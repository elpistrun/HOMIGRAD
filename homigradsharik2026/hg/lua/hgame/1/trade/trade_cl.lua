if not CLIENT then return end

-- Trade state
local tradePanel = nil
local tradeRequestPanel = nil
local tradePartner = nil
local tradeRequester = nil
local tradeMyItems = {}
local tradePartnerItems = {}
local tradeMyConfirmed = false
local tradePartnerConfirmed = false

-- Trade request notification
net.Receive("hg_trade_request", function()
    local requester = net.ReadEntity()
    if not IsValid(requester) then return end
    tradeRequester = requester

    -- Show accept/decline popup
    if IsValid(tradeRequestPanel) then tradeRequestPanel:Remove() end

    tradeRequestPanel = vgui.Create("DFrame")
    tradeRequestPanel:SetSize(350, 150)
    tradeRequestPanel:Center()
    tradeRequestPanel:SetTitle("")
    tradeRequestPanel:SetDraggable(false)
    tradeRequestPanel:ShowCloseButton(false)
    tradeRequestPanel:MakePopup()

    function tradeRequestPanel:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 240))
        draw.SimpleText(L("trade_request_title"), "DermaDefaultBold", w/2, 30, color_white, TEXT_ALIGN_CENTER)
        draw.SimpleText(requester:Name() .. " " .. L("trade_request_wants"), "DermaDefault", w/2, 60, Color(200,200,200), TEXT_ALIGN_CENTER)
    end

    local btnAccept = vgui.Create("DButton", tradeRequestPanel)
    btnAccept:SetSize(140, 40)
    btnAccept:SetPos(20, 95)
    btnAccept:SetText(L("trade_accept"))
    btnAccept:SetFont("DermaDefaultBold")
    function btnAccept:DoClick()
        net.Start("hg_trade_accept")
        net.SendToServer()
        if IsValid(tradeRequestPanel) then tradeRequestPanel:Remove() end
        tradeRequester = nil
    end
    function btnAccept:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 180, 50, 220))
    end

    local btnDecline = vgui.Create("DButton", tradeRequestPanel)
    btnDecline:SetSize(140, 40)
    btnDecline:SetPos(190, 95)
    btnDecline:SetText(L("trade_decline"))
    btnDecline:SetFont("DermaDefaultBold")
    function btnDecline:DoClick()
        net.Start("hg_trade_decline")
        net.SendToServer()
        if IsValid(tradeRequestPanel) then tradeRequestPanel:Remove() end
        tradeRequester = nil
    end
    function btnDecline:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(180, 50, 50, 220))
    end

    -- Auto-close after 15 seconds
    timer.Simple(15, function()
        if IsValid(tradeRequestPanel) then
            tradeRequestPanel:Remove()
            tradeRequester = nil
        end
    end)
end)

