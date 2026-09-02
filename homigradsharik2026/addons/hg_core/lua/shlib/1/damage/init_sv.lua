local ENTITY = FindMetaTable("Entity")

local bit_band = bit.band

util.AddNetworkString("death")
util.AddNetworkString("damage log")

function ENTITY:TakeDamageTab(dmgTab)
    local target = dmgTab.target
    if not IsValid(target) then return end

    local result = event.Call("Damage", dmgTab)
    if result == false then return end

    local dmg = dmgTab.dmg or 0
    if dmg <= 0 then return end

    local attacker = dmgTab.att
    local weapon = dmgTab.weapon
    local dmgType = dmgTab.dmgType or DMG_GENERIC

    local dmgInfo = DamageInfo()
    dmgInfo:SetDamage(dmg)
    dmgInfo:SetAttacker(IsValid(attacker) and attacker or target)
    dmgInfo:SetInflictor(IsValid(weapon) and weapon or IsValid(attacker) and attacker or target)
    dmgInfo:SetDamageType(dmgType)
    dmgInfo:SetDamagePosition(dmgTab.pos or target:GetPos())

    if dmgTab.force then
        dmgInfo:SetDamageForce(dmgTab.force)

        if target:IsPlayer() then
            target:SetVelocity(target:GetVelocity() + dmgTab.force * 0.4)
        end
    end

    if dmgTab.forcePhys and target:GetMoveType() == MOVETYPE_VPHYSICS then
        local phys = target:GetPhysicsObject()
        if IsValid(phys) then
            phys:ApplyForceCenter(dmgTab.forcePhys)
            phys:Wake()
        end
    end

    local hpBefore = target:Health()

    target:TakeDamageInfo(dmgInfo)

    if not IsValid(target) then return end

    local dead
    if target:IsPlayer() or target:IsNPC() then
        dead = hpBefore > 0 and not target:Alive()
    else
        dead = hpBefore > 0 and target:Health() <= 0
    end

    if dead then
        target.LastDmg = dmgTab

        self:DamageTab_Death(dmgTab)
    end

    return dmgTab
end

function ENTITY:DamageTab_Death(dmgTab)
    local target = dmgTab.target
    if not IsValid(target) or not target:IsPlayer() then return end

    local reasons = dmgTab.reasons or {}
    dmgTab.reasons = reasons

    local dmgType = dmgTab.dmgType or DMG_GENERIC
    local boneName = dmgTab.boneName or ""

    local head = string.find(boneName,"Head") or string.find(boneName,"Neck")

    local isExplosive = dmgTab.isExplosive or bit_band(dmgType,DMG_BLAST) ~= 0

    if isExplosive then
        if head then
            reasons["headExplode"] = true
        end
    elseif head or dmgTab.headshot then
        reasons["head"] = true
    end

    local attacker = dmgTab.att

    local killedBy,killedTarget

    if not IsValid(attacker) or attacker == target then
        if not IsValid(attacker) then
            killedBy = nil
        else
            killedBy = "player"
            killedTarget = attacker

            reasons["killyourself"] = true
        end
    elseif attacker:IsPlayer() then
        killedBy = "player"
        killedTarget = attacker
    elseif attacker:IsNPC() then
        killedBy = "npc"
        killedTarget = attacker:Name() or "NPC"
    else
        killedBy = "object"
        killedTarget = attacker:GetClass() or "object"
    end

    local wepName
    local weapon = dmgTab.weapon
    if IsValid(weapon) then
        local name = weapon.PrintName
        if type(name) == "string" then wepName = name end
    end

    local distance
    if killedBy == "player" and IsValid(attacker) then
        distance = target:GetPos():Distance(attacker:GetPos())
    end

    local dmgTabNet = dmgTab

    timer.Simple(0.15,function()
        if not IsValid(target) then return end

        dmgTabNet.killedBy = killedBy
        dmgTabNet.killedTarget = killedTarget
        dmgTabNet.wepName = wepName
        dmgTabNet.distance = distance

        local ragEnt = target:GetRagdollEntity()
        if not IsValid(ragEnt) then
            local dummy = target:GetDummy()
            if IsValid(dummy) and dummy != target then ragEnt = dummy end
        end

        dmgTabNet.ragEntIndex = IsValid(ragEnt) and ragEnt:EntIndex() or 0

        net.Start("death")
        net.WriteTable(dmgTabNet)
        net.Broadcast()

        net.Start("damage log")
        net.WriteTable(dmgTabNet)
        net.Send(target)
    end)
end