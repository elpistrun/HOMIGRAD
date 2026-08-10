local SWEP = oop.Reg("wep_melee_gladius_admin","wep_melee_gladius")
if not SWEP then return end

SWEP.PrintName = "Gladius Admin"
SWEP.itemType = "meleePrimary"

SWEP.EnableMetalVibration = true

SWEP.dwiPos = Vector(7.5,-70,-7.3)
SWEP.dwsAng = Angle(45,180,0)
SWEP.dwsPos = Vector(7.5,-90,-7.3)

SWEP.vbwUseWMDropData = true
SWEP.vbwIsHolster = false
SWEP.vbwPos = Vector(-9,-4,-1)
SWEP.vbwAng = Angle(90 + 12,0,0)

SWEP.wmDropData = {model = "models/weapons/arc9/darsu_eft/w_melee_gladius.mdl"}

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_melee_gladius.mdl",
    vec = Vector(-3,3,0),
    ang = Angle(0,0,0)
})

SWEP.Primary.Delay = 0.1
SWEP.Primary.DamageType = DMG_SLASH
SWEP.Primary.Damage = 14
SWEP.Primary.DamageBleed = 10
SWEP.Primary.DamagePain = 3
SWEP.Primary.Force = 0
SWEP.Primary.DontBleedArtery = true
SWEP.Primary.FirstHullTrace = true
SWEP.Primary.MultiAttack = 6

SWEP.Secondary.Delay = 0.1
SWEP.Secondary.DamageType = DMG_SLASH
SWEP.Secondary.Damage = 9
SWEP.Secondary.DamageBleed = 10
SWEP.Secondary.DamagePain = 10
SWEP.Secondary.DamageImpulse = 1.1
SWEP.Secondary.Force = 0

SWEP.EnableBlooded = false
SWEP.EnableBulletDecal = false
SWEP.EnableSoundBulllet = false

SWEP.AnimationList = {
    ["deploy"] = {
        index = 2,
        delay = 1,
        startCycle = 0.2,

        skip = 0.5,

        sound = {
            [0] = {{{"weapons/melee/sword_deploy.ogg"},75,0.5,120}}
        }
    },
    ["holster"] = {
        index = 1,
        delay = 0.7,
        endCycle = 0.5
    },
    ["inspect"] = {
        index = 5,
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
    {0.4,Angle(-5,0,0)},
    {0.5,Angle(-5,-10,0)},
    {1,Angle()},
}

SWEP.AnimationList["attack_secondary"] = {
    index = 13,
    delay = 0.1,
    skip = 0.8,

    Start = function(self)

    end,

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
    end,

    OnChangeCamera = function(self,pos,ang)
    end,

    sound = {
        --[0.1] = {{"weapons/melee/matelbat/bat_holster.wav",75,0.6,150}},
        --[0.23] = {{"weapons/melee/matelbat/bat_draw.wav",75,0.6}},
    },

    movementMul = 0.2,

    load = 0.3,
    attackPosStart = Vector(0,0,-1),
    attackPosEnd = Vector(93,0,-2),

    hitboxMins = -Vector(1,4,1),
    hitboxMaxs = Vector(1,4,1),

    secondaryWeaponFollow = {
        [0] = true
    }
}

local graphAngle = {
    {0,Angle()},
    {0.4,Angle(-5,-10,0)},
    {0.5,Angle(-20,60,0)},
    {0.6,Angle(0,0,0)},
    {1,Angle()},
}

local graphVector = {
    {0,Vector()},
    {0.5,Vector(-8,0,0)},
    {1,Vector()},
}

SWEP.AnimationList["attack_primary"] = {
    index = 17,
    delay = 0.1,
    startCycle = 0,
    endCycle = 0.8,

    Start = function(self)

    end,

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
        wmVector:Set(math.EvalGraphVector(self:GetCycle("animation"),graphVector))
    end,

    OnChangeCamera = function(self,pos,ang)

    end,

    sound = {
        --[0.15] = {{"weapons/melee/matelbat/bat_holster.wav",75,0.6,150}},
        --[0.25] = {{{"weapons/melee/scythe_whoosh_01.ogg","weapons/melee/scythe_whoosh_02.ogg","weapons/melee/scythe_whoosh_03.ogg","weapons/melee/scythe_whoosh_04.ogg","weapons/melee/scythe_whoosh_05.ogg"},75,100}}
    },

    movementMul = 0.2,

    load = 0.5,
    attackPosStart = Vector(0,0,-3),
    attackPosEnd = Vector(93,0,-3),

    hitboxMins = -Vector(16,16,1),
    hitboxMaxs = Vector(16,16,1),
}