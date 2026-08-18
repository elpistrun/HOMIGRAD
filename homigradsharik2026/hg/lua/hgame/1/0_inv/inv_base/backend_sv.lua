-- Authoritative backend for the gameplay inventory shown on scoreboard page 2.
util.AddNetworkString("hg_inventory_sync")

local function ItemPackage(item)
    local data = table.Copy(item.data or {})
    data.spawnname = item.spawnname
    return data
end

local function SlotsPackage(inv)
    local result = {}
    local w,h = inv:GetSize()
    for x = 1,w do
        result[x] = {}
        for y = 1,h do
            result[x][y] = {}
            for depth,item in ipairs(inv.slots[x][y].list) do
                result[x][y][depth] = ItemPackage(item)
            end
        end
    end
    return result
end

local function SendInventory(inv,ply,create)
    if not IsValid(inv) or not IsValid(ply) then return end
    net.Start("hg_inventory_sync")
        net.WriteTable({
            id = inv.id,
            class = create and inv.ClassName or nil,
            slots = SlotsPackage(inv),
            parentEntIndex = IsValid(inv.parent) and inv.parent:EntIndex() or -1,
            name = inv.name,
            auto = inv.auto
        })
    net.Send(ply)
end

local function SendRemove(inv,ply)
    if not IsValid(inv) or not IsValid(ply) then return end
    net.Start("hg_inventory_sync")
        net.WriteTable({id = inv.id,remove = true})
    net.Send(ply)
end

local function CanAccess(ply,inv)
    if not IsValid(inv) then return false end
    if inv.parent == ply then return true end
    if not IsValid(inv.parent) then return false end
    return ply:EyePos():DistToSqr(inv.parent:NearestPoint(ply:EyePos())) <= 14400
end

local function EmptySlot(inv)
    local w,h = inv:GetSize()
    for y = 1,h do
        for x = 1,w do
            if not inv.slots[x][y].list[1] then return inv.slots[x][y] end
        end
    end
end

local function RemoveItem(item)
    if not item or not IsValid(item.inv) then return end
    local slot = item.inv:GetSlot(item.x,item.y)
    if not slot then return end
    table.remove(slot.list,item.depth or 1)
    for depth,other in ipairs(slot.list) do other.depth = depth end
    item.inv,item.x,item.y,item.depth = nil,nil,nil,nil
end

