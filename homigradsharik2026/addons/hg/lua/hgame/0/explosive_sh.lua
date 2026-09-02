-- Explosive utility functions for melee weapons and other entities

--- Knock a player down (put them in fake death state)
---@param ply Player The player to knock down
function FakeDown(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not ply:InFake() then
        -- Enable fake ragdoll mode first if not already in it
        if ply.SetNWBool then
            ply:SetNWBool("Fake",true)
        end
    end
    -- Set fake death state (knock down)
    if ply.SetNWBool then
        ply:SetNWBool("FakeDeath",true)
    end
end

--- Destroy/damage props and structures in radius
---@param attacker Entity|nil The attacker entity
---@param pos vector Explosion center position
---@param radius number Explosion radius
---@param damage number Damage amount
---@param attacker2 Entity|nil Alternative attacker reference
---@param wreckBuildings boolean Whether to destroy props
function Explosive_WreckBuildings(attacker,pos,radius,damage,attacker2,wreckBuildings)
    if not pos then return end
    
    if wreckBuildings then
        -- Find and damage/destroy props in radius
        local ents = ents.FindInSphere(pos,radius * 100)
        local attackerEnt = IsValid(attacker) and attacker or (IsValid(attacker2) and attacker2) or game.GetWorld()
        for _,ent in ipairs(ents) do
            if IsValid(ent) and ent:GetMoveType() == MOVETYPE_VPHYSICS then
                local dist = ent:GetPos():Distance(pos)
                if dist < radius * 100 then
                    local dmg = DamageInfo()
                    dmg:SetDamage(damage * (1 - dist / (radius * 100)))
                    dmg:SetDamageForce((ent:GetPos() - pos):GetNormalized() * damage * 100)
                    dmg:SetDamagePosition(pos)
                    dmg:SetAttacker(attackerEnt)
                    dmg:SetInflictor(attackerEnt)
                    
                    ent:TakeDamageInfo(dmg)
                end
            end
        end
    end
    
    -- Visual effect
    local effect = EffectData()
    effect:SetOrigin(pos)
    effect:SetMagnitude(radius or 1)
    util.Effect("Explosion",effect)
end

--- Check if entity is a door
local function IsDoorEntity(ent)
    if not IsValid(ent) then return false end
    local class = string.lower(ent:GetClass() or "")
    return class == "prop_door_rotating" or class == "func_door" or class == "func_door_rotating" or string.find(class, "door")
end

--- Blast open doors in radius
---@param attacker Entity|nil The attacker entity
---@param pos vector Explosion center position
---@param radius number Explosion radius
---@param damage number Damage/force amount
---@param attacker2 Entity|nil Alternative attacker reference
function Explosive_BlastDoors(attacker,pos,radius,damage,attacker2)
    if not pos then return end
    
    local ents = ents.FindInSphere(pos,radius * 100)
    for _,ent in ipairs(ents) do
        if IsDoorEntity(ent) then
            local dist = ent:GetPos():Distance(pos)
            if dist < radius * 100 then
                -- Unlock and open the door
                if ent.Fire then
                    ent:Fire("Unlock","",0)
                    ent:Fire("Open","",0.1)
                end
                
                -- Apply force to physics doors
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then
                    local force = (ent:GetPos() - pos):GetNormalized() * damage * 100
                    phys:ApplyForceCenter(force)
                end
            end
        end
    end
end

--- Blast a specific door entity
---@param doorEntity Entity The door to blast
---@param force vector Force to apply
function Explosive_BlastThatDoor(doorEntity,force)
    if not IsValid(doorEntity) then return end
    if not IsDoorEntity(doorEntity) then return end
    
    -- Unlock and open
    if doorEntity.Fire then
        doorEntity:Fire("Unlock","",0)
        doorEntity:Fire("Open","",0.1)
    end
    
    -- Apply force
    local phys = doorEntity:GetPhysicsObject()
    if IsValid(phys) and isvector(force) then
        phys:ApplyForceCenter(force)
    end
end

--- Fragmentation explosion
---@param owner Entity Owner of the explosion
---@param pos vector Explosion center
---@param radius number Explosion radius
---@param damage number Damage amount
---@param force number Force multiplier
---@param attacker Entity The actual attacker
function Explosive_FragSplosion(owner,pos,radius,damage,force,attacker)
    if not pos then return end
    
    -- Damage entities in radius
    local ents = ents.FindInSphere(pos,radius)
    for _,ent in ipairs(ents) do
        if IsValid(ent) and ent:IsPlayer() or ent:IsNPC() or (ent:GetMoveType() == MOVETYPE_VPHYSICS and ent:GetClass() ~= "prop_ragdoll") then
            local dist = ent:GetPos():Distance(pos)
            if dist < radius then
                local dmg = DamageInfo()
                dmg:SetDamage(damage * (1 - dist / radius))
                dmg:SetDamageForce((ent:GetPos() - pos):GetNormalized() * force)
                dmg:SetDamagePosition(pos)
                dmg:SetAttacker(attacker or owner or game.GetWorld())
                dmg:SetInflictor(owner or attacker or game.GetWorld())
                
                ent:TakeDamageInfo(dmg)
            end
        end
    end
    
    -- Visual effect
    local effect = EffectData()
    effect:SetOrigin(pos)
    effect:SetMagnitude(radius / 100)
    util.Effect("Explosion",effect)
end
