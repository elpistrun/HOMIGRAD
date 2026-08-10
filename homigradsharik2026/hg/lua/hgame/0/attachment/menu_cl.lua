attachmentGame = attachmentGame or {}

local delayOpen = 0.25

attachmentGame.iconSize = 54
attachmentGame.iconSizeSelected = 72
attachmentGame.iconSizeEmpty = 24

attachmentGame.colorBackground = Color(20,20,20,200)
attachmentGame.colorBackgroundHovered = Color(255,255,255,75)
attachmentGame.colorBackgroundHovered2 = Color(255,255,255,25)

attachmentGame.defaultIcon = "homigrad/vgui/icons/inventory.png"

attachmentGame.HoveredTrueSnds = {
    pitch = 200,
    volume = 0.2,
    list = {
        "homigrad/vgui/csgo_ui_contract_type1.wav",
        "homigrad/vgui/csgo_ui_contract_type2.wav",
        "homigrad/vgui/csgo_ui_contract_type3.wav",
        "homigrad/vgui/csgo_ui_contract_type4.wav",
        "homigrad/vgui/csgo_ui_contract_type5.wav",
        "homigrad/vgui/csgo_ui_contract_type6.wav",
        "homigrad/vgui/csgo_ui_contract_type7.wav",
        "homigrad/vgui/csgo_ui_contract_type8.wav",
        "homigrad/vgui/csgo_ui_contract_type9.wav",
    }
}

local angle_zero = Angle()

