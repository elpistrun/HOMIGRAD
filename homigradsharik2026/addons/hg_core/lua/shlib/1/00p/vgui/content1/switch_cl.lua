local PANEL = oop.Reg("v_switch","v_panel")
if not PANEL then return end

PANEL:Event_Add("Init","Main",function(self)
    self:SetMouseInputEnabled(true)

    self.on = false
    self.onLerp = 0

    self.corner = 8
end)

PANEL:Event_Add("Down","Sound",function(self,value)
    LocalPlayer():EmitSound("buttons/button15.wav",75,value and 110 or 90,value and 0.25 or 0.1)

    if value then
        self.on = not self.on

        if self.OnValue then self:OnValue(self.on) end
    end
end)

function PANEL:SetValue(value,fast)
    self.on = value
    self.onLerp = self.on and (self.invert and 0 or 1) or (self.invert and 1 or 0)
end

function PANEL:SetInvert(value)
    self.invert = value
    self.onLerp = self.on and (self.invert and 0 or 1) or (self.invert and 1 or 0)
end

local SetDrawColor,DrawRect = surface.SetDrawColor,surface.DrawRect

PANEL:SetDrawStyle("old",{
    Draw = function(self,w,h)
        SetDrawColor(15,15,15,200)
        DrawRect(0,0,w,h)
        draw.Frame(0,0,w,h,cframe2,cframe1)
    
        local set = self.on and 1 or 0
        if math.abs(set - self.onLerp) <= 0.1 then self.onLerp = set end
    
        self.onLerp = LerpFT(0.5,self.onLerp,set)
    
        SetDrawColor(Lerp(self.onLerp,255,0),Lerp(self.onLerp,0,255),0)
    
        local x,y,s = self.onLerp * w / 2,0,w / 2,h
        DrawRect(x,y,s,h)
        draw.Frame(x,y,s,h,cframe1,cframe2)
    end
})

local white = Color(245,245,235)
local corner = 0.8

PANEL:SetDrawStyle("white",{
    Draw = function(self,w,h)
        self.onLerp = LerpFTLess(0.5,self.onLerp,self.on and (self.invert and 0 or 1) or (self.invert and 1 or 0),0.05)
    
        local x,y = self.corner,self.corner

        w = w - self.corner * 2
        h = h - self.corner * 2

        draw.RoundedBox(h/2,x,y,w,h,Color(Lerp(self.onLerp,255,0),Lerp(self.onLerp,0,255),65))
        draw.RoundedBox(h/2,x + Lerp(self.onLerp,h/2 - h * corner / 2,w - h/2 - h * corner / 2),y + h/2 - h * corner / 2,h * corner,h * corner,white)
    end
})

PANEL:SetupDrawStyle("white")