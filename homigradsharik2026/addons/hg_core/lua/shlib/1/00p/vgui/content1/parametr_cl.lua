local PANEL = oop.Reg("v_parametr","v_button")
if not PANEL then return end

function PANEL:GetText() return "" end

function VguiCreateBlackScreen(id)
    local start = RealTime()
    id = id or ""
    
    local VguiBlackScreen = _G["VguiBlackScreen" .. id]
    if IsValid(VguiBlackScreen) then VguiBlackScreen:Remove() end
    local frame = oop.CreatePanel("v_frame"):setSize(ScrW(),ScrH())
    frame:MakePopup()
    _G["VguiBlackScreen" .. id] = frame

    function frame:Close()
        if self.close then return end 
        self.close = RealTime()
    end

    function frame:GetK()
        if self.close then
            return math.max(self.close + 0.1 - RealTime(),0) / 0.1
        else
            return 1 - math.max(start + 0.1 - RealTime(),0) / 0.1
        end
    end

    function frame:Draw(w,h)
        local k = self:GetK()
        surface.SetAlphaMultiplier(k)

        surface.SetDrawColor(0,0,0,200)
        surface.DrawRect(0,0,w,h)
        DrawBlurByPanel(5,self)

        if self.DrawContent then self:DrawContent(w,h,k) end
    end
    function frame:DrawOver()
        surface.SetAlphaMultiplier(1)
    end
    function frame:Step()
        if self.close and self.close + 0.1 - RealTime() <= 0 then self:Remove() end
    end
    function frame:OnMouse() frame:Close() end

    frame:EnableDeleteSelfByOutsideClick()

    return frame
end

function VguiBlackScreenIsValid(id) return IsValid(_G["VguiBlackScreen" .. (id or "")]) end

function VParametrEdit(name,value,callback,title)
    local panel = VguiCreateBlackScreen()
    panel:MakePopup()

    panel:setSize(ScrW(),ScrH() * 0.2):setPos(0,ScrH()/2-panel:H()/2)

    local textEntry = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(w * 0.5,60):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2) end)
    textEntry:SetPaintBackground(false)
    textEntry:SetFont("HS30")
    textEntry:SetTextColor(Color(255,255,255))
    textEntry:SetCursorColor(Color(255,255,255))

    panel:Event_Add("Think","AlphaAnimation",function()
        local k = panel:GetK()
        panel:SetAlpha(255 * k)
        if k >= 1 then panel:Event_Remove("Think","AlphaAnimation") end
    end)

    function panel:Draw(w,h,k)
        surface.SetDrawColor(30,30,30)
        surface.DrawRect(0,0,w,h)

        draw.SimpleText(title or L("parametredit_settings"),"H50",w / 2,textEntry.y/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        if name then draw.SimpleText(name,"H50",w / 2,h - (h - textEntry.y - textEntry:H())/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
    end

    textEntry:SetValue(value)
    textEntry:RequestFocus()
    textEntry:SelectAllOnFocus()

    function textEntry:OnEnter()
        callback(textEntry:GetValue())
        panel:Remove()
    end
end

function VParametrAgree(title,callback,name)
    local panel = VguiCreateBlackScreen()
    panel:MakePopup()
    panel:setSize(ScrW(),ScrH() * 0.2):setPos(0,ScrH()/2-panel:H()/2)

    panel:Event_Add("Think","AlphaAnimation",function()
        local k = panel:GetK()
        panel:SetAlpha(255 * k)
        if k >= 1 then panel:Event_Remove("Think","AlphaAnimation") end
    end)

    local buttYes = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w/5,h/3.33):setPos(w/2-self:W() - h/10,h/2-self:H()/2) end)
    buttYes:SetupDrawStyle("white_gradient"); buttYes.font = "HS.45"; buttYes.text = L("yes")

    function buttYes:OnClick()
        callback()
        panel:Close()
    end

    local buttNo = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w/5,h/3.33):setPos(w/2 + h/10,h/2-self:H()/2) end)
    buttNo:SetupDrawStyle("white_gradient"); buttNo.font = "HS.45"; buttNo.text = L("no")

    function buttNo:OnClick()
        panel:Close()
    end

    function panel:Draw(w,h,k)
        surface.SetDrawColor(30,30,30)
        surface.DrawRect(0,0,w,h)

        draw.SimpleText(title or L("parametredit_settings"),"H50",w / 2,buttYes.y/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        if name then draw.SimpleText(name,"H50",w / 2,h - (h - buttYes.y - buttYes:H())/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
    end
end

function PANEL:OnClick()
    local text = self.GetTextEntry and self:GetTextEntry() or self:GetText()

    if text == "true" then text = 1 end
    if text == "false" then text = 0 end

    VParametrEdit(self.text,text,self.Callback)
end

local white = Color(255,255,255)

PANEL:Event_Add("Init","Param",function(self)
    self.color = white
end)

//

PANEL:SetDrawStyle("dark",{
    PreDraw = function(self,w,h)
        if self.Tip then self:DrawTip(self.Tip) end

        if self.isNotClickable then
            surface.SetDrawColor(0,0,0,75)
            surface.DrawRect(0,0,w,h)
            surface.SetBG("lines_d_l")
            surface.SetDrawColor(100,100,100,15)
            draw.BG(0,0,w,h)

            return
        end

        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)
        
        local color = self.color
        surface.SetDrawColor(color.r,color.g,color.b,5)
        surface.DrawRect(0,0,w,1)
        surface.DrawRect(0,h - 1,w,1)
        
        draw.SimpleText(self.text or "",self.font,h / 2,h/2,nil,nil,TEXT_ALIGN_CENTER)
        
        local size = w / 3
        surface.SetDrawColor(color.r,color.g,color.b,16)
        draw.GradientRight(w - size + 1,0,size,h)
        
        draw.SimpleText(self:GetText(),self.font,w - h / 2,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        if self:IsHovered() then surface.SetDrawColor(255,255,255,5) surface.DrawRect(0,0,w,h) end
    end,
    Draw = function(self,w,h)
        if self.tip then
            self:DrawTip(self.tip,1)
        end
    end,
    DrawOver = function(self,w,h) draw.Frame(0,0,w,h,cframe1,cframe2) end
})