function draw.DrawTextWitchBackground(text,x,y,font,radius,color)
    surface.SetFont(font)

    local tw,th = surface.GetTextSize(text)

    tw = tw + 16
    th = th + 16

    draw.RoundedBox(radius,x - tw/2,y - th/2,tw,th,color)
    draw.SimpleText(text,font,x,y,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end

local hideHands_mat = Material("homigrad/vgui/icons/hands.png")
local hideSlots_mat = Material("homigrad/vgui/icons/slot.png")
local cosmetic_mat = Material("homigrad/vgui/icons/paint.png")

local color_gray = Color(128,128,128,128)

function attachmentGame.CreatePanel(manual)
    local self = manual.self

    local frame = vCreate("v_frame")

    local attachmentsPanel = {}
    frame.attachments = attachmentsPanel

    function frame.Update()
        for path,key in SortedPairs(self.attachments) do
            local panel = attachmentsPanel[path]
            local isCreate = not IsValid(panel)

            panel = panel or vCreate("v_button",frame)
            panel.key = key
            panel.HoveredTrueSnds = attachmentGame.HoveredTrueSnds

            if not isCreate then continue end

            function panel:Draw(w,h)
                draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackground)

                local isHovered = self:IsHovered() or frame.selectSlot == panel
                if isHovered then draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackgroundHovered) end

                local config = attachmentGame.config[key[2][1]]

                if config then
                    surface.SetDrawColor(255,255,255)
                    surface.SetMaterial(MaterialHash(config.icon or attachmentGame.defaultIcon))
                    surface.DrawTexturedRectRotated(w/2,h/2,w*0.95,h*0.95,0)
                else
                    if path == "0" then
                        surface.SetDrawColor(0,0,0)
                        surface.SetMaterial(MaterialHash(key[3].icon or attachmentGame.defaultIcon))
                        surface.DrawTexturedRectRotated(w/2,h/2,w*0.95,h*0.95,0)
                    else
                        draw.SimpleText("+","H.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                    end
                end

                if isHovered then
                    self:SetZPos(1)
                    DisableClipping(true)

                    local text = config and (config.printName or key[2][1]) or key[3].name or ""
                    draw.DrawTextWitchBackground(text,w/2,-24,"HS.12",6,attachmentGame.colorBackground)

                    DisableClipping(false)
                else
                    self:SetZPos(0)
                end
            end

            function panel.OnClick()
                frame:Event_Call("AttachmentClick",path,key,panel)
            end

            attachmentsPanel[path] = panel
        end

        for path,panel in pairs(attachmentsPanel) do
            if self.attachments[path] then continue end
            if IsValid(panel) then panel:Remove() end

            attachmentsPanel[path] = nil
        end
    end

    local angleRotate = Angle(0,90,0)
    frame.angleRotate = angleRotate

    local oldMouseX,oldMouseY = 0,0
    local sensivity = 10

    frame.screenX = 0
    frame.screenY = 0

    function frame.Step()
        local mouseX,mouseY = gui.MouseX(),gui.MouseY()

        if input.IsMouseDown(MOUSE_RIGHT) then
            angleRotate[1] = angleRotate[1] + (oldMouseY - mouseY) / ScrH() * 90 * sensivity
            oldMouseY = mouseY
            
            angleRotate[2] = angleRotate[2] + (oldMouseX - mouseX) / ScrW() * 90 * sensivity
            oldMouseX = mouseX

            angleRotate[1] = math.Clamp(angleRotate[1],-90,90)

            angleRotate:Normalize()
        else
            oldMouseY = mouseY
            oldMouseX = mouseX
        end

        if system.HasFocus() then
            frame.screenX = mouseX / ScrW() - 0.5
            frame.screenY = mouseY / ScrH() - 0.5
        end
        
        local wm = self.wm
        if not IsValid(wm) then return end
        
        for path,panel in SortedPairs(attachmentsPanel) do
            local key = self.attachments[path]

            local pos = key[2].slotPos or key[3].slotPos
            local mdl = wm.attachments and wm.attachments[key.parentPath] or wm

            if not pos then
                pos = mdl:GetPos()
            else
                local boneName = key[3].bone or self.AttachmentBoneParent or "weapon"

                local mat = mdl:GetBoneMatrix(mdl:LookupBone(boneName) or mdl:LookupBone("root") or 0)

                if mat then
                    pos = LocalToWorld(pos,angle_zero,mat:GetTranslation(),mat:GetAngles())
                else
                    pos = mdl:GetPos()
                end
            end

            pos = pos:ToScreen()

            if frame.hideSlotsMode then
                panel:SetAlpha(0)
            else
                panel:SetAlpha(frame.selectSlot and frame.selectSlot != panel and 35 or 255)
            end

            local size = ((key[2][1] or path == "0") and panel:IsHovered() and attachmentGame.iconSizeSelected) or (panel == frame.selectSlot and attachmentGame.iconSizeSelected) or ((key[2][1] or path == "0") and attachmentGame.iconSize) or attachmentGame.iconSizeEmpty
            panel:setSize(size,size)

            panel:setPos(pos.x - size/2,pos.y - size/2)
        end
    end

    local start = RealTime()
    local close = false

    function frame:GetK()
        if close then
            
        else
            return 1 - math.max(start + delayOpen - RealTime(),0) / delayOpen
        end
    end

    frame:Update()

    function frame:SetSelectSlot(panel)
        if IsValid(frame.selectSlot) and frame.selectSlot.OnSelectSlotLose then
            frame.selectSlot:OnSelectSlotLose()
        end

        frame.selectSlot = panel
    end

    function frame:OnMouse(key,value)
        if not value or key == MOUSE_RIGHT then return end

        frame:SetSelectSlot()
    end

    attachmentGame:Event_Call("MenuCreate",self,frame)

    --

    local corner = 16

    local hideHands
    local cosmetic

    local hideSlots = oop.CreatePanel("v_button",frame):setSize(attachmentGame.iconSize,attachmentGame.iconSize)
    hideSlots:setPos(ScrW()/2-hideSlots:W()/2,ScrH()-hideSlots:H()-corner)
    hideSlots.HoveredTrueSnds = attachmentGame.HoveredTrueSnds

    function hideSlots:Draw(w,h)
        draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackground)
        if self:IsHovered() then draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackgroundHovered2) end
        surface.SetMaterial(hideSlots_mat)
        if frame.hideSlotsMode then surface.SetDrawColor(255,0,0) else surface.SetDrawColor(0,255,0) end
        local size = h * (0.75 + self.hovered / 10)
        surface.DrawTexturedRectRotated(w/2,h/2,size,size,0)
        DisableClipping(true) draw.SimpleText("2","HS.12",w/2,h + 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP) DisableClipping(false)
    end
    function hideSlots:OnClick() frame.hideSlotsMode = not frame.hideSlotsMode end
    local old 
    function hideSlots:Step()
        local active = input.IsButtonDown(KEY_2)
        if old != active then
            old = active
            if active then hideSlots:ForceClick() end
        end
    end

    if not manual.hideCosmetic then
        cosmetic = oop.CreatePanel("v_button",frame):setSize(attachmentGame.iconSize,attachmentGame.iconSize)
        cosmetic:setPos(hideSlots.x + hideSlots:W() + corner,ScrH()-hideSlots:H()-corner)
        cosmetic.HoveredTrueSnds = attachmentGame.HoveredTrueSnds

        function cosmetic:Draw(w,h)
            draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackground)
            if self:IsHovered() then draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackgroundHovered2) end
            surface.SetMaterial(cosmetic_mat)
            if frame.cosmeticMode then surface.SetDrawColor(0,255,0) else surface.SetDrawColor(255,0,0) end
            local size = h * (0.75 + self.hovered / 10)
            surface.DrawTexturedRectRotated(w/2,h/2,size,size,0)

            DisableClipping(true)
                draw.SimpleText("3","HS.12",w/2,h + 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)

                --[[if frame.pipetteSkin then
                    surface.SetDrawColor(255,255,255)
                    surface.SetMaterial(MaterialHash(attachmentGame.config_skin[frame.pipetteSkin].material))
                    surface.DrawTexturedRectRotated(w + corner + w/2,h/2,h * 0.9,h * 0.9,0)

                    draw.SimpleText("CTRL","HS.12",w + w/2 + corner,h + 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
                end]]--
            DisableClipping(false)
        end
        function cosmetic:OnClick() frame.cosmeticMode = not frame.cosmeticMode end
        local old 
        function cosmetic:Step()
            local active = input.IsButtonDown(KEY_3)
            if old != active then
                old = active
                if active then cosmetic:ForceClick() end
            end
        end
    end

    if not manual.hideHands then
        frame.hideHandsMode = true
        hideHands = oop.CreatePanel("v_button",frame):setSize(attachmentGame.iconSize,attachmentGame.iconSize)
        hideHands:setPos(hideSlots.x - hideHands:W() - corner,ScrH()-hideSlots:H()-corner)
        hideHands.HoveredTrueSnds = attachmentGame.HoveredTrueSnds

        function hideHands:Draw(w,h)
            draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackground)
            if self:IsHovered() then draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackgroundHovered2) end
            surface.SetMaterial(hideHands_mat)
            if frame.hideHandsMode then surface.SetDrawColor(255,0,0) else surface.SetDrawColor(0,255,0) end
            local size = h * (0.75 + self.hovered / 10)
            surface.DrawTexturedRectRotated(w/2,h/2,size,size,0)
            DisableClipping(true) draw.SimpleText("1","HS.12",w/2,h + 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP) DisableClipping(false)
        end
        function hideHands:OnClick() frame.hideHandsMode = not frame.hideHandsMode end
        local old 
        function hideHands:Step()
            local active = input.IsButtonDown(KEY_1)
            if old != active then
                old = active
                if active then hideHands:ForceClick() end
            end
        end
    end
    
    local credits = oop.CreatePanel("v_button",frame):setSize(attachmentGame.iconSize * 2,attachmentGame.iconSize / 2)
    credits:setPos((hideHands or hideSlots).x - credits:W() - corner,(cosmetic or hideSlots).y + hideSlots:H() - credits:H())

    function credits:Draw(w,h)
        draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackground)
        if self:IsHovered() then draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackgroundHovered) end
        draw.SimpleText("СОЗДАЛИ","HS.12",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    function credits:OnClick()
        local frame = VguiCreateBlackScreen("attachment_cl_credits")
        
        local size = 124
        local corner = size * 0.33 / 2

        --

        local avatarpanel = oop.CreatePanel("v_avataricons",frame):ad(function(self,w,h) self:setSize(size,size):setPos(w/2-self:W()/2,h * 0.2 - self:H()/2) end)
        avatarpanel:Setup(size * (1 - 0.33))
        avatarpanel:AddPanel("1",GetGlobalVar("AttachmentCredits_1_Avatar"),GetGlobalVar("AttachmentCredits_1_AvatarFrame"))
        function avatarpanel:Draw(w,h)
            DisableClipping(true)
            draw.SimpleText("Разрабатывал и создавал один","HS.25",w/2,-corner,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            draw.SimpleText("Шарик","HS.25",w/2,h + corner,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            DisableClipping(false)

            self:DrawTip("Действительно, кто ещё кодит хомиград.com")
        end

        local avatarpanel = oop.CreatePanel("v_avataricons",frame):ad(function(self,w,h) self:setSize(size,size):setPos(w/2-self:W()/2,h * 0.5 - self:H()/2) end)
        avatarpanel:Setup(size * (1 - 0.33))
        avatarpanel:AddPanel("1",GetGlobalVar("AttachmentCredits_3_Avatar"),GetGlobalVar("AttachmentCredits_3_AvatarFrame"))
        function avatarpanel:Draw(w,h)
            DisableClipping(true)
            draw.SimpleText("Помог разобратся в модулях на оружие и тестировал","HS.25",w/2,-corner,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            draw.SimpleText("Tarkovsky","HS.25",w/2,h + corner,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            DisableClipping(false)

            self:DrawTip("Помог понять калибры, общее представление о модулях на оружиях и зачем они нужны\nПодрубал демку и вместе смотрели как собираются модули на оружие в EFT")
        end

        local avatarpanel = oop.CreatePanel("v_avataricons",frame):ad(function(self,w,h) self:setSize(size,size):setPos(w/2-self:W()/2,h * 0.8 - self:H()/2) end)
        avatarpanel:Setup(size * (1 - 0.33))
        avatarpanel:AddPanel("1",GetGlobalVar("AttachmentCredits_2_Avatar"),GetGlobalVar("AttachmentCredits_2_AvatarFrame"))
        function avatarpanel:Draw(w,h)
            DisableClipping(true)
            draw.SimpleText("Тестировал","HS.25",w/2,-corner,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            draw.SimpleText("Laidon","HS.25",w/2,h + corner,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            DisableClipping(false)

            self:DrawTip("Самая быстрая рука на диком западе")
        end

        --

        local particles = particles2D:Create()

        particles.gravity = {0,ScrH() / 6}
        particles.friction = 0.1

        particles.SetDrawFunction(function(part,ft,time)
            local col = 80 + math.max(15 * math.cos(part[1] / 64 - time * 6),0) + math.max(80 * math.sin(part[2] / 32 - time * 6),0)

            surface.SetDrawColor(col,col,col + 20,65)
            surface.DrawRect(part[1] - 1,part[2] - 1,2,2)
        end)

        function frame:DrawContent(w,h,_,ft)
            particles.Draw(w,h,ft or FrameTime())

            if #particles.list >= 200 then return end
            particles.Add(math.Rand(0,w),h,-ScrW() * math.Rand(0.3,1.3) * math.randAbs() * 0.1,-ScrH() * math.Rand(0.6,0.8) * 0.5)
        end

        for i = 1,250 do
            frame:DrawContent(frame:W(),frame:H(),nil,1 / 24)
        end
    end

    --

    function frame.Draw(_,w,h)
        local printName = self.PrintName

        draw.SimpleText(printName,"HS.25",w/2,h - corner * 2 - attachmentGame.iconSize,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
        draw.SimpleText("В РАЗРАБОТКЕ, ЭТО НЕ ФИНАЛЬНАЯ ВЕРСИЯ","H.12",w/2,0,color_gray,TEXT_ALIGN_CENTER)
    end

    frame.fov = 120

    function frame:OnMouseWheeled(wheel)
        frame.fov = math.Clamp(frame.fov - wheel * 10,30,160)
    end

    return frame
end

if Initialize then
    timer.Simple(0,function()
        local wep = LocalPlayer():GetActiveWeapon()
        if not IsValid(wep) or not wep.AttachmentMenu_Open then return end

        wep:AttachmentMenu_Open()
    end)
end