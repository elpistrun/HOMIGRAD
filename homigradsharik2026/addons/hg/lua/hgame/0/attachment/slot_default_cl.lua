attachmentGame:Event_Add("MenuCreate","Default",function(self,frame)
    frame:Event_Add("AttachmentClick","Main",function(_,path,key,panel)
        frame:SetSelectSlot(panel)
        
        local panelContent = vCreate("v_panel",frame)
        panelContent:SetZPos(2)

        panel.OnSelectSlotLose = function()
            panel.OnSelectSlotLose = nil

            if IsValid(panelContent) then panelContent:Remove() end
        end

        function panelContent:Step()
            if not IsValid(panel) then panelContent:Remove() frame:SetSelectSlot() return end--wtf

            self:setPos(panel.x + panel:W() + 16,panel.y)
        end

        function panelContent:OnMouse(key,value)
            if not value or key == MOUSE_RIGHT then return end

            frame:SetSelectSlot()
        end

        local w = 1
        local x,y = 0,0

        local corner = attachmentGame.iconSizeSelected * 0.1
        local iconSize = attachmentGame.iconSizeSelected - corner

        local order = {}
        
        for pathVar,key in pairs(self.attachments[path][3].slots) do
            local config = attachmentGame.config[key[1]]

            order[#order + 1] = {pathVar,key,pathVar != 0 and config and config.printName or "!"}
        end

        table.sort(order,function(a,b) return a[3] < b[3] end)

        for i = 1,#order do
            local order = order[i]
            local pathVar,key = order[1],order[2]

            local variant = vCreate("v_button",panelContent):setSize(iconSize,iconSize)
            variant:setPos(corner + (iconSize + corner) * x,corner + (iconSize + corner + 24 + 16) * y)
            variant.HoveredTrueSnds = attachmentGame.HoveredTrueSnds

            function variant.Draw(_,w,h)
                draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackground)
                
                local isHovered = variant:IsHovered()
                if isHovered or self.attachments[path][2][1] == key[1] then draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackgroundHovered) end

                local config = attachmentGame.config[key[1]]

                if config then
                    surface.SetMaterial(MaterialHash(config.icon or attachmentGame.defaultIcon))
                    surface.SetDrawColor(255,255,255)
                    surface.DrawTexturedRectRotated(w/2,h/2,w,h,0)
                else
                    draw.SimpleText("X","H.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                end
                
                if isHovered then
                    variant:SetZPos(3)

                    DisableClipping(true)

                    if pathVar == 0 then
                        draw.SimpleText("default","HS.12",w/2,-6,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
                    end

                    if config then
                        draw.DrawTextWitchBackground(config.printName or key[1],w/2,h + 24,"HS.12",6,attachmentGame.colorBackground)
                    end

                    DisableClipping(false)
                else
                    variant:SetZPos(1)
                end
            end

            function variant.OnClick()
                frame.DnAttachmentSet(path,pathVar)

                local depth = self.attachments[path].depth

                sound.EmitScreen("homigrad/vgui/item_drop.wav",0.8,150 + (depth - 1) * 5)
                sound.EmitScreen("homigrad/vgui/panorama/rotate_weapon_08.wav",1,80 + (depth - 1) * 5)
            end

            x = x + 1
            w = math.max(w,x)

            if x > 3 then
                x = 0
                y = y + 1
            end
        end
        
        panelContent:setSize((iconSize + corner) * w + corner,(iconSize + corner + 24 + 16) * (y + 1) + corner)
    end)
end)