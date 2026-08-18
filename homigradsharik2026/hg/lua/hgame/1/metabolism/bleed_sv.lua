if not SERVER then return end

local PLAYER = FindMetaTable("Player")

function PLAYER:GetBleed()
    return self.bleed or 0
end

function PLAYER:SetBleed(value)
    self.bleed = math.max(tonumber(value) or 0, 0)
    self:SetNW2Float("bleed", self.bleed)
end

function PLAYER:StopBleeding()
    self:SetBleed(0)
end

function PLAYER:RestoreBlood(amount)
    self.blood = math.min((self.blood or 5000) + (tonumber(amount) or 0), 5000)
    self:SetNW2Float("blood", self.blood)
end

-- Accumulate bleed and pain from damage
event.Add("Damage", "Bleed System", function(dmgTab)
    local target = dmgTab.target
    if not IsValid(target) or not target:IsPlayer() then return end

    -- Bleed accumulation
    if not dmgTab.stopBleed then
        local bleed = dmgTab.bleed
        if bleed and bleed > 0 then
            target:SetBleed((target.bleed or 0) + bleed)

            -- Spawn blood particles at hit position
            if dmgTab.pos and gibParticles.bleedCreate then
                local vel = dmgTab.force
                    and dmgTab.force:GetNormalized():Mul(math.Rand(50, 150))
                    or VectorRand():Mul(100)
                vel = vel or VectorRand():Mul(100)

                if dmgTab.dontBleedArtery then
                    gibParticles.bleedCreate(dmgTab.pos, vel)
                else
                    gibParticles.bleedArteryCreate(dmgTab.pos, vel)
                end
            end
        end
    end

    -- Pain accumulation
    local pain = dmgTab.pain
    if pain and pain > 0 then
        local mul = target.painMul or 1
        target.pain = math.min((target.pain or 0) + pain * mul, 200)
        target:SetNW2Float("pain", target.pain)
    end
end, -5)

-- Bleed tick: drain blood, spawn drip particles, deal bleed damage, decay pain
timer.Create("HG Metabolism Tick", 0.5, 0, function()
    local dt = 0.5

    for _, ply in ipairs(player.GetAll()) do
        if not ply:Alive() then continue end

        -- === Bleed processing ===
        local bleed = ply.bleed or 0
        if bleed > 0 then
            -- Drain blood proportional to bleed rate
            local bloodLoss = bleed * 2.5 * dt
            ply.blood = math.max((ply.blood or 5000) - bloodLoss, 0)

            -- Spawn periodic blood drip particles from player
            if math.random(1, 3) == 1 and gibParticles.bleedCreate then
                local pos = ply:GetPos() + Vector(math.Rand(-15, 15), math.Rand(-15, 15), math.Rand(20, 50))
                gibParticles.bleedCreate(pos, Vector(math.Rand(-20, 20), math.Rand(-20, 20), math.Rand(-50, -20)))
            end

            -- Deal bleed damage when blood is critically low
            if ply.blood <= 0 then
                local dmgInfo = DamageInfo()
                dmgInfo:SetDamage(bleed * dt * 2)
                dmgInfo:SetDamageType(DMG_GENERIC)
                dmgInfo:SetAttacker(ply)
                dmgInfo:SetInflictor(ply)
                dmgInfo:SetDamagePosition(ply:GetPos())
                dmgInfo:SetDamageForce(Vector())
                ply:TakeDamageInfo(dmgInfo)
            end

            -- Slow natural blood regeneration when not bleeding heavily
            if bleed < 5 and ply.blood > 0 and ply.blood < 5000 then
                ply.blood = math.min(ply.blood + 1.5 * dt, 5000)
            end

            ply:SetNW2Float("bleed", bleed)
            ply:SetNW2Float("blood", ply.blood)
        end

        -- === Pain decay ===
        local pain = ply.pain or 0
        if pain > 0 then
            local painLosing = ply.painLosing or 5
            ply.pain = math.max(pain - painLosing * dt, 0)
            ply:SetNW2Float("pain", ply.pain)
            ply:SetNW2Float("painlosing", painLosing)

            -- Otrub (unconscious) from extreme pain
            if pain >= 100 and not ply.Otrub then
                ply.Otrub = true
                ply:SetNW2Bool("Otrub", true)

                timer.Simple(8, function()
                    if not IsValid(ply) then return end
                    ply.Otrub = nil
                    ply.pain = math.max((ply.pain or 0) - 30, 0)
                    ply:SetNW2Float("pain", ply.pain)
                    ply:SetNW2Bool("Otrub", false)
                end)
            end
        else
            ply:SetNW2Float("painlosing", 0)
        end

        -- === Adrenaline expiry ===
        if ply.adrenaline and ply.adrenaline <= CurTime() then
            ply.adrenaline = nil
            ply.painMul = math.max((ply.painMul or 1) / 1.5, 1)
            ply:SetNW2Float("adrenaline", 0)
        elseif ply.adrenaline then
            ply:SetNW2Float("adrenaline", ply.adrenaline - CurTime())
        end
    end
end)

