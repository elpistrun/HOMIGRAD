local SWEP = oop.Reg("wep_m32a1","wep_rsh12",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "M32A1"
SWEP.Category 				= L("weapon_category_explosive")
SWEP.IconOverride = "entities/arc9_eft_m32a1.png"

SWEP.Slot					= 2
SWEP.SlotPos				= 1
SWEP.itemCategory = "weapon"
SWEP.weaponLimitType = "secondary"

SWEP.HoldType = "ar2"

-- Model

SWEP.Primary.ClipSize  = 6
SWEP.Primary.Automatic = true

SWEP.Primary.Delay = 1 / 6
SWEP.Primary.Spread = 90 / 190
SWEP.Primary.AmmoDWR = "pistol"
SWEP.Primary.AmmoCalibre = "40mm"

SWEP.MuzzlePos = Vector(0,-27,-0.7)
SWEP.MuzzleAng = Angle(0,-90,0)

function SWEP:GetShootMatrix(wm)
    local wm = wm or self:GetWorldModel()
    if not wm then return self:GetPos(),self:GetAngles() end

    local mat = wm:GetBoneMatrix(wm:LookupBone("weapon"))
    if not mat then return self:GetPos(),self:GetAngles() end

    return LocalToWorld(self.MuzzlePos,self.MuzzleAng,mat:GetTranslation(),mat:GetAngles())
end

SWEP.Primary.Sound = {
    outdoor_close = {
        "weapons/eft/m203/m203_fire_outdoor_close.ogg"
    },
    outdoor_distant = {
        "weapons/eft/m203/m203_fire_outdoor_distant.ogg",
    },

    --

    indoor_close = {
        "weapons/eft/m203/m203_fire_indoor_close.ogg"
    },
    indoor_distant = {
        "weapons/eft/m203/m203_fire_indoor_distant.ogg"
    }
}

SWEP.Primary.SoundEmpty = "weapons/eft/m203/m203_trigger.ogg"
SWEP.FootstepSounds = weapons.SoundsSpinRifle

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_m32a1.mdl",
    vec = Vector(12,-4,-3),
    ang = Angle(-3,0,0),
    chamberBodygroup = 3
})

SWEP:TableLink("wmFastData",{
    model = "models/weapons/arc9/darsu_eft/c_m32a1.mdl",
    vec = Vector(13,0,-5),
    ang = Angle(5,0,180)
})

SWEP:TableLink("wmVeryFastData",{
    model = "models/weapons/w_rocket_launcher.mdl",
    vec = Vector(-5,-2,-6),
    ang = Angle(5,0,180)
})

SWEP.dwsPos = Vector(-12,70,4.6)
SWEP.dwiSelectPos = Vector(-12,150,4.6)
SWEP.dwiPos = Vector(-12,60,-5)
SWEP.dwiAng = Angle(-45,0,0)

SWEP.vbwPos = Vector(8,-8,2)
SWEP.vbwAng = Angle(0,-90,180)

SWEP.WorldModelCenter = {Vector(-19,4.25,3),Angle(0,0,0)}

-- Camera

SWEP.CameraPos = Vector(-20,-0.2,3)
SWEP.CameraRecoil = -4

-- Others

SWEP.SprayAng = Angle(18,0,0)

SWEP.recoilLerp = 0.12

SWEP.MoveMulEquip = 0.8

SWEP.RecoilBackMul = 4

SWEP.ShellBoneIndex = {
    "patron_in_weapon_000",
    "patron_in_weapon_001",
    "patron_in_weapon_002",
    "patron_in_weapon_003",
    "patron_in_weapon_004",
    "patron_in_weapon_005",
}