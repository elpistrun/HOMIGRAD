local PANEL = oop.Reg("v_bind","v_button")
if not PANEL then return end

function PANEL:OnClick(key)
    if self.waitTaping then return end

    self.waitTaping = true
    self.text = "PRESS ANY KEY"

    input.StartKeyTrapping()
end

function PANEL:SetValue(code)
    if code == 70 then
        self.code = nil
        self.text = "NOTHING"
    else
        self.code = code
        self.text = code and string.upper(input.GetKeyName(code)) or "NOTHING"
    end
end

PANEL:Event_Add("Think","Key",function(self)
    if not self.waitTaping then return end

    local code = input.CheckKeyTrapping()
    if not code then return end

    self.waitTaping = nil

    self:SetValue(code)
    self:OnValue(code)
end)

PANEL.initDrawStyle = "white"
PANEL.corner = 8

local white = Color(255,255,255,13)
PANEL:SetDrawStyle("white",{
    font = "H.18",
    Draw = function(self,w,h)
        local corner = self.corner
        
        white.a = self.waitTaping and 8 or (self:IsHovered() and 20) or 13
        
        draw.RoundedBox(h - corner * 2,corner,corner,w - corner * 2,h - corner * 2,white)
        self:DrawText(w,h)
    end
})