-- Trade start (both accepted)
net.Receive("hg_trade_start", function()
    local plyA = net.ReadEntity()
    local plyB = net.ReadEntity()
    if not IsValid(plyA) or not IsValid(plyB) then return end

    tradePartner = (plyA == LocalPlayer()) and plyB or plyA
    tradeMyItems = {}
    tradePartnerItems = {}
    tradeMyConfirmed = false
    tradePartnerConfirmed = false

    if IsValid(tradePanel) then tradePanel:Remove() end

    tradePanel = vgui.Create("DFrame")
    tradePanel:SetSize(700, 500)
    tradePanel:Center()
    tradePanel:SetTitle("")
    tradePanel:SetDraggable(true)
    tradePanel:MakePopup()

    function tradePanel:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(25, 25, 25, 245))
        draw.SimpleText(L("trade_title"), "DermaDefaultBold", w/2, 15, color_white, TEXT_ALIGN_CENTER)

        -- Player names
        if IsValid(LocalPlayer()) then
            draw.SimpleText(LocalPlayer():Name(), "DermaDefault", 175, 40, Color(100, 200, 255), TEXT_ALIGN_CENTER)
        end
        if IsValid(tradePartner) then
            draw.SimpleText(tradePartner:Name(), "DermaDefault", 525, 40, Color(255, 200, 100), TEXT_ALIGN_CENTER)
        end

        -- Divider
        surface.SetDrawColor(60, 60, 60, 200)
        surface.DrawRect(348, 50, 4, 380)

        -- Confirm status
        local myStatus = tradeMyConfirmed and L("trade_confirmed") or L("trade_not_confirmed")
        local partnerStatus = tradePartnerConfirmed and L("trade_confirmed") or L("trade_not_confirmed")
        local myColor = tradeMyConfirmed and Color(50, 200, 50) or Color(200, 200, 200)
        local partnerColor = tradePartnerConfirmed and Color(50, 200, 50) or Color(200, 200, 200)
        draw.SimpleText(myStatus, "DermaDefault", 175, 440, myColor, TEXT_ALIGN_CENTER)
        draw.SimpleText(partnerStatus, "DermaDefault", 525, 440, partnerColor, TEXT_ALIGN_CENTER)
    end

    -- My items list
    local myList = vgui.Create("DScrollPanel", tradePanel)
    myList:SetPos(10, 60)
    myList:SetSize(330, 370)

    -- Partner items list
    local partnerList = vgui.Create("DScrollPanel", tradePanel)
    partnerList:SetPos(360, 60)
    partnerList:SetSize(330, 370)

    local function RebuildLists()
        myList:Clear()
        partnerList:Clear()

        -- My offered items
        for i, name in ipairs(tradeMyItems) do
            local item = myList:Add(name)
            item:SetTall(25)
            item:Dock(TOP)
            item:DockMargin(0, 2, 0, 0)
            item:SetFont("DermaDefault")
            item:SetTextColor(color_white)

            local removeBtn = vgui.Create("DButton", item)
            removeBtn:SetSize(60, 22)
            removeBtn:Dock(RIGHT)
            removeBtn:SetText("X")
            removeBtn:SetFont("DermaDefaultBold")
            function removeBtn:Paint(w, h)
                draw.RoundedBox(2, 0, 0, w, h, Color(180, 50, 50, 200))
            end
            function removeBtn:DoClick()
                net.Start("hg_trade_remove")
                    net.WriteUInt(i, 8)
                net.SendToServer()
            end
        end

        -- Partner offered items
        for i, name in ipairs(tradePartnerItems) do
            local item = partnerList:Add(name)
            item:SetTall(25)
            item:Dock(TOP)
            item:DockMargin(0, 2, 0, 0)
            item:SetFont("DermaDefault")
            item:SetTextColor(color_white)
        end
    end

    -- Add item button (from player's inventory)
    local addBtn = vgui.Create("DButton", tradePanel)
    addBtn:SetPos(10, 460)
    addBtn:SetSize(150, 30)
    addBtn:SetText(L("trade_add_item"))
    addBtn:SetFont("DermaDefault")
    function addBtn:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 100, 180, 200))
    end
    function addBtn:DoClick()
        -- Open inventory picker
        if IsValid(tradePicker) then tradePicker:Remove() end

        tradePicker = vgui.Create("DFrame")
        tradePicker:SetSize(400, 300)
        tradePicker:Center()
        tradePicker:SetTitle(L("trade_pick_item"))
        tradePicker:MakePopup()

        local scroll = vgui.Create("DScrollPanel", tradePicker)
        scroll:Dock(FILL)

        -- List player's inventory items
        local inv = LocalPlayer().inv
        if IsValid(inv) and inv.slots then
            for x = 1, #inv.slots do
                for y = 1, #inv.slots[x] do
                    local slot = inv.slots[x][y]
                    if slot and slot.list and slot.list[1] then
                        local item = slot.list[1]
                        local btn = scroll:Add(item.spawnname or "unknown")
                        btn:SetTall(28)
                        btn:Dock(TOP)
                        btn:DockMargin(0, 2, 0, 0)
                        btn:SetFont("DermaDefault")
                        btn:SetTextColor(color_white)
                        function btn:DoClick()
                            net.Start("hg_trade_add")
                                net.WriteUInt(x, 7)
                                net.WriteUInt(y, 7)
                            net.SendToServer()
                            if IsValid(tradePicker) then tradePicker:Remove() end
                        end
                        function btn:Paint(w, h)
                            draw.RoundedBox(2, 0, 0, w, h, Color(40, 40, 60, 200))
                        end
                    end
                end
            end
        end
    end

    -- Confirm button
    local confirmBtn = vgui.Create("DButton", tradePanel)
    confirmBtn:SetPos(170, 460)
    confirmBtn:SetSize(150, 30)
    confirmBtn:SetText(L("trade_confirm"))
    confirmBtn:SetFont("DermaDefaultBold")
    function confirmBtn:Paint(w, h)
        local col = tradeMyConfirmed and Color(50, 150, 50, 200) or Color(50, 180, 50, 220)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    function confirmBtn:DoClick()
        if tradeMyConfirmed then return end
        net.Start("hg_trade_confirm")
        net.SendToServer()
    end

    -- Cancel button
    local cancelBtn = vgui.Create("DButton", tradePanel)
    cancelBtn:SetPos(540, 460)
    cancelBtn:SetSize(150, 30)
    cancelBtn:SetText(L("trade_cancel"))
    cancelBtn:SetFont("DermaDefault")
    function cancelBtn:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(180, 50, 50, 200))
    end
    function cancelBtn:DoClick()
        net.Start("hg_trade_cancel")
        net.SendToServer()
    end

    -- Store rebuild function for updates
    tradePanel.RebuildLists = RebuildLists
    RebuildLists()
end)

-- Trade update (items/confirmations changed)
net.Receive("hg_trade_update", function()
    local plyA = net.ReadEntity()
    local plyB = net.ReadEntity()

    local countA = net.ReadUInt(8)
    tradeMyItems = {}
    for i = 1, countA do
        tradeMyItems[i] = net.ReadString()
    end

    local countB = net.ReadUInt(8)
    tradePartnerItems = {}
    for i = 1, countB do
        tradePartnerItems[i] = net.ReadString()
    end

    tradeMyConfirmed = net.ReadBool()
    tradePartnerConfirmed = net.ReadBool()

    if IsValid(tradePanel) and tradePanel.RebuildLists then
        tradePanel.RebuildLists()
    end
end)

-- Trade end
net.Receive("hg_trade_end", function()
    local reason = net.ReadString()
    if IsValid(tradePanel) then
        tradePanel:Remove()
        tradePanel = nil
    end
    if IsValid(tradeRequestPanel) then
        tradeRequestPanel:Remove()
        tradeRequestPanel = nil
    end

    tradePartner = nil
    tradeMyItems = {}
    tradePartnerItems = {}
    tradeMyConfirmed = false
    tradePartnerConfirmed = false

    if reason == "complete" then
        -- Already handled by chat print
    elseif reason == "cancelled" then
        chat.AddText(Color(200, 200, 200), "[Trade] ", L("trade_cancelled"))
    elseif reason == "died" then
        chat.AddText(Color(200, 100, 100), "[Trade] ", L("trade_ended_death"))
    elseif reason == "too_far" then
        chat.AddText(Color(200, 100, 100), "[Trade] ", L("trade_too_far"))
    end
end)
