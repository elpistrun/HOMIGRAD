local INV = oop.Get("inv_base")
if not INV then return end

function inventoryGame.ItemDelete(item)
    local x,y,depth = item.x,item.y,item.depth

    local inv = item.inv
    if not inv then return false end

    if IsValid(item.ent) then item.ent.invItem = nil end

    item.x = nil
    item.y = nil
    item.inv = nil
    item.depth = nil
    item.IsValid = inventoryGame.IsValidItem

    return true
end