local ENTITY = FindMetaTable("Entity")

function CreateDamageTab(entity, attacker, weapon, dmg, dmgType)
    return {
        target = entity,
        att = attacker,
        weapon = weapon,
        dmg = dmg,
        dmgType = dmgType or DMG_GENERIC,

        forcePhys = Vector(),
        forcePhysRagdoll = Vector(),

        reasons = {}
    }
end

function DamageTab_ParseBone(dmgTab)
    local target = dmgTab.target
    if not IsValid(target) or not dmgTab.bone then return end

    local boneName = target:GetBoneName(dmgTab.bone)
    if not boneName or boneName == "" then return end

    dmgTab.boneName = boneName

    if dmgTab.noHeadshot then return end

    if string.find(boneName,"Head") or string.find(boneName,"Neck") then
        dmgTab.dmg = (dmgTab.dmg or 0) * 2

        dmgTab.headshot = true
    end
end