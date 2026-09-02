local SWEP = oop.Reg("wep_melee_labris","wep_melee_base")
if not SWEP then return end

SWEP.PrintName = "Labris"
SWEP.itemType = "meleePrimary"

SWEP.BlockSecondaryWeapon = true
SWEP.EnableMetalVibration = true
SWEP.TextureSubIndex = 2

SWEP.dwiPos = Vector(9,-100,-9)
SWEP.dwsAng = Angle(45,180,0)
SWEP.dwsPos = Vector(9,-120,-8)

SWEP.vbwUseWMDropData = true
SWEP.vbwIsHolster = false
SWEP.vbwPos = Vector(-9,-4,-1)
SWEP.vbwAng = Angle(90 + 12,0,0)

SWEP.wmDropData = {model = "models/weapons/arc9/darsu_eft/w_melee_labris.mdl"}

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_melee_hultafors.mdl",
    vec = Vector(0,0,0),
    ang = Angle(0,0,0)
})

SWEP.Primary.Delay = 1.2
SWEP.Primary.DamageType = DMG_SLASH
SWEP.Primary.Damage = 28
SWEP.Primary.DamagePain = 30
SWEP.Primary.DamageImpulse = 1.1
SWEP.Primary.DamageBleed = 20
SWEP.Primary.Force = 800
SWEP.Primary.ForceRagdoll = SWEP.Primary.Force * 10
SWEP.Primary.Volume = 1

SWEP.Secondary.Delay = 1
SWEP.Secondary.Damage = 60
SWEP.Secondary.DamagePain = 90
SWEP.Secondary.DamageImpulse = 5
SWEP.Secondary.Force = 300
SWEP.Secondary.ForceRagdoll = SWEP.Primary.Force * 30
SWEP.Secondary.Throw = "melee_labris"

SWEP.Primary.SoundHitFlesh = {
    list = {"weapons/melee/slash_hit1.ogg","weapons/melee/slash_hit2.ogg",},
    pitch = 90,
    volume = 0.55,
}

SWEP.Primary.SoundHit = {
    pitch = 80,
    volume = 1,
    list = {"weapons/melee/hammer_hit_wall1.ogg","weapons/melee/hammer_hit_wall2.ogg"}
}

SWEP.EnableBlooded = true
SWEP.EnableBulletDecal = true
SWEP.EnableSoundBulllet = true

SWEP.BulletDecalSizeW = 3
SWEP.BulletDecalSizeH = 3

SWEP.AnimationList = {
    ["deploy"] = {
        index = 2,
        delay = 1.3,
        startCycle = 0.2,

        skip = 0.5,

        sound = {
            [0.1] = {
                {{"weapons/melee/bat/sfx_cloth_jacket_leather_run_10.wav"},75,1,70},
                {{"weapons/melee/hammer_charge1.ogg"},75,1,100}
            }
        }
    },
    ["holster"] = {
        index = 1,
        delay = 0.7,
        endCycle = 0.5,

        sound = {
            [0] = {
                {{"weapons/melee/bat/sfx_cloth_jacket_leather_run_08.wav"},75,1,70},
                {{"weapons/melee/hammer_charge2.ogg"},75,1,100}
            }
        }
    },
    ["inspect"] = {
        index = 3,
        delay = 3,

        startCycle = 0.1,
        endCycle = 0.8,

        OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
            wmVector[3] = wmVector[3] + 0
            wmVector[1] = wmVector[1] + 2
        end,
    }
}

local graphAngle = {
    {0,Angle()},
    {0.4,Angle(0,-4.333,10)},
    {1,Angle()},
}

local graphCameraAngle = {
    {0.1,Angle()},
    {0.2,Angle(-2.5,5,5)},
    {0.3,Angle(-5,5,10)},
    {0.4,Angle(5,-5,-10)},
    {0.6,Angle(0,0,0)},
    {1,Angle()}
}

SWEP.AnimationList["attack_primary"] = {
    index = 6,
    delay = 2,
    
    skip = 0.9,

    load = 0.4,

    attackPosStart = Vector(0,0,0),
    attackPosEnd = Vector(PlayerDisUse * 1,0,0),

    hitboxMins = -Vector(4,3,16),
    hitboxMaxs = Vector(4,3,4),

    sound = {
        [0.08] = {{"weapons/melee/matelbat/bat_draw.wav",75,0.6,90}},
        [0.26] = {{{"weapons/melee/scythe_whoosh_01.ogg","weapons/melee/scythe_whoosh_02.ogg","weapons/melee/scythe_whoosh_03.ogg","weapons/melee/scythe_whoosh_04.ogg","weapons/melee/scythe_whoosh_05.ogg"},75,80}},
        [0.24] = {{{"weapons/melee/hammer_swing1.ogg","weapons/melee/hammer_swing1.ogg","weapons/melee/hammer_swing3.ogg"},75,1,90}},
    },

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
    end,
    
    OnChangeCamera = function(self,pos,ang)
        ang:Add(math.EvalGraphAngle(self:GetCycle("animation"),graphCameraAngle))
    end,

    movementMul = 0.46
}

