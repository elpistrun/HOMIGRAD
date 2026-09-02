local SWEP = oop.Reg("wep_melee_dagger","wep_melee_base")
if not SWEP then return end

SWEP.PrintName = "Dagger"

SWEP.dwiPos = Vector(1.5,-20,-1.5)
SWEP.dwsAng = Angle(45,180,0)
SWEP.dwsPos = Vector(1.5,-20,-1.5)

SWEP.Primary.Delay = 0.5
SWEP.Primary.DamageType = DMG_SLASH
SWEP.Primary.Damage = 9
SWEP.Primary.DamagePain = 10
SWEP.Primary.MultiAttack = 2
SWEP.Primary.DontBleedArtery = true

SWEP.Primary.SoundHitFlesh = {
    list = {
        "weapons/melee/slash_hit1.ogg","weapons/melee/slash_hit2.ogg"
    },
    pitch = 125,
    volume = 0.3,
}

SWEP.Secondary.Delay = 0.9
SWEP.Secondary.DamageType = DMG_SLASH
SWEP.Secondary.Damage = 13

SWEP.HoldType = "melee"
SWEP.EnableBlooded = true
SWEP.EnableBulletDecal = true

function SWEP:TextureUV_PaintBlood(w,h)
    local unlitGeneric = gibParticles.bloodDrop.unlitGeneric
    
    for i = 1,#unlitGeneric do
        surface.SetMaterial(unlitGeneric[i])
        surface.SetDrawColor(255,0,0)
        surface.DrawTexturedRect(w * 0,h * 0.5,w,h)
    end

    surface.SetMaterial(unlitGeneric[5])
    surface.SetDrawColor(255,0,0)
    surface.DrawTexturedRect(w * 0.5,h * -0,w * 0.7,h * 0.7)


    surface.SetMaterial(unlitGeneric[5])
    surface.SetDrawColor(255,0,0)
    surface.DrawTexturedRect(w * 0.1,h * 0.33,w * 0.7,h * 0.7)
end

SWEP.wmDropData = {model = "models/weapons/arc9/darsu_eft/w_melee_dagger.mdl"}

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_melee_dagger.mdl",
    vec = Vector(-10,0,0),
    ang = Angle(0,0,0)
})

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
    {0.3,Angle(0,0,0)},
    {0.5,Angle(-3,7,0)},
    {1,Angle()},
}

local graphCameraAngle = {
    {0,Angle(0,0,0)},
    {0.3,Angle(3,-3,6)},
    {0.4,Angle(-1,5,-5)},
    {0.7,Angle()},
}

SWEP.AnimationList["attack_secondary"] = {
    index = 6,
    delay = 0.8,

    endCycle = 0.6,

    load = 0.65,

    attackPosStart = Vector(0,0,0),
    attackPosEnd = Vector(PlayerDisUse * 0.6,0,-3),

    hitboxMins = Vector(0,-1,-1),
    hitboxMaxs = Vector(0,1,1),

    sound = {
        [0.18] = {{"weapons/melee/matelbat/bat_draw.wav",75,0.6}},
        [0.2] = {{{"weapons/melee/knife_bayonet_swing1.ogg","weapons/melee/knife_bayonet_swing2.ogg"},75,0.5,150}}
    },

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
    end,
    
    OnChangeCamera = function(self,pos,ang)
        ang:Add(math.EvalGraphAngle(self:GetCycle("animation"),graphCameraAngle))
    end,

    movementMul = 0.9
}

local graphAngle = {
    {0,Angle()},
    {0.3,Angle(0,0,0)},
    {0.5,Angle(-15,0,0)},
    {1,Angle()},
}

local graphCameraAngle = {
    {0,Angle(0,0,0)},
    {0.3,Angle(3,-3,6)},
    {0.4,Angle(-1,5,-5)},
    {0.7,Angle()},
}

SWEP.AnimationList["attack_primary"] = {
    index = 4,
    delay = 0.6,

    endCycle = 0.6,

    load = 0.5,

    attackPosStart = Vector(0,0,0),
    attackPosEnd = Vector(PlayerDisUse * 0.6,0,-3),

    hitboxMins = Vector(0,-6,-1),
    hitboxMaxs = Vector(0,6,1),

    sound = {
        [0.18] = {{"weapons/melee/matelbat/bat_draw.wav",75,0.6}},
        [0.2] = {{{"weapons/melee/knife_bayonet_swing1.ogg","weapons/melee/knife_bayonet_swing2.ogg"},75,1,100}}
    },

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
    end,

    OnChangeCamera = function(self,pos,ang)
        ang:Add(math.EvalGraphAngle(self:GetCycle("animation"),graphCameraAngle))
    end,

    movementMul = 0.9
}