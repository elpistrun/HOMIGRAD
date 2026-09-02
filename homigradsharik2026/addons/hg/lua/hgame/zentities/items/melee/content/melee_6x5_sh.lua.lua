local SWEP = oop.Reg("wep_melee_6x5","wep_melee_base")
if not SWEP then return end

SWEP.PrintName = "6X5"

SWEP.dwiPos = Vector(4,-27,-4.1)
SWEP.dwsAng = Angle(45,180,0)
SWEP.dwsPos = Vector(4,-32,-4.1)

SWEP.Primary.Delay = 0.67
SWEP.Primary.DamageType = DMG_SLASH
SWEP.Primary.Damage = 18
SWEP.Primary.DamageBleed = 10
SWEP.Primary.DamagePain = 10
SWEP.Primary.MultiAttack = 2

SWEP.Primary.SoundHitFlesh = {
    list = {"weapons/melee/slash_hit1.ogg","weapons/melee/slash_hit2.ogg"},
    pitch = 125,
    volume = 0.3,
}

SWEP.Secondary.Delay = 1
SWEP.Secondary.DamageType = DMG_SLASH
SWEP.Secondary.Damage = 30
SWEP.Secondary.DamageBleed = 10
SWEP.Secondary.DamagePain = 10
SWEP.Secondary.DamageImpulse = 0.5

SWEP.Secondary.SoundHitFlesh = {
    list = {"weapons/melee/slash_hit1.ogg","weapons/melee/slash_hit2.ogg"},
    pitch = 90,
    volume = 0.5,
}

SWEP.Secondary.Throw = "melee_6x5"
SWEP.ThrowOffset = Vector(0,2,6)

SWEP.EnableBlooded = true
SWEP.EnableBulletDecal = true

SWEP.wmDropData = {model = "models/weapons/arc9/darsu_eft/w_melee_6x5.mdl"}

SWEP.HoldType = "knife"

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_melee_6x5.mdl",
    vec = Vector(-10,0,2),
    ang = Angle(10,10,0)
})

SWEP.textureUVBlood_X = 0
SWEP.textureUVBlood_Y = -0.5

SWEP.AnimationList = {
    ["deploy"] = {
        index = 2,
        delay = 0.5,
        skip = 0.5,
    },
    ["holster"] = {
        index = 1,
        delay = 0.5
    },
    ["inspect"] = {
        index = 6,
        delay = 3,

        endCycle = 0.8,

        OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
            wmVector[3] = wmVector[3] + 2
            wmVector[1] = wmVector[1] + 6
        end,

        dontShake = true
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

SWEP.AnimationList["attack_primary"] = {
    index = 13,
    delay = 0.8,
    startCycle = 0,
    endCycle = 0.66,

    Start = function(self)
        local ply = self.parent:GetOwner()
        ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD,ply:LookupSequence("range_knife"),0,true)
        ply:SetLayerDuration(GESTURE_SLOT_ATTACK_AND_RELOAD,self.delay)
    end,

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
    end,

    OnChangeCamera = function(self,pos,ang)
        ang:Add(math.EvalGraphAngle(self:GetCycle("animation"),graphCameraAngle))
    end,

    sound = {
        [0.18] = {{"weapons/melee/matelbat/bat_draw.wav",75,0.6}},
        [0.2] = {{{"weapons/melee/knife_bayonet_swing1.ogg","weapons/melee/knife_bayonet_swing2.ogg"},75,1}}
    },

    movementMul = 0.8,

    load = 0.5,
    attackPosStart = Vector(0,0,-1),
    attackPosEnd = Vector(PlayerDisUse * 0.5,0,-2),

    hitboxMins = Vector(1,-4,-1),
    hitboxMaxs = Vector(1,4,1),
}

local graphAngle = {
    {0,Angle()},
    {0.15,Angle(-17,8.3,0)}
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

    Start = function(self)
        self.parent:SetHoldType("normal")
    end,

    Stop = function(self)
        self.parent:SetHoldType(self.parent.HoldType)
    end,

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
    end,

    movementMul = 0.6,
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
            {{"weapons/melee/bat/baseball_swing_1st_layer_01.wav","weapons/melee/bat/baseball_swing_1st_layer_02.wav","weapons/melee/bat/baseball_swing_1st_layer_03.wav","weapons/melee/bat/baseball_swing_1st_layer_04.wav"},75,1,180}
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
    name = "melee_6x5",
    AmmoCalibre = "melee",

    bulletInfo = {
        Speed = 29,
        Diametr = 9,
        Mass = 50,

        MultiplySpeed = 1.3,
        DoNotCrack = true,

        Think = function(self)
            if self:GetPVSVar("Hit") then return end
            
            local ang = self.dir:GetNormalized():Angle()

            ang[1] = ang[1] + 90

            self:SetAngles(ang)
        end,

        HitEnd = function(self,traceResult)
            local dir = self.dir:GetNormalized()
            local ang = dir:Angle()

            ang[1] = ang[1] + 90

            self:SetAngles(ang)
        end
    },

    DeterminateUseMin = -Vector(5,1.5,2),
    DeterminateUseMax = Vector(5,1.5,14),

    CenterModel = {Vector(0,0,-8),Angle(0,0,0)},
})