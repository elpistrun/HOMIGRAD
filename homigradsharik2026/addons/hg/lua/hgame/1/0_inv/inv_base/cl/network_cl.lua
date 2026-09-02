local INV = oop.Get("inv_base")
if not INV then return end

INV:Event_Add("Sync","Slots",function(self,pkg)
    local slots = pkg.slots
    if not slots then return end
 
    if self:ChangeSlots(#slots,#slots[1]) then
        self:OnChangeSlots()
    end

    local selfSlots = self.slots

    for x = 1,#slots do
        for y = 1,#slots[x] do
            local slot = selfSlots[x][y]

            local listItems = slot.list
            local newListItems = slots[x][y]

            for depth,item in pairs(listItems) do
                if not newListItems[depth] then
                    listItems[depth] = nil

                    if inventoryGame.SelectItem and inventoryGame.SelectItem.slot == slot then inventoryGame.SetSelectItem() end
                end
            end

            for depth,newItem in pairs(newListItems) do
                local item = listItems[depth]
                
                if not item or item.spawnname != newItem.spawnname then
                    item = {data = newItem,spawnname = newItem.spawnname,inv = self}
                    item.IsValid = inventoryGame.IsValidItem

                    newItem.spawnname = nil
                    listItems[depth] = item
                else
                    for k in pairs(item.data) do item.data[k] = nil end--пиздец
                    
                    newItem.spawnname = nil
                    for k,v in pairs(newItem) do item.data[k] = v end
                end
            
                item.x = x
                item.y = y
                item.depth = depth
            end
        end
    end
end)


INV:Event_Add("Sync","Parent",function(self,pkg)
    if pkg.name then self.name = pkg.name end
    if pkg.auto then self.auto = pkg.auto end
    
    if pkg.parentEntIndex == nil then return end

    if IsValid(self.parent) then
        self.parent.invListIndex = self.parent.invListIndex or {}
        self.parent.invListIndex[self] = nil
    end

    self.parentEntIndex = pkg.parentEntIndex
    self.parent = EntityCoroutine(self.parentEntIndex,TickInterval() * 1.5)
    
    if IsValid(self.parent) then
        self.parent.invListIndex = self.parent.invListIndex or {}
        self.parent.invListIndex[self] = true
    end
end,-1)

INV:Event_Add("Sync","Update Item",function(self,pkg)
    if not pkg.x then return end

    local slot = self.slots[pkg.x][pkg.y]
    slot.wait = nil

    local newItem = pkg.item

    if not newItem then
        local delItem = slot.list[pkg.depth]
        slot.list[pkg.depth] = nil

        if inventoryGame.SelectItem and inventoryGame.SelectItem == delItem then inventoryGame.SetSelectItem() end
    else
        local depth = pkg.depth
        local list = slot.list
        local item = list[depth]
        
        if item then
            for k in pairs(item.data) do item.data[k] = nil end
            for k,v in pairs(newItem) do item.data[k] = v end
        else
            item = {data = newItem,spawnname = newItem.spawnname,inv = self,x = pkg.x,y = pkg.y}
            newItem.spawnname = nil
            list[depth] = item
        end
    end
end)

function INV:Close()
    local id = self.id

    coroutine.wrap(function()
        inventoryGame.SendClose(id)
    end)()

    self:Remove()
end