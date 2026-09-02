local PANEL = oop.Reg("v_tipmenu","v_panel")
if not PANEL then return end

function PANEL:OnInit()
    self.list = {}
    self.height = 30
    self.font = "H25"
    self.corner = vgui.corner
end

function PANEL:AddItem(name,callback)
    self.list[#self.list+1] = {
        name = name,
        callback = callback
    }

    return #self.list
end

function PANEL:Spawn()
    local corner = self.corner
    local height = self.height

    height = height + corner * 2

    local maxWidth = 0

    surface.SetFont(self.font)

    for i,info in pairs(self.list) do
        local tw,th = surface.GetTextSize(info.name)

        maxWidth = math.max(maxWidth,tw)
    end

    maxWidth = maxWidth + corner * 2

    for i,info in pairs(self.list) do
        local button = vCreate("v_button",self):setPos(0,(i - 1) * height):setSize(maxWidth,height)
        
        function button.Draw(button,w,h)
            draw.RoundedBox(6,0,corner/2,w,h - corner,vgui.cBackgroundDarker)
            if button:IsHovered() then draw.RoundedBox(6,0,corner/2,w,h - corner,vgui.cBackgroundHover) end

            draw.SimpleText(info.name,self.font,w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end

        function button.OnClick()
            self:Remove()
            info.callback(info)
        end
    end

    self:setSize(maxWidth,#self.list * height + corner * 2)
    self:setPos(gui.MouseX(),gui.MouseY())

    self:SetZPos(1024)
    self:MakePopup()

    self:EnableDeleteSelfByOutsideClick()
end