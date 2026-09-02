inventoryGame:Event_Add("PanelConstruct","Local Inventory",function(inv,panel)
    if inv.ClassName != "inv_player" or inv.parent != LocalPlayer() then return end

    local slotSize = inventoryGame.SlotSize
    local invW,invH = inv:GetSize()

    panel:setSize(inventoryGame.SlotSize * invW,inventoryGame.SlotSize * invH)
    
    panel:CreateOnThink()

    function panel:OnThink()
        self:setPos(ScrW() / 2 - self:W()/2,ScrH() - self:H() + self:H() * (1 - inventoryGame.InterfaceAnim))
    end

    for x = 1,invW do
        for y = 1,invH do
            local slot = inv:CreatePanelSlot(x,y,panel)
            slot:setSize(slotSize,slotSize)
            slot:SetPos(slotSize * (x - 1),slotSize * (y - 1))
        end
    end

    inventoryGame.local_inv = inv

    return true
end)

inventoryGame:Event_Add("PanelConstruct","Local Dumping",function(inv,panel)
    if inv.ClassName != "inv_dump" or inv.parent != LocalPlayer() then return end

    local slotSize = inventoryGame.SlotSize
    local invW,invH = inv:GetSize()

    panel:setSize(inventoryGame.SlotSize * invW,inventoryGame.SlotSize * invH)
    
    panel:CreateOnThink()

    function panel:OnThink()
        local panelInv = inventoryGame.panels[inventoryGame.local_inv]

        local x = ScrW() / 2

        if IsValid(panelInv) then x = panelInv.x + panelInv:W() + slotSize / 6 end

        self:setPos(x,ScrH() - self:H() + self:H() * (1 - inventoryGame.InterfaceAnim))
    end

    function panel:Draw(w,h)
        DisableClipping(true)
        draw.SimpleText(inv.name or inv.ClassName,"HS.18",w/2,-slotSize/3,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        DisableClipping(false)
    end

    for x = 1,invW do
        for y = 1,invH do
            local slot = inv:CreatePanelSlot(x,y,panel)
            slot:setSize(slotSize,slotSize)
            slot:SetPos(slotSize * (x - 1),slotSize * (y - 1))
        end
    end

    inventoryGame.local_inv_dump = inv

    return true
end)

inventoryGame:Event_Add("PanelConstruct","Local Backpack",function(inv,panel)
    if inv.ClassName != "inv_backpack" or inv.parent != LocalPlayer() then return end

    local slotSize = inventoryGame.SlotSize
    local invW,invH = inv:GetSize()

    panel:setSize(inventoryGame.SlotSize * invW,inventoryGame.SlotSize * invH)
    
    panel:CreateOnThink()

    function panel:OnThink()
        local panelInv = inventoryGame.panels[inventoryGame.local_inv]
        local panelDump = inventoryGame.panels[inventoryGame.local_inv_dump]

        local x = ScrW() / 2

        if IsValid(panelInv) then x = panelInv.x + panelInv:W() + slotSize / 6 end
        if IsValid(panelDump) then x = panelDump.x + panelDump:W() + slotSize / 6 end

        self:setPos(x,ScrH() - self:H() + self:H() * (1 - inventoryGame.InterfaceAnim))
    end

    function panel:Draw(w,h)
        DisableClipping(true)
        draw.SimpleText(inv.name or inv.ClassName,"HS.18",w/2,-slotSize/3,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        DisableClipping(false)
    end
    
    for x = 1,invW do
        for y = 1,invH do
            local slot = inv:CreatePanelSlot(x,y,panel)
            slot:setSize(slotSize,slotSize)
            slot:SetPos(slotSize * (x - 1),slotSize * (y - 1))
        end
    end

    inventoryGame.local_inv_backpack = inv

    return true
end)

inventoryGame:Event_Add("PanelConstruct","Armor Inventory",function(inv,panel)
    if inv.ClassName != "inv_armor" or inv.parent != LocalPlayer() then return end

    inventoryGame.local_inv_armor = inv

    return true
end)

inventoryGame.RecounstructPanels()