--
-- THROW
--

local graphAngle = {
    {0,Angle()},
    {0.15,Angle(-20,-2,0)},
}

SWEP.AnimationList["attack_throw_start"] = {
    index = 6,
    delay = 0.5,
    endCycle = 0.15,
    endless = true,

    sound = {
        [0] = {
            {{"weapons/handling_csgo/aug_zoom_in.wav"},75,1,100},
        },
    },

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
    end,

    movementMul = 0.6,
    skip = 1.3,
}

SWEP.AnimationList["attack_throw"] = {
    index = 6,
    delay = 0.5,
    startCycle = 0.15,
    endless = true,

    Think = function(object)
        if not object.isLocal then return end

        if CLIENT and object:GetCycle() > object.skip then
            object.parent:DoAction({name = "attack_throw",flag = 3})
        end
    end,

    skip = 0.3
}


SWEP.AnimationList["attack_throw_stop"] = {
    index = 6,
    delay = 0.5,
    endCycle = 0.2,
    inversion = true,

    sound = {
        [0] = {
            {{"weapons/handling_csgo/aug_zoom_out.wav",75,1,100}}
        }
    },

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
    end,
}

function SWEP:PreHit(dmgTab,result,surfaceName)
    if dmgTab.target:IsPlayer() then
        if dmgTab.target:Health() - dmgTab.dmg <= 50 then
            dmgTab.headshootForce = true
        end

        dmgTab.effect_headExplode = true

        if dmgTab.hitgroup == HITGROUP_HEAD then
            gibParticles.bloodHitCreate(result.HitPos,result.HitNormal,result.Entity)
            surfaceWorld.CreateDecalBullet(result.HitPos,result.HitNormal,result.Entity,surfaceName)
            sound.Emit(nil,"homigrad/player/headshot/headshot_tp_" .. math.random(1,4) .. ".ogg",75,1,100,result.HitPos)

            dmgTab:AddKill("head")
        end
    else
        dmgTab.headshootForce = true
        dmgTab.explodeHead = true
    end
end

function SWEP:PostHit(dmgTab)
    dmgTab.damageDoors = true
    
    local ent = dmgTab.rag or dmgTab.ent

    if ent.explodeHead or ent.breakHead then
        self:SetPVSVar("IsBlooded",true)
        inventoryGame.SyncItemByEntity(self)
    end
end

function SWEP:HitPost(result,typeAttack,surfaceName)
    local info = surfaceWorld.Fast.sound.footkick[surfaceName]
    if not info then return end

    self:EmitLocalSound(info.list[math.random(1,#info.list)],75,1)
end

function SWEP:CreateWorldModelBodygroup(wm)
    wm:SetBodygroup(0,2)
end

ammoGame.Reg({
    name = "melee_labris",
    AmmoCalibre = "melee",

    bulletInfo = {
        Speed = 12,
        Diametr = 48,
        Mass = 700,

        MultiplySpeed = 0.9,
        DoNotCrack = true,

        FlySound = {
            list = {"weapons/melee/fly.ogg"},
            volume = 0.6,
            level = 75,
            pitch = 90
        },

        TraceManual = {
            Vector(0,0,0),
            Vector(0,0,-4),
            Vector(0,0,4)
        },

        Think = function(self)
            if self:GetPVSVar("Hit") then return end
            
            local ang = self.dir:GetNormalized():Angle()

            ang[1] = ang[1] + (CurTime() * self.dir:Length() * 0.1) % 360

            self:SetAngles(ang)
        end,

        HitEnd = function(self,traceResult)
            local dir = self.dir:GetNormalized()
            local ang = dir:Angle()

            local normal = traceResult.HitNormal
            local dot = math.Clamp(normal:Dot(-dir), -1, 1)

            local hitAngle = math.deg(math.acos(dot))

            if hitAngle > 2 then
                local correction = hitAngle - 2

                local rotationAxis = ang:Right()

                ang:RotateAroundAxis(rotationAxis,-correction)
            end
            
            self:SetAngles(ang)
        end
    },

    DeterminateUseMin = -Vector(7,2.5,9),
    DeterminateUseMax = Vector(7,2.5,32),

    CenterModel = {Vector(0,0,-24),Angle(0,0,0)},
})
