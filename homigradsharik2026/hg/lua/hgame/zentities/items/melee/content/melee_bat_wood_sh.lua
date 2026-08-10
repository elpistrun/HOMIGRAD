local SWEP = oop.Reg("wep_melee_bat_wood","wep_melee_base")
if not SWEP then return end

SWEP.PrintName = "Bat Wood"
SWEP.itemType = "meleePrimary"

SWEP.BlockSecondaryWeapon = true

SWEP.dwiPos = Vector(7.6,-55,-7.8)
SWEP.dwsAng = Angle(45,180,0)
SWEP.dwsPos = Vector(7.6,-66,-7.8)

SWEP.vbwUseWMDropData = true
SWEP.vbwIsHolster = true
SWEP.vbwPos = Vector(-7,2,0)
SWEP.vbwAng = Angle(0,-5,90)

SWEP.Primary.Delay = 1

SWEP.Primary.Damage = 14
SWEP.Primary.DamageImpulse = 0.1
SWEP.Primary.Force = 300
SWEP.Primary.ForceRagdoll = SWEP.Primary.Force * 20
SWEP.Primary.MultiAttack = 6

SWEP.Primary.DamageType = DMG_BLAST
SWEP.Primary.SoundHit = {
    list = {
        "weapons/melee/bat/sfx_bat_impact_01.wav",
        "weapons/melee/bat/sfx_bat_impact_02.wav",
        "weapons/melee/bat/sfx_bat_impact_03.wav",
        "weapons/melee/bat/sfx_bat_impact_04.wav",
        "weapons/melee/bat/sfx_bat_impact_05.wav",
        "weapons/melee/bat/sfx_bat_impact_06.wav",
        "weapons/melee/bat/sfx_bat_impact_07.wav",
        "weapons/melee/bat/sfx_bat_impact_08.wav",
        "weapons/melee/bat/sfx_bat_impact_09.wav",
        "weapons/melee/bat/sfx_bat_impact_10.wav"
    },
    volume = 1
}

SWEP.Secondary.Damage = 14
SWEP.Secondary.DamageImpulse = 0.1
SWEP.Secondary.Force = 300
SWEP.Secondary.ForceRagdoll = SWEP.Secondary.Force * 20
SWEP.Secondary.MultiAttack = 6

SWEP.Secondary.DamageType = DMG_BLAST
SWEP.Secondary.SoundHit = {
    list = {
        "weapons/melee/bat/sfx_bat_impact_01.wav",
        "weapons/melee/bat/sfx_bat_impact_02.wav",
        "weapons/melee/bat/sfx_bat_impact_03.wav",
        "weapons/melee/bat/sfx_bat_impact_04.wav",
        "weapons/melee/bat/sfx_bat_impact_05.wav",
        "weapons/melee/bat/sfx_bat_impact_06.wav",
        "weapons/melee/bat/sfx_bat_impact_07.wav",
        "weapons/melee/bat/sfx_bat_impact_08.wav",
        "weapons/melee/bat/sfx_bat_impact_09.wav",
        "weapons/melee/bat/sfx_bat_impact_10.wav"
    },
    volume = 1
}

SWEP.Secondary.Throw = "melee_bat"

SWEP.wmDropData = {model = "models/weapons/tfa_nmrih/w_bat.mdl"}

SWEP.CorrectiveDropInfo = {
    bone = "root",
    vec = Vector(0,0,0),
    ang = Angle(0,0,0)
}

SWEP.HoldType = "revolver"

SWEP:TableLink("wmData",{
    model = "models/weapons/c_battlebat.mdl",
    vec = Vector(-22,3,-10),
    ang = Angle(0,0,0)
})

SWEP.textureUVBlood_X = 0.38
SWEP.textureUVBlood_Y = 0.2

SWEP.TPIKLerpWhitelist = {
    ["melee"] = true
}

SWEP.CorrectiveDropInfo = {
    bone = "melee",
    vec = Vector(0,0,0),
    ang = Angle(0,0,0)
}

SWEP.AnimationList = {
    ["deploy"] = {
        index = 1,
        delay = 0.5,
        startCycle = 0,
        endCycle = 0.3,
        sound = {
            [0] = {{{"weapons/melee/bat/sfx_bat_equip.wav"},75,1,110}}
        }
    },
    ["holster"] = {
        index = 2,
        delay = 0.5
    }
}

local graphCameraAngle = {
    {0,Angle(0,0,0)},
    {0.22,Angle(3,-6,6)},
    {0.23,Angle(-3,12,-6)},
    {0.4,Angle()},
}

function SWEP:DoInputAttackClient(cmd)
    if cmd.type == "primary" then
        if self:IsCooldown("attack2") then
            cmd.name = "attack_primary2"

            self:SetCooldown("attack2",0)
        else
            self:SetCooldown("attack2",self.Primary.Delay + 0.1)
        end
    else
        cmd.name = "attack_throw"
    end

    self:DoAction(cmd)
end

