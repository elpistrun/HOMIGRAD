local SWEP = oop.Reg("wep_melee_evangelion_low","wep_melee_base")
if not SWEP then return end

SWEP.PrintName = "Longinus Evangelion Low"
SWEP.itemType = "meleePrimary"

SWEP.dwiPos = Vector(0,-350,0)
SWEP.dwsAng = Angle(0,90,45)
SWEP.dwsPos = Vector(0,-400,0)

SWEP.vbwUseWMDropData = true
SWEP.vbwIsHolster = false
SWEP.vbwPos = Vector(-2,-6,-3.3)
SWEP.vbwAng = Angle(0,-90,20)

SWEP.Primary.Delay = 1.2
SWEP.Primary.DamageType = DMG_BLAST
SWEP.Primary.Damage = 100
SWEP.Primary.DamagePain = 10
SWEP.Primary.DamageImpulse = 1.1
SWEP.Primary.Force = 2000
SWEP.Primary.ForceRagdoll = SWEP.Primary.Force * 10
SWEP.Primary.Volume = 1

SWEP.Primary.SoundHitFlesh = {
    pitch = 80,
    volume = 1,
    list = {"weapons/melee/hammer_hit_body1.ogg","weapons/melee/hammer_hit_body2.ogg"}
}

SWEP.Primary.SoundHit = {
    pitch = 80,
    volume = 1,
    list = {"weapons/melee/hammer_hit_wall1.ogg","weapons/melee/hammer_hit_wall2.ogg"}
}

SWEP.Secondary.Delay = 1
SWEP.Secondary.DamageType = DMG_SLASH
SWEP.Secondary.Damage = 100
SWEP.Secondary.DamagePain = 60
SWEP.Secondary.DamageImpulse = 1
SWEP.Secondary.Force = 1000
SWEP.Secondary.ForceRagdoll = SWEP.Primary.Force * 10
SWEP.Secondary.Throw = "melee_longinus_low"

SWEP.wmDropData = {model = "models/evangelion/w_spear_longinus.mdl"}

SWEP:TableLink("wmData",{
    model = "models/evangelion/c_spear_longinus.mdl",
    vec = Vector(-19,0,-8),
    ang = Angle(0,0,0)
})

SWEP.TPIKLerpWhitelist = {
    ["c_weapon_longinus_root"] = true
}

SWEP.CorrectiveDropInfo = {
    bone = "c_weapon_longinus_root",
    vec = Vector(0,0,0),
    ang = Angle(0,0,0)
}

