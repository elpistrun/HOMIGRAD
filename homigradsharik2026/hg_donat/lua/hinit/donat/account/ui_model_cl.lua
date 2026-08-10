local Page = donatPanel:Page_Reg(1)

local PageSub = Page.Reg_Page(2)
PageSub.Name = "Model"

function PageSub.Open(frame)
    local avatar = Page.avatarModel

    local button = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(w/2,60):setPos(0,h - self:H()) end)
    button.text = L("donat_ui_outfit_play"); button.font = "HS.18"; button:SetupDrawStyle("white")

    function button.OnClick()
        outfitManager:CoroutineWrap(function()
            button:SetLock(true)
            sound.EmitScreen("homigrad/vgui/csgo_ui_store_select.wav",0.5)

            local success = outfitManager:NetUserRequest({cmd = "model_equip",modelID = tostring(frame:GetSelectItem().id)})

            if IsValid(button) then button:SetLock(false) end
            
            if success then
                chat.AddText(L("donat_outfit_has_equip"))
                sound.EmitScreen("homigrad/vgui/panorama/case_unlock_immediate_01.wav",0.5,255)
            end
        end)
    end

    local button = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(w/2,60):setPos(w/2,h - self:H()) end)
    button.text = L("donat_ui_outfit_not_play"); button.font = "HS.18"; button:SetupDrawStyle("white")

    function button.OnClick()
        outfitManager:CoroutineWrap(function()
            button:SetLock(true)
            sound.EmitScreen("homigrad/vgui/csgo_ui_store_select.wav",0.5)

            local success = outfitManager:NetUserRequest({cmd = "model_equip"})

            if IsValid(button) then button:SetLock(false) end

            if success then
                chat.AddText(L("donat_outfit_has_remove"))
                sound.EmitScreen("homigrad/vgui/panorama/case_unlock_immediate_01.wav",0.5,255)
            end
        end)
    end

    local scrollPanel = oop.CreatePanel("v_scrollpanel",frame):ad(function(self,w,h) self:setSize(w,h - button:H()) end)
    scrollPanel:CreateVBar()
    scrollPanel.canvasPanel:AddFlexParent()
    scrollPanel.scrolling = 300

    local selectItemID
    local selectItemAnchorID = outfitManager:GetPlayerModelID(AccountSteamID64)

    function frame:SelectItem(id)
        if id == selectItemID then return end
        selectItemID = id

        if id and frame:GetSelectItem() then
            avatar:SetModel(frame:GetSelectItem().data.model)
        end

        if IsValid(Page.panelPresets) then
            Page.panelPresets:SelectItem(id)
        end

        if IsValid(Page.panelBodygroups) then
            Page.panelBodygroups:SelectItem(id)
        end
    end

    function frame:GetSelectItem()
        local id = selectItemID or selectItemAnchorID
        if not id then return end

        local list = inventoryManager.listGame[AccountSteamID64]
        if not list then return end

        return list[id]
    end

    frame:SelectItem(selectItemAnchorID)

    local vbar = 10

    function frame:Update()
        local iconSize = math.ceil((scrollPanel:W() - vbar) / 7)
        scrollPanel.vbar:setSize(vbar + (iconSize % 2) == 0 and 1 or 0,scrollPanel.vbar:H())
        
        scrollPanel:Clear()

        for _,item in pairs(inventoryManager:SortItemList(inventoryManager.listGame[AccountSteamID64],"1_models")) do
            local id = item.id

            local icon = oop.CreatePanel("v_button",scrollPanel):ad(function(self,w,h) self:setSize(iconSize,iconSize) end):AddByFlex()

            function icon:Draw(w,h)
                item:DrawIcon(w,h,self)
                if self:IsHovered() then hoverItem = id end
                if selectItemAnchorID == id or selectItemID == id then
                    surface.SetDrawColor(255,255,255)
                    surface.DrawRect(0,h - 1,w,1)
                end

                if outfitManager:GetPlayerModelID(AccountSteamID64) == id then
                    draw.SimpleText("Экипипрован","HS.18",w/2,8,nil,TEXT_ALIGN_CENTER)
                    
                    surface.SetDrawColor(255,255,255)
                    surface.DrawRect(0,h - 1,w,1)
                end
            end

            function icon:OnClick()
                selectItemAnchorID = id
                frame:SelectItem(selectItemAnchorID)
            end
        end
    end

    frame:Update()
end

if Initialize then scoreboard:Open() end