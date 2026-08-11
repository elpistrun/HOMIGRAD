local PANEL = oop.Get("v_panel")
if not PANEL then return end

PanelInputMouse = PanelInputMouse or {}
PanelInputKeyboard = PanelInputKeyboard or {}

PANEL:Event_Add("Init","Input",function(self)
    self.mouse = {}
    self.keyboard = {}
end,-1)

function PANEL:OnMousePressed(key,linkPanel)
    self.mouse[key] = true
    PanelInputMouse[self] = true

    if self.OnMouse then self:OnMouse(key,true,linkPanel) end
    self:Event_Call("Mouse",key,true,linkPanel)
end

function PANEL:OnMouseReleased(key,outside,linkPanel)
    local value = self.mouse[key]

    if self.OnMouseOut then self:OnMouseOut(key,outside,linkPanel) end
    self:Event_Call("MouseOut",key,outside,linkPanel)

    if not value then return end

    self.mouse[key] = nil

    if self.OnMouse then self:OnMouse(key,false,linkPanel) end
    self:Event_Call("Mouse",key,false,linkPanel)
end

--

function PANEL:OnKeyCodePressed(key)
    self.keyboard[key] = true
    PanelInputKeyboard[self] = true

    if self.OnKey then self:OnKey(key,true) end
    self:Event_Call("Key",key,true)
end

function PANEL:OnKeyCodeReleased(key,outside)
    if not self.keyboard[key] then return end
    self.keyboard[key] = nil
    
    if self.OnKey then self:OnKey(key,false) end
    self:Event_Call("Key",key,false)
end

function PANEL:OnMouseWheeled(wheel)
    --if (self.wheelDelay or 0) > RealTime() then return end
    --self.wheelDelay = RealTime() + 1 / 25
    
    if self.OnWheel then self:OnWheel(wheel) end
    self:Event_Call("Wheel",wheel)
end

hook.Add("Think","Panel Input",function()
    for panel in pairs(PanelInputMouse) do
        if not IsValid(panel) then PanelInputMouse[panel] = nil continue end

        for key in pairs(panel.mouse) do
            if not input.IsMouseDown(key) then panel:OnMouseReleased(key,true) end
        end
    end

    for panel in pairs(PanelInputKeyboard) do
        if not IsValid(panel) then PanelInputKeyboard[panel] = nil continue end

        for key in pairs(panel.keyboard) do
            if not input.IsKeyDown(key) then panel:OnKeyCodeReleased(key,true) end
        end
    end
end)

function PANEL:IsDown()
    for key in pairs(self.mouse) do return true end

    return false
end

function PANEL:GetMousePos()
    local x,y = self:LocalToScreen(0,0)

    return mousex - x,mousey - y
end

local function step(panel,x,y)
    local parent = panel:GetParent()

    if IsValid(parent) then
        return step(parent,x + panel.x,y + panel.y)
    else
        return x,y
    end
end

function PANEL:GetGlobalPos()
    return step(self,0,0)
end

function PANEL:LinkMouse(panel,backUp)
    local OnMousePressed = self.OnMousePressed

    self.OnMousePressed = function(_,key,value)
        if backUp then OnMousePressed(self,key) end
        panel:OnMousePressed(key,self)
    end

    local OnMouseReleased = self.OnMouseReleased

    self.OnMouseReleased = function(_,key,value)
        if backUp then OnMouseReleased(self,key) end
        panel:OnMouseReleased(key,nil,self)
    end

    self.OnMouseWheeled = function(_,value) panel:OnMouseWheeled(value,self) end
end

function PANEL:SetLock(value)
    if self.isNotClickable == value then return end
    self.isNotClickable = value

    if value then
        self:SetCursor("arrow")
        self:SetMouseInputEnabled(false)
    else
        self:SetMouseInputEnabled(true)
        self:SetCursor("hand")
    end
end

local list = {}

function PANEL:MouseFocus()
    list[self] = true
end

function PANEL:HasParent(parent)
    if self == parent then return true end

    local step = self:GetParent()
    if not IsValid(step) then return end

    return step:HasParent(parent)
end

hook.Add("VGUIMousePressed","Focus Panel",function(key)
    local hover = vgui.GetHoveredPanel()

    for panel in pairs(list) do
        if not IsValid(panel) then list[panel] = nil continue end

        if not IsValid(hover) or not hover:HasParent(panel) then
            if panel.WantUnFocus and panel:WantUnFocus(hover) == false then continue end
            
            panel:UnFocus()

            list[panel] = nil
        end
    end
end)

local hg_test_hovered_panel

cvars.CreateOption("hg_test_hovered_panel","0",function(value)
    hg_test_hovered_panel = tonumber(value or 0) > 0

    if hg_test_hovered_panel then
        hook.Add("DrawOverlay","TEST HOVERED PANEL",function()
            local panel = vgui.GetHoveredPanel()
            if not IsValid(panel) then return end

            local x,y = panel:LocalToScreen(0,0)

            surface.SetDrawColor(255,0,0,125)
            surface.DrawRect(x,y,panel:GetWide(),panel:GetTall())

            local x2,y2 = panel:LocalToScreen(panel:GetWide(),panel:GetTall())

            local parents = {}
            local p = panel
            for i = 1,12 do
                if not IsValid(p) then parents[#parents + 1] = "ROOT" break end
                parents[#parents + 1] = p.GetClassName and p:GetClassName() or p.ClassName or "?"
                p = p:GetParent()
            end

            surface.SetDrawColor(255,255,255)
            draw.SimpleText("class: " .. (panel:GetClassName() or panel.ClassName or "?") .. " xy: " .. math.Round(x) .. "," .. math.Round(y) .. " wh: " .. panel:GetWide() .. "x" .. panel:GetTall() .. " parents: " .. table.concat(parents," > "),"H.14",x + 4,y + 4,Color(255,255,0),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
        end)
    else
        hook.Remove("DrawOverlay","TEST HOVERED PANEL")
    end
end,0,1)

function PANEL:EnableDeleteSelfByOutsideClick()
    local id = tostring(self)

    hook.Add("VGUIMousePressed",id,function(pnl,code)
        if not pnl:HasParent(self) then self:Remove() end
    end)

    self:Event_Add("Remove","EnableDeleteSelfByOutsideClick",function(self) hook.Remove("VGUIMousePressed",id) end)
end