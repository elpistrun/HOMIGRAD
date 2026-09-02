local INV = oop.Get("inv_base")
if not INV then return end

INV:Event_Add("Init","Panel Construct",function(self)
    timer.Simple(0,function() if IsValid(self) then self:PanelConstruct() end end)--ждём всех пакетов о открытии инвентарей
end)

INV:Event_Add("Construct Object","Panel Construct",function(self)
    timer.Create("inv_base:PanelConstruct",0,1,function() self:PanelConstruct() end)
end)

--[[function INV:UpdateUI()
    if IsValid(self.panel) then
        if self.panel.UpdateFromInventory then self.panel:UpdateFromInventory(pkg) end
    end
    
    local w,h = self:GetSize()

    for x = 1,w do
        for y = 1,h do
            local panelSlot = self.slots[x][y].panel

            if IsValid(panelSlot) and panelSlot.UpdateFromInventory then panelSlot:UpdateFromInventory(pkg) end
        end
    end
end

INV:Event_Add("Sync","Update",function(self,pkg)
    self:UpdateUI()
end,3)]]--

inventoryGame.panels = inventoryGame.panels or {}
local panelIndex = inventoryGame.panels

function INV:PanelConstruct()--вызывается при создании, либо обновлении кода
    local panel = panelIndex[self]

    if IsValid(panel) then
        panel.dontCallPanelConstruct = true
        vRemove(panel)
    end

    panel = vCreate("v_panel")
    panelIndex[self] = panel

    panel.inv = self

    self.panel = panel

    panel:Event_Add("Remove","Inv",function()
        if not IsValid(self) or panel.dontCallPanelConstruct then return end
        
        self:PanelConstruct()
    end,100)

    self:OnPanelCreate(panel)

    if inventoryGame:Event_Call("PanelConstruct",self,panel) == true then--нужно поставить в интерфейс
        panel:SetVisible(true)
        if panel.OnThink then panel:OnThink() end
    else
        panel:SetVisible(false)
    end
end

INV:Event_Add("Remove","Panel",function(self)
    if not IsValid(self.panel) then return end

    self.panel.dontCallPanelConstruct = true

    if self.panel.OnClose then
        self.panel:OnClose()
    else
        vRemove(self.panel)
    end
end)

function INV:OnChangeSlots()
    if IsValid(self.panel) then self.panel:InvalidateLayout(true) end
end

function INV:OnPanelCreate(panel)
    
end

inventoryGame.RecounstructPanels = function()--FOR DEV
    if not Initialize then return end

    for i,inv in pairs(inventoryGame.list) do
        inv:PanelConstruct()
    end
end

event.Add("Screen Size","Inventory Panels",function()
    inventoryGame.RecounstructPanels()
end,10)

function INV:CreatePanelSlot(x,y,panel)
    local slot = oop.CreatePanel("v_inv_slot",panel)
    slot:SetInventory(self,x,y)

    if self.OnCreateSlot then self:OnCreateSlot(slot) end

    return slot
end

function INV:SetWait(slot,delay)
    if not delay then
        slot.wait = nil
        slot.waitDelay = nil
    else
        if delay == 0 then
            slot.wait = 0
        else
            slot.wait = RealTime()
            slot.waitDelay = delay
        end
    end
end

inventoryGame.RecounstructPanels()