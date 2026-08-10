local PANEL = oop.Get("v_panel")
if not PANEL then return end

PANEL:Event_Add("Init","Fast Perform",function(self)
    self.adlist = {}
end,-1)

function PANEL:ad(func)
    self.adlist[#self.adlist + 1] = func

    local parent = self:GetParent()

    func(self,parent:GetWide(),parent:GetTall(),parent)

    return self
end

PANEL:Event_Add("Perform","ad",function(self,w,h)
    local parent = self:GetParent()

    for i,func in pairs(self.adlist) do func(self,parent:GetWide(),parent:GetTall(),parent) end--не стоит изменять размер parent'а
end)

event.Add("Screen Size","Perform Layout",function(new)
    for panel in pairs(vgui.CreatePanels) do
        if not IsValid(panel) then vgui.CreatePanels[panel] = nil continue end
        
        if panel.ConstructLayout then panel:ConstructLayout() end
    end
end)

function VGUIScreenSize()
    local panel = vgui.GetWorldPanel()

    return panel:GetWide(),panel:GetTall()
end

function PANEL:Clear()
    for i,panel in pairs(self:GetChildren()) do
        vRemove(panel)
    end
end