local PANEL = oop.Reg("v_panel","lib_event",true)
if not PANEL then return INCLUDE_BREAK end

PANEL.Base = "Panel"

vgui.Panels = vgui.Panels or {}
local Panels = vgui.Panels

vgui.CreatePanels = vgui.CreatePanels or {}
local CreatePanels = vgui.CreatePanels

concommand.Add("hg_vgui_removeall",function()
    for panel in pairs(CreatePanels) do
        if IsValid(panel) then panel:Remove() end

        CreatePanels[panel] = nil
    end
end)

PANEL:Event_Add("Construct","register",function(class)
    local content = class[1]
    if content.NonRegisterGMOD or class.NonRegisterGMOD then return end

    Panels[content.ClassName] = class

    for panel in pairs(CreatePanels) do
        if not IsValid(panel) then CreatePanels[panel] = nil continue end
        if panel.ClassName ~= content.ClassName then continue end

        util.tableLink(panel,content)

        panel:Event_Call("Construct Object",tbl)
    end
end)

function oop.CreatePanel(class,parent)
    local object = Panels[class]
    if not object then error("invalid object '" .. class .. "'") end

    local content = object[1]
    content = util.tableCopy(content)

    local func = content.FunctionCreate
    local panel

    if func then
        panel = func(content,parent)
    else
        panel = vgui.CreateFromTable(content,parent,class)--wtf?
    end

    CreatePanels[panel] = true

    return panel
end

vCreate = oop.CreatePanel

function PANEL:Init()
    self.oldHovered = false
    self.oldDown = false

    self:Event_Call("Init")
end

PANEL:Event_Add("Init","Main",function(self)
    if self.OnInit then self:OnInit() end
end)

function PANEL:Think()
    local hovered = self:IsHovered()

    if hovered ~= self.oldHovered then
        self.oldHovered = hovered
        if self.OnHovered then self:OnHovered(hover) end
        self:Event_Call("Hovered",hovered)
    end

    local down = self:IsDown()
    
    if down ~= self.oldDown then
        self.oldDown = down
        self:Event_Call("Down",down)
    end

    self:Event_Call("Think")
    if self.Step then self:Step() end
end

function vRemove(panel)
    if not IsValid(panel) then return end
    
    panel:Remove()

    if panel.removed then return end
    panel.removed = true

    if panel.OnRemove then
        panel:OnRemove()
        panel.OnRemove = nil
    end

    for i,child in pairs(panel:GetChildren()) do
        vRemove(child)
    end
end

function PANEL:OnRemove()
    self:SetVisible(false)
    self:Event_Call("Remove")
end

function PANEL:Paint(w,h)
    if self.Draw then self:Draw(w,h) end
end

function PANEL:PaintOver(w,h)
    if self.DrawOver then self:DrawOver(w,h) end
end

function PANEL:LinkPaint(panel)
    self.Paint = function(_,w,h) panel:Paint(w,h) end
    self.PaintOver = function(_,w,h) panel:PaintOver(w,h) end
end

PANEL:Event_Add("Draw","Main",function(self,w,h)
    if self.Draw then self:Draw(w,h) end
end)

hook.Add("Think","Remove Stupid Ass Shit wtf is that vase",function()
    local hover = vgui.GetHoveredPanel()
    if not IsValid(hover) then return end

    local parent = hover:GetParent()
    if not IsValid(parent) then return end
end)

function PANEL:OnChildAdded(child)
    self:Event_Call("Child Added",child)
end

function PANEL:OnChildRemoved(child)
    self:Event_Call("Child Remove",child)
end

PANEL:Event_Add("Init","hoveredIds",function(self)
    self.hoveredIds = {}
end)

function PANEL:IsHoveredOneTime(id,active)
    if active == nil then active = self:IsHovered() end

    id = id or "main"

    if active ~= self.hoveredIds[id] then
        self.hoveredIds[id] = active

        return active
    end
end


vgui.listThinkIndex = vgui.listThinkIndex or {}
local listThinkIndex = vgui.listThinkIndex

event.Add("Think","Panels",function()
    for panel in pairs(listThinkIndex) do
        if not IsValid(panel) then listThinkIndex[panel] = nil continue end

        panel:OnThink()
    end
end)

function PANEL:CreateOnThink()
    listThinkIndex[self] = true
end

PANEL:Event_Add("Init","DeleteOnRemove",function(self)
    self.deleteOnRemoveList = {}
end)

function PANEL:DeleteOnRemove(panel)
    panel.deleteOnRemoveList[self] = true
end

PANEL:Event_Add("Remove","DeleteOnRemove",function(self)
    for panel in pairs(self.deleteOnRemoveList) do
        if IsValid(panel) then vRemove(panel) end
    end
end)