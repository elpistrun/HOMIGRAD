local PANEL = oop.Reg("v_button","v_panel")
if not PANEL then return end

function PANEL:OnInit()
    self:SetLock(false)

    self.hovered = 0
    self.font = "H18"
end

function PANEL:DrawText(w,h)
    if self.PreDrawText then self:PreDrawText(w,h) end

    if self.text then
        draw.SimpleText(self.text,self.font,w / 2,h / 2,self.textColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end

function PANEL:ForceClick()
    if self.OnClick then self:OnClick(key) end
    self:Event_Call("Down",true)
end

PANEL:Event_Add("Mouse","Click",function(self,key,value)
    if value == false then return end

    if self.OnClick then self:OnClick(key) end

    local SoundClick = self.SoundClick
    if SoundClick then sound.EmitScreen(SoundClick.list[math.random(1,#SoundClick.list)],SoundClick.volume,SoundClick.pitch) end
end)

PANEL:Event_Add("Think","Hovered",function(self)
    self.hovered = LerpFT(0.56,self.hovered,self:IsDown() and -1 or self:IsHovered() and 1 or 0)
end)

PANEL:Event_Add("Hovered","Sound",function(self,hovered)
    local Sound = hovered and self.SoundHovered or self.SoundUnHovered
    if not Sound then return end
    
    sound.EmitScreen(Sound.list[math.random(1,#Sound.list)],Sound.volume,Sound.pitch)
end)

//

local SetDrawColor,DrawRect = surface.SetDrawColor,surface.DrawRect

PANEL:SetDrawStyle("dark",{
    PreDraw = function(self,w,h)
        SetDrawColor(25,25,25)
        DrawRect(0,0,w,h)
    
        if self.isNotClickable then
            surface.SetDrawColor(0,0,0,75)
            surface.DrawRect(0,0,w,h)
            surface.SetBG("lines_d_l")
            surface.SetDrawColor(100,100,100,15)
            draw.BG(0,0,w,h)

            return
        end

        if self:IsDown() then
            SetDrawColor(0,0,0,255)
            DrawRect(0,0,w,h)
        elseif self:IsHovered() then
            SetDrawColor(255,255,255,5)
            DrawRect(0,0,w,h)
        end
    end,
    Draw = function(self,w,h) self:DrawText(w,h) end,
    DrawOver = function(self,w,h) draw.Frame(0,0,w,h,cframe1,cframe2) end
})

local white = Color(255,255,255,5)
PANEL:SetDrawStyle("white",{
    PreDraw = function(self,w,h)
        SetDrawColor(self.backgroundColor or white)
        DrawRect(0,0,w,h)

        if self.isNotClickable then
            surface.SetBG("lines_d_l")
            surface.SetDrawColor(100,100,100,15)
            draw.BG(0,0,w,h)

            return
        end

        if self.isDownForce or self:IsDown() then
            SetDrawColor(0,0,0,5)
            DrawRect(0,0,w,h)
        elseif self:IsHovered() then
            SetDrawColor(255,255,255,5)
            DrawRect(0,0,w,h)
        end
    end,
    Draw = function(self,w,h) self:DrawText(w,h) end,
    DrawPost = function(self,w,h) draw.Frame(0,0,w,h,cframe1,cframe2) end
})

local white = Color(255,255,255,10)
PANEL:SetDrawStyle("white_gradient",{
    PreDraw = function(self,w,h)
        local hover = self.hover or 0

        SetDrawColor(self.backgroundColor or white)
        surface.DrawRect(0,0,w,h)

        //if self.isNotClickable then
            surface.SetDrawColor(100,100,100,15)
            surface.SetBG("lines_d_l")
            surface.SetDrawColor(100,100,100,15)
            draw.BG(0,0,w,h)

        //    return
        //end
        
        if self.gradientSide == "right" then
            surface.SetDrawColor(255,255,255,64)
            draw.GradientRight(w - w / (1.25 - 0.25 * hover),0,w / (1.25 - 0.25 * hover),h)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawRect(w - 2,0,2,h)
        elseif self.gradientSide == "left" then
            surface.SetDrawColor(255,255,255,64)
            draw.GradientLeft(0,0,w / (1.25 - 0.25 * hover),h)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawRect(0,0,2,h)
        elseif self.gradientSide == "bottom" then
            surface.SetDrawColor(255,255,255,64)
            local size = h / (1.25 - 0.25 * hover)
            draw.GradientDown(0,h - size + 1,w,size)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawRect(0,h - 2,w,2)
        end

        self.hover = LerpFT(0.5,hover,self:IsHovered() and 1 or 0)
    end,
    Draw = function(self,w,h)
        if self.text then draw.SimpleText(self.text,self.font,w / 2,h / 2 - ((self.hover or 0) * (h/10)),self.textColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
    end,
    DrawPost = function(self,w,h) draw.Frame(0,0,w,h,cframe1,cframe2) end
})