SWEP.AnimationList = {
    ["deploy"] = {
        index = 0,
        delay = 0.5,
    },
    ["holster"] = {
        index = 0,
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
    {1,Angle()},
}

local graphVector = {
    {0,Vector(0,0,0)},
    {0.3,Vector(-6,0,0)},
    {0.4,Vector(32,0,0)},
    {1,Vector(0,0,0)},
}

local graphCameraAngle = {
    {0,Angle(0,0,0)},
    {0.7,Angle()},
}

SWEP.HoldType = "melee"

SWEP.AnimationList["attack_primary"] = {
    index = 0,
    delay = 1,
    
    skip = 0.9,

    load = 0.3,

    attackPosStart = Vector(0,0,0),
    attackPosEnd = Vector(PlayerDisUse * 1,0,0),

    hitboxMins = -Vector(5,5,6),
    hitboxMaxs = Vector(5,5,4),

    sound = {
        [0.08] = {{"weapons/melee/matelbat/bat_draw.wav",75,0.6,90}},
        [0.22] = {{{"weapons/melee/bat/baseball_swing_1st_layer_01.wav","weapons/melee/bat/baseball_swing_1st_layer_02.wav","weapons/melee/bat/baseball_swing_1st_layer_03.wav","weapons/melee/bat/baseball_swing_1st_layer_04.wav"},75,1,80}},
        [0.24] = {{{"weapons/melee/hammer_swing1.ogg","weapons/melee/hammer_swing1.ogg","weapons/melee/hammer_swing3.ogg"},75,1,100}},
    },

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
        wmVector:Add(math.EvalGraphVector(self:GetCycle("animation"),graphVector))
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
    {0.15,Angle(0,0,30)},
}

local graphVector = {
    {0,Vector()},
    {0.15,Vector(0,0,0)},
}

SWEP.AnimationList["attack_throw_start"] = {
    index = 3,
    delay = 0.5,
    endCycle = 0.9,
    endless = true,

    sound = {
        [0] = {
            {{"weapons/handling_csgo/aug_zoom_in.wav"},75,1,100},
        },
    },

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
        wmVector:Set(math.EvalGraphVector(self:GetCycle("animation"),graphVector))
    end,

    movementMul = 0.89,
    skip = 1.3,
}

SWEP.AnimationList["attack_throw"] = {
    index = 3,
    delay = 0.5,
    endless = true,

    sound = {
        [0] = {
            {{"weapons/melee/scythe_whoosh_01.ogg","weapons/melee/scythe_whoosh_02.ogg","weapons/melee/scythe_whoosh_03.ogg"},120,1,200},
            {{"weapons/melee/bat/baseball_swing_1st_layer_01.wav","weapons/melee/bat/baseball_swing_1st_layer_02.wav","weapons/melee/bat/baseball_swing_1st_layer_03.wav","weapons/melee/bat/baseball_swing_1st_layer_04.wav"},120,1,200}
        },
    },

    movementMul = 0,
    movementMulGraph = {
        {0,1}
    },

    Start = function(self)
    end,

    skip = 0.1
}

SWEP.AnimationList["attack_throw_stop"] = {
    index = 3,
    delay = 0.5,
    endCycle = 0.9,
    inversion = true,

    sound = {
        [0] = {
            {{"weapons/handling_csgo/aug_zoom_out.wav",75,1,100}}
        }
    },

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
        wmVector:Set(math.EvalGraphVector(self:GetCycle("animation"),graphVector))
    end,

    movementMul = 0.6
}

ammoGame.Reg({
    name = "melee_longinus_low",
    AmmoCalibre = "melee",

    bulletInfo = {
        AlwaysReplicate = true,
        Speed = 80,
        Diametr = 48,
        Mass = 700,

        MultiplySpeed = 1,

        FlySound = {
            list = {"homigrad/wind/woosh0.wav"},
            volume = 1,
            level = 120,
            pitch = 100
        },

        TraceManual = {
            Vector(0,0,0),
            Vector(0,0,-2),
            Vector(0,0,2)
        },

        Think = function(self)
            if self:GetPVSVar("Hit") then return end
            
            local ang = self.dir:GetNormalized():Angle()
            ang:RotateAroundAxis(ang:Up(),-90)
            self:SetAngles(ang)
        end,

        HitEnd = function(self,traceResult)
            local ang = self.dir:GetNormalized():Angle()
            ang:RotateAroundAxis(ang:Up(),-90)
            self:SetAngles(ang)
        end
    },

    DeterminateUseMin = -Vector(6,60,6),
    DeterminateUseMax = Vector(6,90,6),

    CenterModel = {Vector(0,-49,0),Angle(0,0,0)},
})

local recipientFilter = SERVER and RecipientFilter()

function SWEP:HitPost(result,typeAttack,surfaceName)
    if CLIENT then return end

    local pos = result.HitPos

    for i = 1,1 do
        surfaceWorld.CreateEffectBullet_Net(pos + Vector(0,math.Rand(-10,10),math.Rand(-10,10)):Rotate(result.HitNormal:Angle()),result.HitNormal,result.Entity,surfaceName,6)
        recipientFilter:AddPVS(result.HitPos)
        net.Send(recipientFilter)
    end

    Explosive_WreckBuildings(nil,result.HitPos,0.6,100,true,true)
    Explosive_BlastDoors(nil,result.HitPos,1,100,true)

    Explosive_BlastThatDoor(result.Entity,result.Normal * 1000)
end
