local cframe1 = Color(255,255,255,3)

inventoryGame:Event_Add("PanelConstruct","Other Player",function(inv,panel)
    if inv.ClassName != "inv_armor" then return end
    
    local invArmor = inv
    local invH = invArmor.Size[2]

    panel:SetZPos(-1)

    local playerModel = oop.CreatePanel("v_playermodel",panel):ad(function(self,w,h) self:setSize(w,h) end)
    local w,h = ScrW(),ScrH()
    panel:setSize(w * 0.15,math.floor(h * 0.7 / invH) * invH)

    local size = inventoryGame.SlotSize * 0.9
    local subY = panel:H() * 0.3 / 2

    panel:setPos(w - panel:W() - w * 0.08,h / 2 - panel:H()/2 - h / 40)

    playerModel:SetPlayer(inv.parent)
    playerModel.cameraFOV = 15

    function playerModel:PreDraw(w,h)
        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)
        draw.GradientDown(0,0,w,h)

        DisableClipping(true)
        draw.SimpleText(inv.parent:Nick(),"H.25",w/2,-size/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        DisableClipping(false)

        surface.SetDrawColor(0,0,0,160)
        surface.SetBG("points40")
        draw.BG(0,0,w,h)
    end

    function playerModel:DrawOver(w,h)
        surface.SetDrawColor(0,0,0,160)
        surface.SetBG("lines_d_l")
        draw.BG(0,0,w,h)

        draw.Frame(0,0,w,h,cframe1,cframe2)
    end
    
    inventoryGame.InvLocalArmorCreate(panel,panel:GetParent(),invArmor,size)

    function panel:OnChangeInterfaceState(value,isClose)
        if isClose then
            self:SetMouseInputEnabled(false)

            if IsValid(inv) then inv:Close() end
        end
    end

    return true
end,1)

local forceInsert = {
    ["inv_dump"] = 1,
    ["inv_player"] = 2,
    ["inv_backpack"] = 3
}

inventoryGame:Event_Add("PanelConstruct","Other",function(inv,panel)
    if inv.parent == LocalPlayer() or inv.DontPanelConstructOther then return end

    local otherPanel = inventoryGame.otherPanel

    if not IsValid(otherPanel) then
        otherPanel = oop.CreatePanel("v_scrollpanel")
        otherPanel.scrolling = 120
        otherPanel.start = RealTime()
        otherPanel.invs = {}

        inventoryGame.otherPanel = otherPanel
    end

    function otherPanel:CloseInv()
        if self.close then return end

        inventoryGame.SetSelectItem()

        self.close = true
        self.start = RealTime()

        for inv in pairs(otherPanel.invs) do
            if IsValid(inv) then inv:Close() end
        end

        LocalPlayer():SetCooldown("use",0.1)
    end

    function otherPanel:OnChangeInterfaceState(state,isClose)
        if not isClose then return end
        otherPanel:CloseInv()
    end

    local k = 0

    function otherPanel:Think()
        k = math.max(self.start - RealTime() + 0.12,0) / 0.12
        k = math.ease.InSine(k)

        if not self.close then
            k = 1 - k
        else
            if k <= 0 then self:SetVisible(false) self:Remove() scoreboard:Close() end
        end
    end

    local xStart,yStart,xEnd,yEnd
    local alpha

    function otherPanel:Draw(w,h)
        --surface.SetDrawColor(255,0,0)
        --surface.DrawRect(0,0,w,h)

        xStart,yStart,xEnd,yEnd = render.GetScissorData()
        alpha = surface.GetAlphaMultiplier()

        local x,y = self:LocalToScreen()

        surface.SetDrawColor(200,200,200,64 * (1 - k))
        
        --[[DisableClipping(true)
        local size = math.floor(w * k)
        draw.GradientLeft(w / 2,0,size,h)
        draw.GradientRight(w /2 - size,0,size,h)
        DisableClipping(false)]]--

        render.SetScissor(x + w * (1 - k) / 2,y,w * k,h,true)
        surface.SetAlphaMultiplier(k)
        render.SetBlend(k)
    end

    function otherPanel:DrawOver(w,h)
        render.SetScissor(xStart,yStart,xEnd,yEnd,xStart and true)
        surface.SetAlphaMultiplier(alpha)
        render.SetBlend(1)
    end

    local slotSize = inventoryGame.SlotSize
    local invW,invH = inv:GetSize()

    panel:setSize(slotSize * invW,slotSize * invH)

    for x = 1,invW do
        for y = 1,invH do
            local slot = inv:CreatePanelSlot(x,y,panel)
            slot:setSize(slotSize,slotSize)
            slot:SetPos(slotSize * (x - 1),slotSize * (y - 1))
        end
    end

    otherPanel.invs[inv] = true
    panel:SetParent(otherPanel)

    function panel:Draw(w,h)
        DisableClipping(true)
        draw.SimpleText(inv.name or inv.ClassName,"HS.18",w/2,-slotSize/3,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        DisableClipping(false)
    end

    function otherPanel:Update()
        self:setSize(ScrW() * 0.4,ScrH() * 0.4)
        self:setPos(ScrW() /2 - self:W() / 2,ScrH() / 2 - inventoryGame.SlotSize)

        local countInvs = table.Count(otherPanel.invs)
        
        for inv in pairs(otherPanel.invs) do
            local invPlane = inv.panel
            if not IsValid(invPlane) then continue end--wtf
            
            if countInvs > 1 then
                if inv.ClassName == "inv_dump" then
                    invPlane:setPos(0,self:H() - invPlane:H())
                    continue
                elseif inv.ClassName == "inv_backpack" then
                    invPlane:setPos(self:W() - invPlane:W(),self:H() - invPlane:H())
                    continue
                end
            end

            invPlane:setPos(self:W() / 2 - invPlane:W()/2,0)
        end
    end

    otherPanel:Update()

    function otherPanel.canvasPanel:OnMouse(key,value) inventoryGame.SetSelectItem() end

    panel.OnClose = function() end
    
    inv:Event_Add("Remove","otherPanel:Update()",function()
        if IsValid(otherPanel) then
            if not otherPanel.close then
                otherPanel.invs[inv] = nil
                panel:Remove()

                if table.Count(otherPanel.invs) == 0 then scoreboard:Close() end
            end

            otherPanel:Update()
        end
    end)

    scoreboard.OpenInventory()

    return true
end,3)

inventoryGame:Event_Add("Interface State","Other Panel",function(state,isClose)
    if IsValid(inventoryGame.otherPanel) then
        inventoryGame.otherPanel:OnChangeInterfaceState(state,isClose)
    end
end)

inventoryGame.RecounstructPanels()

local old

event.Add("StartCommand","Inventory Other",function(ply,cmd)
    --[[local active = cmd:KeyDown(IN_USE) and true or false

    if active and IsValid(inventoryGame.otherPanel) then
        cmd:RemoveKey(IN_USE)
    end

    if old != active then
        old = active
        
        if active and not LocalPlayer():IsCooldown("use") and IsValid(inventoryGame.otherPanel) and delay < RealTime() then
            inventoryGame.otherPanel:CloseInv()
        end
    end]]--

    local active = cmd:KeyDown(IN_FORWARD) or cmd:KeyDown(IN_BACK) or cmd:KeyDown(IN_MOVELEFT) or cmd:KeyDown(IN_MOVERIGHT)

    if old ~= active then
        old = active

        if active and IsValid(inventoryGame.otherPanel) then inventoryGame.otherPanel:CloseInv() end
    end
end)