-- Adrenaline speed boost
event.Add("Move", "Adrenaline Speed", function(ply, mv)
    if not ply.adrenaline or ply.adrenaline <= CurTime() then return end
    local maxSpeed = mv:GetMaxSpeed() * 1.3
    mv:SetMaxSpeed(maxSpeed)
    mv:SetMaxClientSpeed(maxSpeed)
end, -1)

-- Needle (med_needle) HP regeneration: cancels on damage
event.Add("Damage", "Health Reg Cancel", function(dmgTab)
    local target = dmgTab.target
    if not IsValid(target) or not target:IsPlayer() then return end
    if dmgTab.dmg and dmgTab.dmg > 0 then
        target.HealthReg = nil
        target:SetNW2Float("HealthReg", 0)
    end
end, -10)

timer.Create("HG Health Regen", 1, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if not ply:Alive() or not ply.HealthReg then continue end

        if ply:Health() < ply:GetMaxHealth() then
            local newHP = math.min(ply:Health() + ply.HealthReg, ply:GetMaxHealth())
            ply:SetHealth(newHP)
        end

        if ply:Health() >= ply:GetMaxHealth() then
            ply.HealthReg = nil
            ply:SetNW2Float("HealthReg", 0)
        end
    end
end)

-- Reset bleed, pain, and health regen on spawn
hook.Add("PlayerSpawn", "HG Bleed Reset", function(ply)
    ply.bleed = 0
    ply.pain = 0
    ply.painLosing = 5
    ply.painMul = 1
    ply.HealthReg = nil
    ply.Otrub = nil
    ply.adrenaline = nil
    ply:SetNW2Float("bleed", 0)
    ply:SetNW2Float("pain", 0)
    ply:SetNW2Float("painlosing", 5)
    ply:SetNW2Float("HealthReg", 0)
    ply:SetNW2Float("adrenaline", 0)
    ply:SetNW2Bool("Otrub", false)
end)

-- Clear all effects on death (prevents effect persisting)
hook.Add("PlayerDeath", "HG Bleed Death Clear", function(ply)
    ply.pain = 0
    ply.painLosing = 5
    ply.painMul = 1
    ply.Otrub = nil
    ply.adrenaline = nil
    ply.HealthReg = nil
    ply:SetNW2Float("pain", 0)
    ply:SetNW2Float("painlosing", 0)
    ply:SetNW2Float("adrenaline", 0)
    ply:SetNW2Float("HealthReg", 0)
    ply:SetNW2Bool("Otrub", false)
end)

-- Low HP: enter fake (Otrub from blood loss)
hook.Add("Think", "HG Low HP Fake", function()
    for _, ply in ipairs(player.GetAll()) do
        if not ply:Alive() or ply:InFake() or ply:HasGodMode() then continue end
        if ply:GetMoveType() == MOVETYPE_NOCLIP then continue end
        if ply.Otrub or ply:InFakeDeath() then continue end

        local hp = ply:Health()
        local maxHp = ply:GetMaxHealth()

        -- Enter fake when HP is critically low (below 15% of max)
        if hp > 0 and hp <= maxHp * 0.15 then
            ply.Otrub = true
            ply:SetNW2Bool("Otrub", true)
            ply.pain = 100
            ply:SetNW2Float("pain", 100)

            -- Enter fake ragdoll
            local vel = ply:GetVelocity()
            ply:EnterFake(vel)

            timer.Simple(8, function()
                if not IsValid(ply) then return end
                ply.Otrub = nil
                ply.pain = math.max((ply.pain or 0) - 30, 0)
                ply:SetNW2Float("pain", ply.pain)
                ply:SetNW2Bool("Otrub", false)
            end)
        end
    end
end)

-- Bullet weapon bleeding: apply bleed from standard FireBullets damage
hook.Add("EntityTakeDamage", "HG Bullet Bleed", function(target, dmginfo)
    if not IsValid(target) or not target:IsPlayer() then return end
    if not target.StopBleeding then return end -- bleed system not loaded

    -- Only process bullet damage
    if not dmginfo:IsDamageType(DMG_BULLET) then return end

    local dmg = dmginfo:GetDamage()
    if dmg < 1 then return end

    -- Calculate bleed based on bullet damage (higher damage = more bleeding)
    local bleedAmount = dmg * 0.3
    target:SetBleed((target.bleed or 0) + bleedAmount)

    -- Spawn blood particles at damage position
    local hitPos = dmginfo:GetDamagePosition()
    if hitPos and gibParticles and gibParticles.bleedCreate then
        local vel = dmginfo:GetDamageForce()
        if vel:Length() < 1 then vel = VectorRand() * 100 end
        gibParticles.bleedCreate(hitPos, vel:GetNormalized() * math.Rand(50, 150))
    end
end)

-- Console command for testing bleeding
concommand.Add("hg_bleed", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not ply.SetBleed then return end

    local amount = tonumber(args[1]) or 10
    ply:SetBleed((ply.bleed or 0) + amount)
    ply:ChatPrint("Кровотечение: " .. math.Round(ply.bleed, 1))
end)
