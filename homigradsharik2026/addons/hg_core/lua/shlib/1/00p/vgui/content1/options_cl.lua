local PANEL = oop.Reg("v_options","v_panel")
if not PANEL then return end

vgui.optionFocus = vgui.optionFocus or nil

PANEL:Event_Add("Mouse","Focus",function(self,key,value,linkPanel)
    if not value then return end

    self:Focus()
end)

function PANEL:Focus()
    if vgui.optionFocus == self then return end

    if IsValid(vgui.optionFocus) then vgui.optionFocus:UnFocus() end

    vgui.optionFocus = self

    self.startFocus = RealTime()

    self:Update()
end

function PANEL:UnFocus()
    if vgui.optionFocus ~= self then return end

    local last = vgui.optionFocus

    vgui.optionFocus = nil

    if IsValid(last) then last:Update() end
end

function PANEL:IsFocus()
    return vgui.optionFocus == self
end

PANEL:Event_Add("Remove","Focus",function(self)
    self:UnFocus()
end)

hook.Add("VGUIMousePressed","v_options",function(key)
    if IsValid(vgui.optionFocus) and vgui.GetHoveredPanel():GetParent() ~= vgui.optionFocus.canvasPanel then
        vgui.optionFocus:UnFocus()
    end
end)

--

function PANEL:OnInit()
    self.list = {}
    
    self.curretOption = 1

    self.focusLerp = 0
    self.lerpY = 0

    self.canvasPanel = vCreate("v_panel",self)
    self.canvasPanel:SetParent(self)--здохни хуйло
        
    self.canvasPanel:ad(function(_,w,h)
        local contentW,contentH = self.canvasPanel:GetContentSize()

        self.canvasPanel.contentH = math.max(contentH or 0,h)
    end)

    self.canvasPanel.Draw = function(_,w,h)
        local x,y = self.canvasPanel:LocalToScreen(0,0)
        local xparent,yparent = self:LocalToScreen(0,0)

        y = Lerp(self.focusLerp,yparent,y)

        w = x + w
        h = Lerp(self.focusLerp,yparent + self:H(),y + h)

        if not self:IsFocus() then
            local xend,yend,wend,hend = self:GetScreenViewData()

            x = math.min(x,xend)
            y = math.min(y,yend)

            w = math.min(w,wend)
            h = math.min(h,hend)

            render.SetScissorRect(x,y,w,h,true)
        end
    end

    self.canvasPanel.DrawOver = function(_,w,h)
        render.SetScissorRect(0,0,0,0,false)
    end

    self.fontSelect = "H18"
    self.fontNotSelect = "H18"

    self:SetMouseInputEnabled(true)
end

PANEL:Event_Add("Remove","canvasPanel",function(self)
    if IsValid(self.canvasPanel) then self.canvasPanel:Remove() end
end)

PANEL:Event_Add("Child Added","CanvasPanel",function(self,panel)
    if not panel.dontParentOnCanvas then panel:SetParent(self.canvasPanel) end
end)

local override

function PANEL:Step()
    if override then return end

    local canvasPanel = self.canvasPanel
    
    local buttonSet = self.list[self.curretOption]
    if not IsValid(buttonSet) then self.curretOption = 1 return end

    self.lerpY = LerpFTLess(0.5,self.lerpY,buttonSet.y,0.05)
    self.focusLerp = LerpFTLess(18,self.focusLerp,self:IsFocus() and 1 or 0,0.05)

    local x,y = self:LocalToScreen(0,0)

    if self:IsFocus() then
        canvasPanel:setPos(x,y - self.lerpY)
        canvasPanel:setSize(self:W(),self.maxY)
    else
        canvasPanel:setPos(0,-self.lerpY)
        canvasPanel:setSize(self:W(),self.maxY)
    end

    if self:IsFocus() then
        for i = 1,9 do
            if input.IsKeyDown(_G["KEY_" .. i]) then
                override = true
                self:Set(i)
                override = nil
            end
        end
    end
end

function PANEL:Update()
    self.canvasPanel:InvalidateLayout(true)
    self.canvasPanel:SetMouseInputEnabled(self:IsFocus())

    for i,button in pairs(self.list) do
        local selected = self.curretOption == i

        button.font = selected and self.fontSelect or self.fontNotSelect
    end

    if self:IsFocus() then
        self.canvasPanel:SetZPos(128)
        self.canvasPanel:SetParent(vgui.GetWorldPanel())
    else
        self.canvasPanel:SetParent(self)
        self.canvasPanel:SetZPos(127)
    end

    self:Step()
end

local black = Color(20,20,20,245)
local corner = 4

function PANEL:Add(name,callback)
    local button = vCreate("v_button",self)
    button:ad(function(_,w,h) button:setSize(self:W(),self:H()) end)
    button.text = name; button.font = self.fontSelect
    button:LinkMouse(self,true)
    
    local textSmall,textBig

    button:ad(function(_,w,h)
        textSmall = markup.Parse("<font=" .. self.fontSelect .. ">" .. name .. "</font>",self:W())
        textBig = markup.Parse("<font=" .. self.fontNotSelect .. ">" .. name .. "</font>",self:W())
    end)

    function button.Draw(_,w,h)
        black.a = Lerp(self.focusLerp,100,255)

        local selected = self.curretOption == button.id

        draw.RoundedBox(h/2,0,corner,w,h - corner * 2,black)
        
        local text = (selected and textBig or textSmall)
        text:Draw(w/2,h/2,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local id = #self.list + 1
    button.id = id
    self.list[id] = button

    local y = 0

    for i,button in pairs(self.list) do
        local Y = y
        button:setPos(0,Y)
        y = y + button:H()
    end

    self.maxY = y

    button.OnClick = function()
        self:Set(id)
    end

    button.callback = callback

    timer.Create(tostring(self),0,1,function()
        if IsValid(self) then self:Update() end
    end)

    return button
end

function PANEL:Set(id,fast)
    if id and not self.list[id] then return end

    if self.curretOption == id then return end
    self.curretOption = id

    self.startOption = RealTime()
    
    self:Update()

    if not fast then
        if self.list[id].callback then self.list[id].callback() end
    end

    if self.OnSet then self:OnSet(id,self.list[id].text) end

    if fast then self.lerpY = self.list[id].y end
end

function PANEL:DrawOver(w,h)
    surface.SetDrawColor(180,180,180,128)
    draw.GradientRight(0,0,w / 2,1)
    draw.GradientLeft(w / 2,0,w / 2,1)

    surface.SetDrawColor(180,180,180,128)
    draw.GradientRight(0,h - 1,w / 2,1)
    draw.GradientLeft(w / 2,h - 1,w / 2,1)
end