SWEP.AnimationList["attack_primary"] = {
    index = 5,
    delay = 1,
    endCycle = 0.4,

    Start = function(self)
        local ply = self.parent:GetOwner()
        ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD,ply:LookupSequence("range_melee"),-self.delay * 0.1,true)
        ply:SetLayerDuration(GESTURE_SLOT_ATTACK_AND_RELOAD,self.delay * 1)
        ply:SetLayerWeight(GESTURE_SLOT_ATTACK_AND_RELOAD,0.33)
    end,

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)

    end,

    OnChangeCamera = function(self,pos,ang)
        ang:Add(math.EvalGraphAngle(self:GetCycle("animation"),graphCameraAngle))
    end,

    sound = {
        [0.03] = {{"weapons/melee/matelbat/bat_holster.wav",75,0.8,100}},
        [0.16] = {
            {{"weapons/melee/scythe_whoosh_01.ogg","weapons/melee/scythe_whoosh_02.ogg","weapons/melee/scythe_whoosh_03.ogg"},75,1,100},
            {{"weapons/melee/bat/baseball_swing_1st_layer_01.wav","weapons/melee/bat/baseball_swing_1st_layer_02.wav","weapons/melee/bat/baseball_swing_1st_layer_03.wav","weapons/melee/bat/baseball_swing_1st_layer_04.wav"},75,0.7,100}
        },
    },

    movementMul = 0.8,

    load = 0.47,
    attackPosStart = Vector(0,0,-3),
    attackPosEnd = Vector(55,0,-3),

    hitboxMins = -Vector(12,12,3),
    hitboxMaxs = Vector(12,12,3),
}

SWEP:ConstructAnimationAction("attack_primary2",
    function(object,cmd)
        local self = object

        self:SetCooldown("attack",self.Primary.Delay)

        local sequenceObject = self:PlayAnimation("attack_primary2")
        sequenceObject.typeAttack = "Primary"
        
        if SERVER then self:SyncAnimation() end

        return true
    end,
    function(self,anim)
        anim.Load = self[1].anm_ActionLoad
    end,
    true
)

local graphCameraAngle = {
    {0,Angle(0,0,0)},
    {0.09,Angle(3,6,-6)},
    {0.1,Angle(-3,-12,6)},
    {0.4,Angle()},
}

SWEP.AnimationList["attack_primary2"] = {
    index = 10,
    delay = 1,
    endCycle = 0.4,

    Start = function(self)
        self.parent:SetHoldType("ar2")
    end,

    Step = function(self)
        if self:GetMarkEmit("changeHoldType") then
            self.parent:SetHoldType(self.parent.HoldType)
        end
    end,

    changeHoldType = {[0.2] = true},

    Stop = function(self)
        self.parent:SetHoldType(self.parent.HoldType)
    end,

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        --wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
    end,

    OnChangeCamera = function(self,pos,ang)
        ang:Add(math.EvalGraphAngle(self:GetCycle("animation"),graphCameraAngle))
    end,

    sound = {
        [0] = {{"weapons/melee/matelbat/bat_holster.wav",75,0.8,100}},
        [0.05] = {
            {{"weapons/melee/scythe_whoosh_01.ogg","weapons/melee/scythe_whoosh_02.ogg","weapons/melee/scythe_whoosh_03.ogg"},75,1,120},
            {{"weapons/melee/bat/baseball_swing_1st_layer_01.wav","weapons/melee/bat/baseball_swing_1st_layer_02.wav","weapons/melee/bat/baseball_swing_1st_layer_03.wav","weapons/melee/bat/baseball_swing_1st_layer_04.wav"},75,0.7,110}
        },
    },

    movementMul = 0.8,

    load = 0.2,
    attackPosStart = Vector(0,8,4),
    attackPosEnd = Vector(55,8,4),

    hitboxMins = -Vector(12,12,3),
    hitboxMaxs = Vector(12,12,3),
}

local graphAngle = {
    {0,Angle()},
    {0.15,Angle(0,0,0)}
}

SWEP.AnimationList["attack_throw_start"] = {
    index = 5,
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
       -- wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
    end,

    movementMul = 0.6,
    skip = 1.3,
}

SWEP.AnimationList["attack_throw"] = {
    index = 5,
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
    index = 5,
    delay = 0.5,
    endCycle = 0.2,
    inversion = true,

    sound = {
        [0] = {
            {{"weapons/handling_csgo/aug_zoom_out.wav",75,1,100}}
        }
    },

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        --wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
    end,

    movementMul = 0.6
}

function SWEP:PreHit(dmgTab)
    if dmgTab.target:IsPlayer() then
        if dmgTab.target:Health() - dmgTab.dmg <= 33 then
            dmgTab.headshootForce = true
        end
    else
        dmgTab.headshootForce = true
    end
end

function SWEP:PostHit(dmgTab)
    local ent = dmgTab.rag or dmgTab.ent

    if dmgTab.breakHead then
        self:SetPVSVar("IsBlooded",true)
        inventoryGame.SyncItemByEntity(self)
    end
end

SWEP.AnimationInspectList = {}

ammoGame.Reg({
    name = "melee_bat",
    AmmoCalibre = "melee",

    bulletInfo = {
        Speed = 15,
        Diametr = 9,
        Mass = 50,

        MultiplySpeed = 1,
        DoNotCrack = true,

        FlySound = {
            list = {"weapons/melee/fly.ogg"},
            volume = 0.6,
            level = 75,
            pitch = 100
        },

        TraceManual = {
            Vector(0,0,0),
            Vector(0,0,-8),
            Vector(0,0,8)
        },

        Think = function(self)
            if self:GetPVSVar("Hit") then return end
            
            local ang = self.dir:GetNormalized():Angle()

            ang[1] = ang[1] + (CurTime() * self.dir:Length()) % 360

            self:SetAngles(ang)
        end,

        HitEnd = function(self,traceResult)
            if SERVER then self:CreatePhysics() end
            
            self:Remove()
        end,
    },

    DeterminateUseMin = -Vector(5,1.5,2),
    DeterminateUseMax = Vector(5,1.5,14),

    CenterModel = {Vector(0,0,-8),Angle(0,0,0)},
})