local function InsertItem(item,slot)
    if not item or not slot then return false end
    slot.list[#slot.list + 1] = item
    item.inv,item.x,item.y,item.depth = slot.inv,slot.x,slot.y,#slot.list
    return true
end

local function IsPlayerInventory(inv,ply)
    return IsValid(inv) and inv.parent == ply
end

local function RestoreWorldEntity(ent,pos,ply)
    ent:SetNoDraw(false)
    ent:SetNotSolid(false)
    ent:SetPos(pos)
    if ent:GetMoveType() == MOVETYPE_NONE then ent:SetMoveType(MOVETYPE_VPHYSICS) end
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        -- Push the weapon away from the player so it doesn't fall underneath
        if IsValid(ply) then
            local fwd = ply:GetAimVector()
            phys:SetVelocity(fwd * 200 + Vector(0,0,100))
        end
    end
end

local function SpawnItemEntity(item,pos)
    if IsValid(item.ent) then
        RestoreWorldEntity(item.ent,pos)
        return item.ent
    end

    local ent = ents.Create(item.spawnname or "")
    if not IsValid(ent) then return nil,"item entity cannot be created" end
    ent:SetPos(pos)
    ent:Spawn()
    item.ent = ent
    return ent
end

local function GiveItemToPlayer(item,ply)
    if IsValid(item.ent) and item.ent:IsWeapon() then
        if item.ent:GetOwner() == ply then return true end
        item.ent:SetNoDraw(false)
        item.ent:SetNotSolid(false)
        ply:PickupWeapon(item.ent)
        -- Return true even if PickupWeapon was blocked (e.g. weapon limit);
        -- the item entity stays valid and the inventory item keeps its reference.
        return true
    end

    if weapons.GetStored(item.spawnname or "") then
        local wep = ply:Give(item.spawnname,true)
        if not IsValid(wep) then return false,"weapon cannot be given" end
        item.ent = wep
    end

    return true
end

local function PutItemIntoContainer(item,ply,container)
    if not IsValid(item.ent) then return true end
    if item.ent:IsWeapon() and item.ent:GetOwner() == ply then ply:DropWeapon(item.ent) end

    item.ent:SetPos(IsValid(container.parent) and container.parent:GetPos() or ply:GetPos())
    item.ent:SetNoDraw(true)
    item.ent:SetNotSolid(true)
    item.ent:SetMoveType(MOVETYPE_NONE)
    return true
end

local function TransferEntityState(item,from,target,ply)
    local fromPlayer = IsPlayerInventory(from,ply)
    local targetPlayer = IsPlayerInventory(target,ply)
    if fromPlayer == targetPlayer then return true end
    if targetPlayer then return GiveItemToPlayer(item,ply) end
    return PutItemIntoContainer(item,ply,target)
end


-- Public server helpers used by lootboxes and other world containers.
inventoryGame.ServerSendInventory = SendInventory
inventoryGame.ServerEmptySlot = EmptySlot
inventoryGame.ServerInsertItem = InsertItem

function inventoryGame.CreateWorldInventory(parent,class,w,h,name)
    if not IsValid(parent) then return end

    local inv = customEnts.Create(class or "inv_storage")
    inv.parent = parent
    inv.name = name
    inv.auto = false
    inv.viewers = {}
    inv:ChangeSlots(w,h)
    inv:Spawn()

    parent.invListIndex = parent.invListIndex or {}
    parent.invListIndex[inv] = true

    function inv:AddEnt(item)
        local slot = EmptySlot(self)
        if not slot then return false end
        return InsertItem(item,slot)
    end

    function inv:Sync(target)
        if IsValid(target) then
            self.viewers[target] = true
            SendInventory(self,target,false)
            return
        end

        for ply in pairs(self.viewers) do
            if IsValid(ply) and CanAccess(ply,self) then
                SendInventory(self,ply,false)
            else
                self.viewers[ply] = nil
            end
        end
    end

    return inv
end

local function CreateInventory(ply,class,w,h,name,field)
    local old = ply[field]
    if IsValid(old) then
        if old:ChangeSlots(w,h) and old.Sync then old:Sync() end
        return old
    end

    local inv = customEnts.Create(class)
    inv.parent = ply
    inv.name = name
    inv.auto = true
    inv:ChangeSlots(w,h)
    inv:Spawn()

    ply[field] = inv
    ply.invListIndex = ply.invListIndex or {}
    ply.invListIndex[inv] = true

    function inv:Sync(target)
        SendInventory(self,target or self.parent,false)
    end

    SendInventory(inv,ply,true)
    return inv
end

local ignoredWeapons = {
    weapon_hands = true,
    weapon_physgun = true,
    gmod_tool = true,
    gmod_camera = true
}

-- Weapon limit system
-- "pistol" = max 1 pistol total
-- "secondary" = max 1 secondary weapon total (rifles, SMGs, shotguns, etc.)
-- "melee" = max 1 of each melee class (can have knife + bat but not 2 knives)
local function GetWeaponLimitType(wep)
    return wep.weaponLimitType or nil
end

local function CanPickupWeapon(ply,wep)
    local limitType = GetWeaponLimitType(wep)
    if not limitType then return true end
    
    local inv = ply.inv
    if not IsValid(inv) then return true end
    
    local wepClass = wep:GetClass()
    
    for x = 1,#inv.slots do
        for y = 1,#inv.slots[x] do
            local item = inv.slots[x][y].list[1]
            if item then
                if limitType == "melee" then
                    -- Melee: block only same class
                    if item.spawnname == wepClass then return false end
                else
                    -- Pistol/secondary: block any of same limit type
                    local classData = GetClassFromName(item.spawnname)
                    local existingType = classData and classData.weaponLimitType
                    if existingType == limitType then return false end
                end
            end
        end
    end
    
    return true
end

local function DropItemWorld(item,ply)
    local dropPos = ply:EyePos() + ply:GetAimVector() * 55 + Vector(0,0,10)
    if IsValid(item.ent) and item.ent:IsWeapon() and item.ent:GetOwner() == ply then
        ply:DropWeapon(item.ent)
        RestoreWorldEntity(item.ent,dropPos,ply)
    elseif IsValid(item.ent) then
        RestoreWorldEntity(item.ent,dropPos,ply)
    else
        SpawnItemEntity(item,dropPos)
    end
end

local function AddWeapon(ply,wep)
    if not IsValid(ply) or not IsValid(wep) or ignoredWeapons[wep:GetClass()] then return end
    local inv = ply.inv
    if not IsValid(inv) then return end

    -- Already tracked by this entity
    if inv:FindItemByEntity(wep) then return end

    local wepClass = wep:GetClass()

    -- Check if an inventory item already exists for this weapon class
    -- (e.g. player had the weapon as data-only from a container transfer)
    local existingItem
    for x = 1,#inv.slots do
        for y = 1,#inv.slots[x] do
            local item = inv.slots[x][y].list[1]
            if item and item.spawnname == wepClass then
                existingItem = item
                break
            end
        end
        if existingItem then break end
    end

    if existingItem then
        if IsValid(existingItem.ent) then
            -- Existing item already has a valid entity; discard the duplicate
            wep:Remove()
            return
        end
        -- Existing item has no entity (from container); link the new entity
        existingItem.ent = wep
        inv:Sync()
        return
    end

    -- If weapon limit is exceeded, drop the conflicting weapon first
    if not CanPickupWeapon(ply,wep) then
        local limitType = GetWeaponLimitType(wep)
        
        for x = 1,#inv.slots do
            for y = 1,#inv.slots[x] do
                local item = inv.slots[x][y].list[1]
                if item then
                    local shouldRemove = false
                    if limitType == "melee" then
                        shouldRemove = item.spawnname == wepClass
                    else
                        local classData = GetClassFromName(item.spawnname)
                        local existingType = classData and classData.weaponLimitType
                        shouldRemove = existingType == limitType
                    end
                    
                    if shouldRemove then
                        DropItemWorld(item,ply)
                        RemoveItem(item)
                        inv:Sync()
                        break
                    end
                end
            end
        end
    end
    
    local slot = EmptySlot(inv)
    if not slot then return end

    InsertItem({spawnname = wepClass,data = {},ent = wep},slot)
    inv:Sync()
end

local function AddArmor(ply,armorName,data)
    if not IsValid(ply) or not armorName then return end
    local inv = ply.invArmor
    if not IsValid(inv) then return end
    
    -- Check if armor is already in inventory
    for x = 1,#inv.slots do
        for y = 1,#inv.slots[x] do
            local list = inv.slots[x][y].list
            for depth,item in ipairs(list) do
                if item.data and item.data.armorName == armorName then return end
            end
        end
    end
    
    -- Get armor position in inventory
    local x,y
    if inv.GetArmorPos then
        x,y = inv:GetArmorPos(armorName)
    end
    if not x then
        -- Fallback to empty slot if position not found
        local slot = EmptySlot(inv)
        if not slot then return end
        x,y = slot.x,slot.y
    end
    
    local slot = inv.slots[x][y]
    if slot.list[1] then return end -- Slot already occupied
    
    InsertItem({spawnname = "item_armor",data = {armorName = armorName,integrity = data and data.integrity or 1}},slot)
    inv:Sync()
end

local function SetupPlayer(ply)
    if not IsValid(ply) then return end
    CreateInventory(ply,"inv_player",8,1,"Инвентарь","inv")
    CreateInventory(ply,"inv_armor",2,9,"Броня","invArmor")
    for _,wep in ipairs(ply:GetWeapons()) do AddWeapon(ply,wep) end
end

hook.Add("PlayerInitialSpawn","HG Gameplay Inventory Create",function(ply)
    timer.Simple(1,function() SetupPlayer(ply) end)
end)

hook.Add("PlayerSpawn","HG Gameplay Inventory Spawn",function(ply)
    timer.Simple(0,function() SetupPlayer(ply) end)
end)

hook.Add("WeaponEquip","HG Gameplay Inventory Weapon",function(wep,ply)
    timer.Simple(0,function() AddWeapon(ply,wep) end)
end)

hook.Add("PlayerCanPickupWeapon","HG Weapon Limits",function(ply,wep)
    -- Block ground pickups of weapons the player already owns the same class.
    -- Container transfers are allowed because the entity is already tracked in inventory.
    local limitType = GetWeaponLimitType(wep)
    if not limitType then return end

    local inv = ply.inv
    if not IsValid(inv) then return end

    -- If entity is already tracked in inventory, it's a container transfer — allow
    if inv:FindItemByEntity(wep) then return end

    -- Block if player already has this weapon class
    local wepClass = wep:GetClass()
    for x = 1,#inv.slots do
        for y = 1,#inv.slots[x] do
            local item = inv.slots[x][y].list[1]
            if item and item.spawnname == wepClass then return false end
        end
    end
end)

-- Hook into armor give system to add armor to inventory.
-- Deferred because 0_inv loads before the armor module, so armorGame may not exist yet.
hook.Add("InitPostEntity","HG Inventory Armor Sync",function()
    if not armorGame then return end

    armorGame:Event_Add("Give","Inventory Sync",function(Armor,armorName,data,typeCall)
        if not IsValid(Armor.parent) or not Armor.parent:IsPlayer() then return end
        timer.Simple(0,function() AddArmor(Armor.parent,armorName,data) end)
    end)
    
    armorGame:Event_Add("Remove","Inventory Sync",function(Armor,armorName,typeCall,ent)
        if not IsValid(Armor.parent) or not Armor.parent:IsPlayer() then return end
        local inv = Armor.parent.invArmor
        if not IsValid(inv) then return end
        
        -- Find and remove armor from inventory
        for x = 1,#inv.slots do
            for y = 1,#inv.slots[x] do
                local list = inv.slots[x][y].list
                for depth,item in ipairs(list) do
                    if item.data and item.data.armorName == armorName then
                        table.remove(list,depth)
                        for d,other in ipairs(list) do other.depth = d end
                        inv:Sync()
                        return
                    end
                end
            end
        end
    end)
end)

hook.Add("PlayerDisconnected","HG Gameplay Inventory Remove",function(ply)
    for inv in pairs(ply.invListIndex or {}) do if IsValid(inv) then inv:Remove() end end
end)

function inventoryGame:InputServer(ply)
    local command = net.ReadString()

    if command == "Close" then
        local inv = self.listIndex[net.ReadInt(14)]
        local allowed = CanAccess(ply,inv)
        if allowed and inv.parent ~= ply then
            if inv.viewers then inv.viewers[ply] = nil end
            SendRemove(inv,ply)
        end
        return allowed,allowed and "" or "inventory access denied"
    elseif command == "Drop" then
        local inv = self.listIndex[net.ReadInt(14)]
        local x,y = net.ReadInt(7),net.ReadInt(7)
        net.ReadInt(7) -- count; weapon stacks are not split
        if not CanAccess(ply,inv) then return false,"inventory access denied" end
        local item = inv:GetItem(x,y)
        if not item then return false,"item not found" end

        local dropPos = ply:EyePos() + ply:GetAimVector() * 55 + Vector(0,0,10)
        if IsValid(item.ent) and item.ent:IsWeapon() and item.ent:GetOwner() == ply then
            ply:DropWeapon(item.ent)
            RestoreWorldEntity(item.ent,dropPos,ply)
        elseif IsValid(item.ent) then
            RestoreWorldEntity(item.ent,dropPos,ply)
        else
            local ent,err = SpawnItemEntity(item,dropPos)
            if IsValid(ent) and IsValid(ply) then
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then
                    phys:Wake()
                    local fwd = ply:GetAimVector()
                    phys:SetVelocity(fwd * 200 + Vector(0,0,100))
                end
            end
            if not IsValid(ent) then return false,err end
        end
        RemoveItem(item)
        inv:Sync()
        return true,""
    elseif command == "Move" then
        local from = self.listIndex[net.ReadInt(14)]
        local fx,fy = net.ReadInt(7),net.ReadInt(7)
        local target = self.listIndex[net.ReadInt(14)]
        local tx,ty = net.ReadInt(7),net.ReadInt(7)
        net.ReadInt(7)
        if not CanAccess(ply,from) or not CanAccess(ply,target) then return false,"inventory access denied" end
        local item = from:GetItem(fx,fy)
        local slot = target:GetSlot(tx,ty)
        if not item or not slot or slot.list[1] then return false,"slot is unavailable" end
        local transferred,reason = TransferEntityState(item,from,target,ply)
        if not transferred then return false,reason or "item transfer failed" end
        RemoveItem(item) InsertItem(item,slot)
        from:Sync() if target ~= from then target:Sync() end
        return true,""
    elseif command == "FastMove" then
        local from = self.listIndex[net.ReadInt(14)]
        local x,y = net.ReadInt(7),net.ReadInt(7)
        if not CanAccess(ply,from) then return false,"inventory access denied" end
        local item = from:GetItem(x,y)
        if not item then return false,"item not found" end
        local candidates = {ply.inv,ply.invDump,ply.invBackpack}
        for _,target in ipairs(candidates) do
            if IsValid(target) and target ~= from then
                local slot = EmptySlot(target)
                if slot then
                    local transferred,reason = TransferEntityState(item,from,target,ply)
                    if not transferred then return false,reason or "item transfer failed" end
                    RemoveItem(item) InsertItem(item,slot)
                    from:Sync() target:Sync()
                    return true,""
                end
            end
        end
        return false,"no free slot"
    elseif command == "Interactive" then
        local inv = self.listIndex[net.ReadInt(14)]
        local x,y = net.ReadInt(7),net.ReadInt(7)
        if not CanAccess(ply,inv) then return false,"inventory access denied" end
        local item = inv:GetItem(x,y)
        if item and IsValid(item.ent) and item.ent.InventoryInteract then
            return item.ent:InventoryInteract(ply,item) ~= false,""
        end
        return false,"item has no interaction"
    end

    return false,"unknown inventory command"
end
