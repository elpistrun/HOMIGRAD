local PANEL = oop.Reg("v_slider","v_panel")
if not PANEL then return end

function PANEL:OnInit()
    self.startTimeChange = 0
    
    self.value = 0
    self.oldValue = 0

    self.maxValue = 1
    self.minValue = 0
    self.round = 10
    
    local butt = oop.CreatePanel("v_button",self)
    self.knob = butt
    function butt.Paint(butt,w,h)
        self:DrawSlider(w,h)
    end

    butt:ad(function(self,w,h)
        self:setSize(15 * ScreenSize,15 * ScreenSize)
    end)

    function butt.Update()
        local value = self:GetKValue(self:GetValue())
        
        self.knob:setPos(self:GetCorner() - self.knob:W() / 2 + (self:GetSlideW()) * value,self:H() / 2 - self.knob:H() / 2)
    end

    function butt:GetDisabled() return false end

    function butt.OnMouse(_,key,value)
        self.grab = value
    end

    function self:OnMouse(key,value)
        self.grab = value
    end

    self.textW = 50

    self:SetTextEntry(true)

    butt:Update()
end

function PANEL:SetTextEntry(value)
    if IsValid(self.textEntry) then self.textEntry:Remove() end

    if value then
        local textEntry = oop.CreatePanel("v_textentry",self):ad(function(textEntry,w,h)
            textEntry:setSize(self.textW,h / 2):setPos(w - textEntry:W() - self:GetCorner(),h / 2 - textEntry:H() / 2)
        end)
        self.textEntry = textEntry

        function textEntry.OnValueChange(_,value)
            if self.override then return end

            self:SetKValue(self:GetKValue(tonumber(value or 0) or 0),true)
        end
    end
end

function PANEL:GetCorner()
    return self:H() / 1.5 * ScreenSize
end

function PANEL:GetSlideW()
    return self:W() - self:GetCorner() * 2 - (IsValid(self.textEntry) and self.textEntry:W() or 0) - self:GetCorner()
end

local SetDrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect

function PANEL:Paint(w,h)
    SetDrawColor(255,255,255,30)
    DrawRect(self:GetCorner(),h / 2,self:GetSlideW(),1)
end

PANEL:Event_Add("Think","Main",function(self)
    if self.grab then
        local x,y = self:LocalToScreen(self:GetCorner(),0)
        self:SetKValue(math.Clamp((mousex - x) / self:GetSlideW(),0,1),true)
    end

    self.knob:Update()
end)

function PANEL:SetMax(max)
    local value = self:GetValue()

    self.maxValue = max

    self:SetValue(value)
end

function PANEL:SetMin(min)
    local value = self:GetValue()

    self.minValue = min

    self:SetValue(value)
end

function PANEL:SetClamp(min,max)
    local value = self:GetValue()

    self.minValue = min
    self.maxValue = max
    
    self:SetValue(value)
end

function PANEL:GetValue(value)
    local value = Lerp(value or self.value,self.minValue,self.maxValue)
    
    if self.round then value = math.Round(value * self.round) / self.round end

    value = math.Clamp(value,self.minValue,self.maxValue)
    
    return value
end

function PANEL:SetValue(value)
    self:SetKValue(self:GetKValue(value),false)
end

function PANEL:GetKValue(value) return math.Clamp((value - self.minValue) / (self.maxValue - self.minValue),0,1) end

local delay = 0

function PANEL:SetKValue(value,callEvent)
    self.value = value

    local value = self:GetValue()

    if callEvent and value ~= self.oldValue then
        self.oldValue = value

        if self.OnValue then self:OnValue(value) end

        local time = RealTime()
        self.startTimeChange = time

        if delay <= time then
            delay = time + math.Rand(0.04,0.05)
            
            LocalPlayer():EmitSound("homigrad/vgui/csgo_ui_contract_type" .. math.random(1,10) .. ".wav",75,math.random(99,101),0.15)
        end
    end

    self.knob:Update()

    if IsValid(self.textEntry) then
        self.override = true
        self.textEntry:SetValue(self:GetValue())
        self.override = nil
    end

    self.oldValue = value
end

function PANEL:DrawSlider(w,h)
    local Normal = GWEN.CreateTextureNormal( 416, 32,	15, 15 )
    local Hover	= GWEN.CreateTextureNormal( 416, 32+16, 15, 15 )
    local Down = GWEN.CreateTextureNormal( 416, 32+32, 15, 15 )
    local Disabled = GWEN.CreateTextureNormal( 416, 32+48, 15, 15 )

    local hover = (self:IsDown() and -2) or (self:IsHovered() and 2) or 0
    
    local x,y,s = 0,0,h + hover

    x = w / 2 - s / 2
    y = h / 2 - s / 2

    if self:IsDown() then
        Disabled(x,y,s,s)
    elseif self:IsHovered() then
        Hover(x,y,s,s)
    else
        Normal(x,y,w,s)
    end
end