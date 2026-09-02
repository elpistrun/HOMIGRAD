local ENTITY = FindMetaTable("Entity")

ENTITY.GetAllItems = function(self)
    local list = {}

    for inv in pairs(inventoryGame.GetSafeInvsFromEntity(self)) do
        for i,item in pairs(inv:GetAllItems()) do
            list[#list + 1] = item
        end
    end

    return list
end

ENTITY.GetAllAutoItems = function(self,ent)
    local list = {}

    for inv in pairs(inventoryGame.GetSafeInvsFromEntity(self)) do
        if not inv.auto then continue end

        for i,item in pairs(inv:GetAllItems()) do
            list[#list + 1] = item
        end
    end

    return list
end

ENTITY.InvSync = function(self)
    for inv in pairs(inventoryGame.GetSafeInvsFromEntity(self)) do
        inv:Sync()
    end
end