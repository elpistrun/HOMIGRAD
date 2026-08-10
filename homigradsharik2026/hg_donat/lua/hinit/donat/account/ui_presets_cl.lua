local Page = donatPanel:Page_Reg(1)

local PageSub = Page.Reg_Page(3)
PageSub.Name = "Presets"

function PageSub.Open(frame)
    local avatar = Page.avatarModel
    
    Page.panelPresets = frame

    local selectItem

    local bodygroupsSelected
    local bodygroupsList = oop.CreatePanel("v_scrollpanel",frame):ad(function(self,w,h) self:setSize(w,h - 80) end)
    bodygroupsList:CreateVBar()
    bodygroupsList.canvasPanel:AddFlexParent()
    bodygroupsList.scrolling = 300

    local button = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(w,60):setPos(0,h - self:H()) end)
    button:SetupDrawStyle("white_gradient"); button.gradientSide = "bottom"; button.text = L("donat_ui_outfit_model"); button.font = "HS.18"
    function button.OnClick()
        outfitManager:CoroutineWrap(function()
            sound.EmitScreen("homigrad/vgui/csgo_ui_store_select.wav",0.5)
            button:SetLock(true)

            if selectItem:SendOutfit(bodygroupsSelected,avatar.mdlColor and avatar.mdlColor:ToColor()) then
                sound.EmitScreen("homigrad/vgui/panorama/case_unlock_immediate_01.wav",0.5,255)
                chat.AddText(L("donat_outfit_has_equip"))

                frame:SelectItem(outfitManager:GetPlayerModelID(AccountSteamID64))
            end

            if IsValid(button) then button:SetLock(false) end
        end)
    end

    local sliders

    function frame:SelectItem(itemID)
        local list = inventoryManager.listGame[AccountSteamID64]
        if not list then return end

        selectItem = list[itemID]
        bodygroupsSelected = {}
        bodygroupsList:Clear()

        if not selectItem then return end

        local info = selectItem:GetModelInfo()
        if not info or not info.bodygroupsMax then return end
        local equipBodygroups = selectItem.data.equipBodygroups or {}

        for x = -1,info.bodygroupsMax do
            selectItem:SetBodygroup(x,0,avatar.mdl)
        end

        sliders = {}

        local y = 0
        for x = -1,info.bodygroupsMax do
            local info = info.bodygroups[x]
            if not info then continue end

            local Y = y
            local panelTitle = oop.CreatePanel("v_panel",bodygroupsList):ad(function(self,w,h) self:setSize(w,40 + 50) end):AddByFlex()
            local panel = oop.CreatePanel("v_panel",panelTitle):ad(function(self,w,h) self:setSize(w,h-40):setPos(0,40) end)
            local slider = oop.CreatePanel("v_slider",panel):ad(function(self,w,h) self:setSize(w,60):setPos(0,h/2-self:H()/2) end)
            slider.round = 1
            slider:SetMin(0)
            slider:SetMax(#info)
            slider:SetValue(0)

            sliders[x] = slider

            function panelTitle:Draw(w,h)
                local newValue = selectItem:BodygroupToReal(x,selectItem:GetBodygroup(x,avatar.mdl))

                if newValue ~= slider:GetValue() then
                    slider:SetValue(newValue)
                    slider:OnValue(newValue)
                end

                panelTitle.error = nil
                
                if newValue != 0 then
                    if not info[newValue] or not selectItem.data.bodygroups or not selectItem.data.bodygroups[tostring(x)] or (selectItem.data.bodygroups[tostring(x)][tostring(newValue)] or 0) < info[newValue].xp then
                        panelTitle.error = true
                    end
                end

                if self.error then
                    surface.SetDrawColor(255,0,0,100)
                    surface.DrawRect(0,0,w,40)
                    surface.SetDrawColor(255,0,0,255)
                    draw.GradientRight(0,0,w,40)

                    draw.SimpleText(L("donat_ui_not_access"),"HS.25",w -  16,20,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
                else
                    surface.SetDrawColor(0,0,0,100)
                    surface.DrawRect(0,0,w,40)
                    draw.GradientLeft(0,0,w,40)
                end

                draw.SimpleText(L(info[slider:GetValue()].name),"HS.25",16,20,nil,nil,TEXT_ALIGN_CENTER)
            end

            function slider:OnValue(value)
                panelTitle.error = nil
                bodygroupsSelected[x] = nil

                selectItem:SetBodygroup(x,value,avatar.mdl)

                if value != 0 then
                    bodygroupsSelected[x] = value
                end
            end

            local x = tostring(x)
            
            if equipBodygroups[x] then
                slider:SetValue(tonumber(equipBodygroups[x]))
                slider:OnValue(tonumber(equipBodygroups[x]))
            end
        end

        if info.colorable then
            local panel = oop.CreatePanel("v_panel",bodygroupsList):ad(function(self,w,h) self:setSize(w,w/4) end):AddByFlex()
            function panel:Draw(w,h)
                surface.SetDrawColor(0,0,0,100)
                surface.DrawRect(0,0,w,40)
                draw.GradientLeft(0,0,w,40)

                draw.SimpleText(L("donat_ui_outfit_color"),"HS.25",16,20,nil,nil,TEXT_ALIGN_CENTER)
            end
            local colorMixer = oop.CreatePanel("v_colormixer",panel):ad(function(self,w,h) self:setSize(w/2,h - 40):setPos(w/2-self:W()/2,40) end)
            colorMixer:SetPalette(false)
            colorMixer:SetAlphaBar(false)
            colorMixer:SetColor(selectItem.data.color or Color(255,255,255))

            function colorMixer.ValueChanged(_,color)
                avatar.mdlColor = Vector(color.r / 255,color.g / 255,color.b / 255)
            end

            local color = colorMixer:GetColor()
            avatar.mdlColor = Vector(color.r / 255,color.g / 255,color.b / 255)
        end
    end

    function frame:Open()
        if not sliders then return end

        local info = selectItem:GetModelInfo()

        for x = -1,info.bodygroupsMax do
            local slider = sliders[x]
            if not slider then continue end

            local value = selectItem:GetBodygroup(x,avatar.mdl)
            value = selectItem:BodygroupToReal(x,value)

            slider:SetValue(value)
            slider:OnValue(value)
        end
    end
    
    --

    function frame:Update()
        button:SetLock(false)
    end

    frame:SelectItem(outfitManager:GetPlayerModelID(AccountSteamID64))
end

local function update()
    local panel = PageSub.panel
    if IsValid(panel) and panel.Update then panel:Update() end
end

inventoryManager:Event_Add("Error","UI Preset",function(steamid64,err)
    update()
end)

inventoryManager:Event_Add("Update","UI Preset",function(steamid64)
    update()
end)

if Initialize then scoreboard:Open() end
