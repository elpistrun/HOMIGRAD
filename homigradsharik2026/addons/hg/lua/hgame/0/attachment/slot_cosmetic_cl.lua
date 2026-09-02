local function paint(frame,path,name)
    frame.DoAttachmentSetSkin(path,name)
    frame.pipetteSkin = name

    sound.EmitScreen("weapons/spray/shoot.wav",0.5,100)
    sound.EmitScreen("weapons/spray/draw.wav",0.6,100)
end

attachmentGame:Event_Add("MenuCreate","Cosmetic",function(self,frame)
    frame:Event_Add("AttachmentClick","Cosmetic",function(_,path,key,panel)
        if not frame.cosmeticMode then return end

        if input.IsButtonDown(KEY_LCONTROL) then
            paint(frame,path)
            
            return true
        end

        frame:SetSelectSlot(panel)

        local panelConrentCosmetic = vCreate("v_panel",frame)
        panelConrentCosmetic:SetZPos(2)

        local panelContentSkin = vCreate("v_panel",frame)
        panelContentSkin:SetZPos(2)

        panel.OnSelectSlotLose = function()
            panel.OnSelectSlotLose = nil

            if IsValid(panelConrentCosmetic) then panelConrentCosmetic:Remove() end
            if IsValid(panelContentSkin) then panelContentSkin:Remove() end
        end

        function panelConrentCosmetic:Step() self:setPos(panel.x - 16 - self:W(),panel.y) end
        
        function panelConrentCosmetic:OnMouse(key,value)
            if not value or key == MOUSE_RIGHT then return end
            frame:SetSelectSlot()
        end

        function panelContentSkin:Step() self:setPos(panel.x + panel:W() + 16,panel.y - attachmentGame.iconSizeEmpty - 48) end

        function panelContentSkin:OnMouse(key,value)
            if not value or key == MOUSE_RIGHT then return end
            frame:SetSelectSlot()
        end

        --

        local w = 1
        local x,y = 0,0

        local corner = attachmentGame.iconSizeSelected * 0.1
        local iconSize = attachmentGame.iconSizeSelected - corner

        local config = attachmentGame.config[key[2][1]]
        if path != "0" and not config then return true end

        config = config or self.attachments["0"][3]

        local cosmeticList = config.cosmetic

        if cosmeticList then
            local new = {}
            for k,v in pairs(cosmeticList) do new[k] = v end
            new["z"] = {}

            for cosmeticName,info in SortedPairs(new) do
                local variant = vCreate("v_button",panelConrentCosmetic):setSize(iconSize,iconSize)
                variant:setPos(corner + (iconSize + corner) * x,corner + (iconSize + corner + 24 + 16) * y)
                variant.HoveredTrueSnds = attachmentGame.HoveredTrueSnds

                if cosmeticName == "z" then cosmeticName = nil end
                
                function variant.Draw(_,w,h)
                    draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackground)
                    
                    local isHovered = variant:IsHovered()
                    if isHovered or self.attachments[path][1].cosmetic == cosmeticName then draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackgroundHovered) end

                    local config = cosmeticName and attachmentGame.config_cosmetic[cosmeticName]

                    local icon = info.icon or config and config.icon
                    local printName = info.printName or config and config.printName or cosmeticName

                    if icon then
                        surface.SetMaterial(MaterialHash(icon))
                        surface.SetDrawColor(255,255,255)
                        surface.DrawTexturedRectRotated(w/2,h/2,w,h,0)
                    else
                        draw.SimpleText(cprintName or "X","H.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                    end
                    
                    if isHovered then
                        variant:SetZPos(3)

                        DisableClipping(true)

                        if printName then
                            draw.DrawTextWitchBackground(printName,w/2,h + 24,"HS.12",6,attachmentGame.colorBackground)
                        else
                            draw.DrawTextWitchBackground("EMPTY",w/2,h + 24,"HS.12",6,attachmentGame.colorBackground)
                        end

                        DisableClipping(false)
                    else
                        variant:SetZPos(1)
                    end
                end

                function variant.OnClick()
                    frame.DoAttachmentSetCosmetic(path,cosmeticName)

                    local depth = self.attachments[path].depth

                    sound.EmitScreen("weapons/spray/shoot_end.wav",0.2,80)
                    sound.EmitScreen("homigrad/vgui/panorama/rotate_weapon_09.wav",1,80)
                    sound.EmitScreen("homigrad/vgui/panorama/rotate_weapon_08.wav",1,80)
                end

                x = x + 1
                w = math.max(w,x)

                if x > 3 then
                    x = 0
                    y = y + 1
                end
            end

            panelConrentCosmetic:setSize((iconSize + corner) * w + corner,(iconSize + corner + 24 + 16) * (y + 1) + corner)
        else
            function panelConrentCosmetic:Draw(w,h)
                DisableClipping(true)
                draw.SimpleText("НЕТ КОСМЕТИКИ","HS.18",0,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
                DisableClipping(false)
            end

            panelConrentCosmetic:setSize(1,iconSize)
        end

        --

        local w = (iconSize + corner) * 12 + corner
        local h = (iconSize + corner) * 6 + corner
        
        local x = 0

        local listButtons = {}

        local function update()
            for i,panel in pairs(listButtons) do if IsValid(panel) then panel:Remove() end listButtons[i] = nil end

            local x,y = 0,attachmentGame.iconSizeEmpty + 40 + attachmentGame.iconSizeSelected + corner + 48
            
            local new = {}
            if attachmentGame.category_skin[selectCategory] then
                for k,v in pairs(attachmentGame.category_skin[selectCategory].listIndex) do new[k] = v end
            end
            new["z"] = {}

            for skinName,info in pairs(new) do
                local variant = oop.CreatePanel("v_button",panelContentSkin):setSize(iconSize,iconSize)
                listButtons[#listButtons + 1] = variant
                variant:setPos(x,y)

                if skinName == "z" then skinName = nil end

                function variant.Draw(_,w,h)
                    local size = h
                    local hovered = 1 + variant.hovered

                    if hovered > 1.1 then
                        DisableClipping(true)
                        size = size * hovered
                    end

                    draw.RoundedBox(6,w/2-size/2,h/2-size/2,size,size,attachmentGame.colorBackground)

                    if self.attachments[path][1].skin then
                        if self.attachments[path][1].skin[frame.skinSlotSelect] == skinName then
                            draw.RoundedBox(6,w/2-size/2,h/2-size/2,size,size,attachmentGame.colorBackgroundHovered)
                        end
                    else
                        if self.attachments[path][1].skin_0 == skinName then
                            draw.RoundedBox(6,w/2-size/2,h/2-size/2,size,size,attachmentGame.colorBackgroundHovered)
                        end
                    end

                    if skinName and info.material then
                        surface.SetDrawColor(255,255,255)
                        surface.SetMaterial(MaterialHash(info.material))

                        local hovered = 1 + variant.hovered

                        surface.DrawTexturedRectRotated(w/2,h/2,size * 0.9,size * 0.9,0)
                    else
                        draw.SimpleText("X","H.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                    end

                    if variant:IsHovered() then
                        variant:SetZPos(1)

                        DisableClipping(true)

                        if skinName then
                            draw.DrawTextWitchBackground(info.printName or skinName,w/2,size,"HS.12",6,attachmentGame.colorBackground)
                        else
                            draw.DrawTextWitchBackground("EMPTY",w/2,size + 24,"HS.12",6,attachmentGame.colorBackground)
                        end

                        DisableClipping(false)
                    else
                        variant:SetZPos(0)
                    end

                    DisableClipping(false)
                end

                function variant:OnClick()
                    paint(frame,path,skinName)
                end

                x = x + iconSize + corner

                if x + iconSize > w then
                    x = 0
                    y = y + iconSize + corner + 24 + 16
                end
            end
        end

        if config.model or config.subMaterialID or path == "0" then
            local new = {}

            if config.skin then
                for skinSlotName in SortedPairs(config.skin) do
                    new[#new + 1] = skinSlotName
                end
            else
                new[#new + 1] = "0"
            end

            local xSkin = 0

            frame.skinSlotSelect = nil

            for i,skinSlotName in pairs(new) do
                local variant = oop.CreatePanel("v_button",panelContentSkin)
                variant:setPos(xSkin,0)

                if not frame.skinSlotSelect then frame.skinSlotSelect = skinSlotName end

                if skinSlotName == "0" then
                    variant:setSize(attachmentGame.iconSizeEmpty,attachmentGame.iconSizeEmpty)
                else
                    surface.SetFont("H.12")
                    local tw,th = surface.GetTextSize(skinSlotName)
                    variant:setSize(tw + 16,attachmentGame.iconSizeEmpty)
                end

                xSkin = xSkin + variant:W() + 16

                function variant:Draw(w,h)
                    draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackground)
                    if self:IsHovered() or frame.skinSlotSelect == skinSlotName then draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackgroundHovered) end

                    draw.SimpleText(skinSlotName,"H.12",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                end
                
                function variant:OnClick() frame.skinSlotSelect = skinSlotName end
            end

            for categoryName,info in SortedPairs(attachmentGame.category_skin) do
                if categoryName == "other" then continue end
                if not selectCategory then selectCategory = categoryName end

                local categoryButton = oop.CreatePanel("v_button",panelContentSkin):setSize(attachmentGame.iconSizeSelected,attachmentGame.iconSizeSelected)
                categoryButton:setPos(x,attachmentGame.iconSizeEmpty + 48)
                
                function categoryButton:Draw(w,h)
                    draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackground)
                    if self:IsHovered() or selectCategory == categoryName then draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackgroundHovered) end

                    surface.SetDrawColor(255,255,255)
                    surface.SetMaterial(MaterialHash(info.icon or attachmentGame.defaultIcon))
                    surface.DrawTexturedRectRotated(w/2,h/2,h * 0.8,h * 0.8,0)

                    if self:IsHovered() then
                        DisableClipping(true)
                        draw.DrawTextWitchBackground(info.printName or categoryName,w/2,h + 24,"HS.12",6,attachmentGame.colorBackground)
                        DisableClipping(false)
                    end
                end

                function categoryButton:OnClick()
                    selectCategory = categoryName
                    update()
                end

                x = x + categoryButton:W() + corner
            end

            panelContentSkin:setSize(w,h)
        else
            function panelContentSkin:Draw(w,h)
                DisableClipping(true)
                draw.SimpleText("НЕТ СКИНОВ","HS.18",0,48 + attachmentGame.iconSizeEmpty + attachmentGame.iconSizeSelected / 2,nil,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
                DisableClipping(false)
            end

            panelContentSkin:setSize(1,iconSize)
        end

        update()

        return true
    end,-1)
end)

--PrintTable(LocalPlayer():GetActiveWeapon().attachments)