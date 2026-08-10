local INV = oop.Get("inv_base")
if not INV then return end

function INV:GetSize()
    return #self.slots,#self.slots[#self.slots]
end

function INV:GetW() return #self.slots end
function INV:GetH() return #self.slots[#self.slots]end

function INV:GetSlot(x,y)
    local slot = self.slots[x]
    if not slot then return false,"invalid slot" end

    slot = slot[y]
    if not slot then return false,"invalid slot" end

    return slot
end

function INV:GetItem(x,y,depth)
    local slot,err = self:GetSlot(x,y)
    if not slot then return false,err end

    return slot.list[depth or 1]
end

function INV:GetAllItems()
    local list = {}

    for x = 1,#self.slots do
        for y = 1,#self.slots[x] do
            for id,item in pairs(self.slots[x][y].list) do
                list[#list + 1] = item
            end
        end
    end

    return list
end

function INV:GetItemTable(item)
    return item and GetClassFromName(item.spawnname)
end

function INV:FindItemByEntity(ent)
    for x = 1,#self.slots do
        for y = 1,#self.slots[x] do
            for id,item in pairs(self.slots[x][y].list) do
                if item.ent == ent then return item,self.slots[x][y] end
            end
        end
    end
end

inventoryGame.IsValidItem = function(self) return IsValid(self.inv) and self.x and self.y and self.depth and self.inv.slots[self.x][self.y].list[self.depth] == self or false end