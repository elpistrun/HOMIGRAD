ammoGame.Reg({
    name = "40x46_m381",
    printname = "40x46 M381",
    desc = "",

    Material = "models/hmcd_ammobox_12",
    Scale = 1,

    icon = "entities/eft_attachments/ammo/40x46/40x46mm_m381.png",

    bulletInfo = {
        Speed = 60,
        Mass = 200,
        
        Diameter = 40,

        DragModelName = "GS",
        BalisticCoeff = 0.1,

        MultiplySpeed = 1,

        Hardness = 1,
        Expansion = 1,
        Damage = 0,
        DamageType = DMG_CLUB,

        Count = 1,

        DoNotCrack = true,
        
        HitEnd = function(self,traceResult)
            local hitEntity = traceResult.Entity

            if util.IsHumanoid(hitEntity) then
                if SERVER then
                    hitEntity = hitEntity:GetController() or hitEntity

                    local attacker = self.attacker
                    local weapon = self.weapon
                    local dmgType = self.dmgType

                    dmgTab = CreateDamageTab(hitEntity,attacker,weapon,1,dmgType or DMG_BULLET)
                    dmgTab.impulse = 10
                    
                    hitEntity:TakeDamageTab(dmgTab)

                    timer.GameSimple(1,function()
                        if hitEntity:IsPlayer() and hitEntity:HasGodMode() then return end

                        local pos = hitEntity:GetPos() + hitEntity:OBBCenter():Rotate(hitEntity:GetAngles())
                        gibParticles.bloodExplodeCreate(pos,traceResult.HitNormal)
                        gibParticles.bloodFallCreate(pos,Vector(0,0,1))
                        
                        dmgTab = CreateDamageTab(hitEntity,attacker,weapon,300,DMG_BLAST)
                        hitEntity:TakeDamageTab(dmgTab)

                        local explosive = oop.Create("explosive_40x46_m381")
                        explosive:SetPos(traceResult.HitPos)
                        explosive:SetAttacker(attacker)
        
                        explosive:Emit()
                    end)
                end

                self:Remove()

                return
            end

            if RealTime() - self.startRealTime > 0.1 then
                local explosive = oop.Create("explosive_40x46_m381")
                explosive:SetPos(traceResult.HitPos + traceResult.HitNormal)
                explosive:SetAttacker(self.attacker)

                if SERVER then
                    explosive:ExplosiveLogic()
                else
                    explosive:Emit()
                end
            else
                if CLIENT then
                    local surfaceName = surfaceWorld.GetSurfaceName(traceResult.SurfaceProps)
                    local ent = sound.GetVurtialEmit(traceResult.HitPos)

                    surfaceWorld.CreateSoundBullet(ent,surfaceName)

                    surfaceWorld.CreateEffectBullet(traceResult.HitPos,traceResult.HitNormal,nil,surfaceName,0.1)

                    surfaceWorld.CreateDecalBullet(traceResult.HitPos,traceResult.HitNormal,traceResult.Entity,surfaceName)
                end
            end

            self:Remove()
        end
    },

    InvSoundUse = {"weapons/shells/12cal_shell_concrete1.wav","weapons/shells/12cal_shell_concrete2.wav","weapons/shells/12cal_shell_concrete3.wav"},

    AmmoCalibre = "40mm",
    ShellSound = "12mm",
    ShellModel = "models/weapons/arc9/darsu_eft/40x46_m381.mdl"
})

ammoGame.callibreIndex["40mm"] = "40x46_m381"

local EXP = oop.RegEx("explosive_40x46_m381","explosive_base")[1]

EXP.Damage = 75
EXP.RadiusDamage = 200//наносит урон от взрывной волны
EXP.RadiusStun = 400//оглушает взрывной волной

EXP.FragCount = 1200
EXP.FragDamage = 25
EXP.FragMaxDistance = 1000

// Client

EXP.ParticleGround = "100lb_air"
EXP.ParticleAir = "100lb_air"

EXP.Earrape = true
EXP.ExplosiveWave = false
EXP.ExplosivePunch = true

EXP.Power = 0.75

EXP.SoundClose = {"weapons/eft/m203/gren_expl2_close.ogg"}
EXP.SoundDist = {"weapons/eft/m203/gren_expl2_dist1.ogg","weapons/eft/m203/gren_expl2_dist2.ogg"}
EXP.SoundFar = nil