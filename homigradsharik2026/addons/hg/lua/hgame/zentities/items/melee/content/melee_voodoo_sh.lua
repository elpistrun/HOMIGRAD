local SWEP = oop.Reg("wep_melee_voodoo","wep_melee_base")
if not SWEP then return end

SWEP.PrintName = "Voodoo"
SWEP.dwiPos = Vector(5.8,-40,-5.4)
SWEP.dwsAng = Angle(45,180,0)
SWEP.dwsPos = Vector(5.8,-50,-5.4)

SWEP.vbwUseWMDropData = true
SWEP.vbwIsHolster = true
SWEP.vbwPos = Vector(-7,5,0)
SWEP.vbwAng = Angle(90,-10,90)

SWEP.Primary.Delay = 1
SWEP.Primary.Damage = 14
SWEP.Primary.DamageType = DMG_SLASH
SWEP.Primary.DamagePain = 0
SWEP.Primary.DamageImpulse = 0.5
SWEP.Primary.Force = 300
SWEP.Primary.ForceRagdoll = SWEP.Primary.Force * 10
SWEP.Primary.MultiAttack = 6

SWEP.Secondary.Delay = 1
SWEP.Secondary.DamageType = DMG_SLASH
SWEP.Secondary.Damage = 40
SWEP.Secondary.DamagePain = 60
SWEP.Secondary.DamageImpulse = 1
SWEP.Secondary.Force = 300
SWEP.Secondary.ForceRagdoll = SWEP.Primary.Force * 30
SWEP.Secondary.Throw = "melee_voodoo"

SWEP.wmDropData = {model = "models/weapons/arc9/darsu_eft/w_melee_voodoo.mdl"}

SWEP.EnableBlooded = true
SWEP.EnableBulletDecal = true
SWEP.EnableSoundBulllet = true
SWEP.EnableMetalVibration = true

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_melee_voodoo.mdl",
    vec = Vector(-4,4,0),
    ang = Angle(0,0,0)
})

SWEP.AnimationList = {
    ["deploy"] = {
        index = 2,
        delay = 0.5,
    },
    ["holster"] = {
        index = 1,
        delay = 0.5
    },
    ["inspect"] = {
        index = 9,
        delay = 3,

        freeLHand = {
            [0] = false
        },

        OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
            wmVector[3] = wmVector[3]
            wmVector[1] = wmVector[1]
        end
    }
}

SWEP.HoldType = "melee"

local graphAngle = {
    {0,Angle()},
    {0.4,Angle(-5,0,-10)},
    {0.5,Angle(-5,33,-10)},
    {0.6,Angle(0,0,0)},
    {1,Angle()},
}

local graphCameraAngle = {
    {0,Angle(0,0,0)},
    {0.3,Angle(3,-3,6)},
    {0.4,Angle(-1,1,-10)},
    {0.7,Angle()},
}

SWEP.AnimationList["attack_primary"] = {
    index = 11,
    delay = 0.8,

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
    end,

    OnChangeCamera = function(self,pos,ang)
        ang:Add(math.EvalGraphAngle(self:GetCycle("animation"),graphCameraAngle))
    end,

    sound = {
        [0.1] = {{"weapons/melee/matelbat/bat_holster.wav",75,0.6,150}},
        [0.11] = {
            {{"weapons/melee/scythe_whoosh_01.ogg","weapons/melee/scythe_whoosh_02.ogg","weapons/melee/scythe_whoosh_03.ogg"},75,1,100},
            {{"weapons/melee/bat/baseball_swing_1st_layer_01.wav","weapons/melee/bat/baseball_swing_1st_layer_02.wav","weapons/melee/bat/baseball_swing_1st_layer_03.wav","weapons/melee/bat/baseball_swing_1st_layer_04.wav"},75,0.7,100}
        },
    },

    movementMul = 0.9,

    load = 0.3,
    attackPosStart = Vector(0,0,-3),
    attackPosEnd = Vector(PlayerDisUse * 0.82,0,-3),

    hitboxMins = -Vector(12,12,1),
    hitboxMaxs = Vector(12,12,1),
}

--
-- THROW
--

local graphAngle = {
    {0,Angle()},
    {0.15,Angle(-22.5,-2.5,0)},
}

SWEP.AnimationList["attack_throw_start"] = {
    index = 11,
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

    movementMul = 0.89,
    skip = 1.3,
}

SWEP.AnimationList["attack_throw"] = {
    index = 11,
    delay = 0.5,
    startCycle = 0.15,
    endless = true,

    sound = {
        [0.1] = {{"weapons/melee/matelbat/bat_holster.wav",75,0.6,150}},
        [0.11] = {
            {{"weapons/melee/scythe_whoosh_01.ogg","weapons/melee/scythe_whoosh_02.ogg","weapons/melee/scythe_whoosh_03.ogg"},75,1,150},
            {{"weapons/melee/bat/baseball_swing_1st_layer_01.wav","weapons/melee/bat/baseball_swing_1st_layer_02.wav","weapons/melee/bat/baseball_swing_1st_layer_03.wav","weapons/melee/bat/baseball_swing_1st_layer_04.wav"},75,1,150}
        },
    },

    movementMul = 0,
    movementMulGraph = {
        {0,1}
    },

    skip = 0.3
}

SWEP.AnimationList["attack_throw_stop"] = {
    index = 11,
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

    movementMul = 0.6
}

ammoGame.Reg({
    name = "melee_voodoo",
    AmmoCalibre = "melee",

    bulletInfo = {
        Speed = 20,
        Diametr = 48,
        Mass = 700,

        MultiplySpeed = 0.9,
        DoNotCrack = true,

        FlySound = {
            list = {"weapons/melee/fly.ogg"},
            volume = 0.6,
            level = 75,
            pitch = 115
        },

        TraceManual = {
            Vector(0,0,0),
            Vector(0,0,-2),
            Vector(0,0,2)
        },

        Think = function(self)
            if self:GetPVSVar("Hit") then return end
            
            local ang = self.dir:GetNormalized():Angle()

            ang[1] = ang[1] + (CurTime() * self.dir:Length()) % 360

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

    DeterminateUseMin = -Vector(5,1.5,2),
    DeterminateUseMax = Vector(5,1.5,14),

    CenterModel = {Vector(0,0,-12),Angle(0,0,0)},
})