local SWEP = oop.Reg("wep_melee_taran","wep_melee_base")
if not SWEP then return end

SWEP.PrintName = "Taran"
SWEP.itemType = "meleePrimary"

SWEP.dwiPos = Vector(7.9,-55,-8)
SWEP.dwsAng = Angle(45,180,0)
SWEP.dwsPos = Vector(7.9,-66,-8)

SWEP.vbwUseWMDropData = true
SWEP.vbwIsHolster = true
SWEP.vbwPos = Vector(-7,2,0)
SWEP.vbwAng = Angle(0,-5,90)

SWEP.Secondary.Disable = true

SWEP.Primary.Delay = 1

SWEP.Primary.Damage = 14
SWEP.Primary.DamageImpulse = 0.5
SWEP.Primary.Force = 300
SWEP.Primary.ForceRagdoll = SWEP.Primary.Force * 5
SWEP.Primary.MultiAttack = 6

SWEP.wmDropData = {model = "models/weapons/arc9/darsu_eft/w_melee_taran.mdl"}

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_melee_taran.mdl",
    vec = Vector(-6,0,-2),
    ang = Angle(0,0,10)
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
            wmVector[3] = wmVector[3] + 3
            wmVector[1] = wmVector[1] + 3
        end
    }
}

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

SWEP.HoldType = "melee"

SWEP.AnimationList["attack_primary"] = {
    index = 11,
    delay = 0.8,

    Start = function(self)

    end,

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