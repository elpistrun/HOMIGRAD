inventoryGame.SyncItem = inventoryGame.SyncItem or function(item)
    if not item or not IsValid(item.inv) then return false end

    if item.inv.Sync then
        item.inv:Sync()
        return true
    end

    return false
end

inventoryGame.SyncItemByEntity = inventoryGame.SyncItemByEntity or function(ent)
    if not IsValid(ent) then return false end

    for _,inv in pairs(inventoryGame.list or {}) do
        if not IsValid(inv) or not inv.FindItemByEntity then continue end

        local item = inv:FindItemByEntity(ent)
        if item then return inventoryGame.SyncItem(item) end
    end

    return false
end
