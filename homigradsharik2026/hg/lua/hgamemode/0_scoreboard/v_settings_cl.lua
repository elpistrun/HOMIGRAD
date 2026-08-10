local PANEL = oop.Reg("v_settings","v_scrollpanel")
if not PANEL then return end

PANEL:Event_Add("Init","itemY",function(self)
    self.itemY = 0
    self.selectItem = nil
    self.selectItemAnchor = nil

    self.items = {}
end)

function PANEL:Add(panel)
    panel:SetParent(self)

    local Y = self.itemY
    panel:ad(function(self,w,h) self:setPos(0,Y) end)

    self.itemY = self.itemY + panel:H()

    panel:InvalidateLayout(true)

    local id = #self.items + 1
    self.items[id] = panel

    panel.id = id

    function panel.OnMouse(_,key,value)
        if panel.cantSelect or not value then return end

        self.selectItemAnchor = id

        if self.selectItem == id then return end
        self:UnFocus()
        self.selectItem = id
        panel:MouseFocus()
        self:OnFocus(self.items[id])

        self.selectItemAnchor = id
    end

    function panel.Step()
        if IsValid(vgui.optionFocus) then return end
        
        if panel.cantSelect then return end
        
        local hoverPanel = vgui.GetHoveredPanel()
        if not IsValid(hoverPanel) or not hoverPanel:HasParent(panel) then return end

        if self.selectItem == id then return end
        self:UnFocus("step")
        self.selectItem = id
        panel:MouseFocus()
        self:OnFocus(self.items[id])
    end

    function panel.UnFocus() self:UnFocus() end
    function panel.WantUnFocus(_,panel) return self:WantUnFocus(panel) end
end

function PANEL:Step()
    if self.selectItemAnchor and self.selectItem ~= self.selectItemAnchor then
        self.selectItem = self.selectItemAnchor
        self:OnFocus(self.items[self.selectItem])
    end
end

function PANEL:UnFocus(callType)
    if not callType then self.selectItemAnchor = nil end

    if not self.selectItem then return end

    local last = self.selectItem
    self.selectItem = nil

    self:OnUnFocus(last and self.items[last])
end

local white = Color(150,150,150)

function PANEL:CreateBlock(textLeft,textRight,icon)
    local panel = vCreate("v_panel",self):ad(function(self,w,h) self:setSize(w,60) end)

    function panel.Draw(_,w,h)
        panel.hovered = LerpFTLess(0.5,panel.hovered or 0,self.selectItem == panel.id and 1 or 0)

        white.a = 25 * panel.hovered
        draw.RoundedBoxEx(h/2,0,0,w,h,white,false,true,false,true)

        if self.selectItemAnchor == panel.id then
            surface.SetDrawColor(128,128,128,128)
            draw.GradientLeft(0,0,w / 2,h)
        end

        draw.SimpleText(textLeft,"H22",h/2,h/2,nil,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

        if icon then
            surface.SetDrawColor(255,255,255)
            surface.SetMaterial(icon)
            surface.DrawTexturedRectRotated(w - 250 - h/2,h/2,h/2,h/2,0)

            if textRight then draw.SimpleText(textRight,"H18",w - 250 - h/2 * 2,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER) end
        else
            if textRight then draw.SimpleText(textRight,"H18",w - 250 - h/2,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER) end
        end
    end

    return panel
end

function PANEL:AddSlider(textLeft,textRight,cvar,icon)
    local panel = self:CreateBlock(textLeft,textRight,icon)
    local slider = vCreate("v_slider",panel):ad(function(self,w,h) self:setSize(250,h):setPos(w - self:W(),0) end)

    panel.cvar = cvar

    cvar = GetConVar(cvar)

    slider:SetMax(cvar:GetMax() or 1000000)
    slider:SetMin(cvar:GetMin() or -1000000)
    slider:SetValue(cvar:GetFloat())

    function slider:OnValue(value)
        RunConsoleCommand(cvar:GetName(),value)
    end

    slider:LinkMouse(panel,true)

    self:Add(panel)

    return panel,slider
end

function PANEL:AddSwitch(textLeft,textRight,cvar,icon)
    local panel = self:CreateBlock(textLeft,textRight,icon)
    local switch = vCreate("v_switch",panel):ad(function(self,w,h) self:setSize(250,h):setPos(w - self:W(),0) end)

    switch.corner = 8

    panel.cvar = cvar

    cvar = GetConVar(cvar)

    switch:SetValue(cvar:GetBool())

    function switch:OnValue(value)
        RunConsoleCommand(cvar:GetName(),value and 1 or 0)
    end

    switch:LinkMouse(panel,true)

    self:Add(panel)

    return panel,switch
end

function PANEL:AddBind(textLeft,textRight,name,icon)
    local panel = self:CreateBlock(textLeft,textRight,icon)
    local bind = vCreate("v_bind",panel):ad(function(self,w,h) self:setSize(250,h):setPos(w - self:W(),0) end)
    bind:SetupDrawStyle("white")
    bind.corner = 8

    bind:SetValue(keyboard.GetBindCode(name))

    function bind:OnValue(code)
        RunConsoleCommand("hg_bind",name,code)
    end

    bind:LinkMouse(panel,true)

    self:Add(panel)

    return panel,bind
end

function PANEL:AddCategory(text,icon)
    local panel = self:CreateBlock(text,icon)
    panel.cantSelect = true

    function panel:Draw(w,h)
        draw.SimpleText(text,"H.25",w / 2,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        surface.SetDrawColor(255,255,255,128)
        draw.GradientLeft(0,h - 1,w,1)
    end

    self:Add(panel)

    return panel
end

function PANEL:AddOptions(textLeft,textRight,options,icon)
    local panel = self:CreateBlock(textLeft,textRight,icon)
    local options = vCreate("v_options",panel):ad(function(self,w,h) self:setSize(250,h):setPos(w - self:W(),0) end)

    options:LinkMouse(panel,true)

    self:Add(panel)

    return panel,options
end