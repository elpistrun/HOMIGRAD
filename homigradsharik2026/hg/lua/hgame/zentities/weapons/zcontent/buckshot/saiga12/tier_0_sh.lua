local SWEP = oop.Reg("wep_saiga12k","hg_wep",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "Сайга-12K"
SWEP.Category 				= L("weapon_category_buckshoot")
SWEP.IconOverride = "entities/arc9_eft_saiga12k.png"

SWEP.Slot					= 2
SWEP.SlotPos				= 0

SWEP.HoldType = "ar2"

-- Model

SWEP.Primary.Automatic = false
SWEP.Primary.ChamberAuto = true

SWEP.Primary.Delay = 1 / 3.5
SWEP.Primary.Spread = 90 / 70
SWEP.Primary.DWRName = "buckshoot"
SWEP.Primary.AmmoCalibre = "12x70"
SWEP.Primary.MagazineModel = "models/weapons/arc9/darsu_eft/mods/mag_saiga12_std.mdl"
SWEP.Primary.MagazineModelAng = Angle(0,-90,0)
SWEP.Primary.MagazineModelPos = Vector(0,0,-6.2)
SWEP.Primary.ClipSize = 12

SWEP.MuzzlePos = Vector(1,0,0)

SWEP.MuzzleFlashScale = 2
SWEP.MuzzleGasForward = 3
SWEP.MuzzleGasSide = 2
SWEP.MuzzleGasAround = 0.8
SWEP.MuzzleGasBack = 0

SWEP.Primary.SoundPitch = 96
SWEP.Primary.Sound = {
    outdoor_close = sound.CreateFormatedList("weapons/eft/ak/fire/saiga12_outdoor_close_",1,4,".ogg"),
    outdoor_distant = sound.CreateFormatedList("weapons/eft/ak/fire/saiga12_outdoor_distant_",1,2,".ogg"),
    indoor_close = sound.CreateFormatedList("weapons/eft/ak/fire/saiga12_indoor_close_",1,4,".ogg"),
    indoor_distant = sound.CreateFormatedList("weapons/eft/ak/fire_new/saiga12_indoor_distant_",1,2,".ogg"),

    outdoor_close_silence = sound.CreateFormatedList("weapons/eft/ak/fire/saiga12_indoor_close_silenced_",1,34,".ogg"),
    outdoor_distant_silence = sound.CreateFormatedList("weapons/eft/ak/fire/saiga12_indoor_distant_silenced_",1,2,".ogg"),
    indoor_close_silence = sound.CreateFormatedList("weapons/eft/ak/fire/saiga12_outdoor_close_silenced_",1,4,".ogg"),
    indoor_distant_silence = sound.CreateFormatedList("weapons/eft/ak/fire/saiga12_outdoor_distant_silenced_",1,2,".ogg")
}

SWEP.Primary.SoundEmpty = "weapons/eft/ak/ak74_trigger_empty.wav"
SWEP.FootstepSounds = weapons.SoundsSpinRifle

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_saiga12k.mdl",
    vec = Vector(12,-4,-3.5),
    ang = Angle(-3,0,0),
    chamberBodygroup = 7
})

SWEP:TableLink("wmFastData",{
    model = "models/weapons/arc9/darsu_eft/c_saiga12k.mdl",
    vec = Vector(9,-1.5,-4),
    ang = Angle(5,5,180)
})

SWEP:TableLink("wmVeryFastData",{
    model = "models/weapons/w_shot_xm1014.mdl",
    vec = Vector(11,-0.8,-6),
    ang = Angle(10,1,180)
})

SWEP.dwsPos = Vector(-21,100,4.6)
SWEP.dwiSelectPos = Vector(-21,150,4.6)
SWEP.dwiPos = Vector(-19,90,-13)
SWEP.dwiAng = Angle(-45,0,0)

SWEP.vbwPos = Vector(2,-4,0)

SWEP.WorldModelCenter = {Vector(-19,4.25,3),Angle(0,0,0)}

-- Camera

SWEP.CameraPos = Vector(-30,0,1.68)
SWEP.CR_Scope = 4
SWEP.CameraRecoil = -1
SWEP.CameraRecoil_Scope = -2

-- Others

SWEP.MoveMulEquip = 0.95

SWEP.recoilLerp = 0.1

SWEP.MuzzleFlashScale = 2
SWEP.MuzzleGasTimeScale = 3
SWEP.MuzzleGasAround = 3

function SWEP:DoAnimationRecoil(wmAngle,wmVector)
    local recoil = self.recoil
    local scopeLerp = self.scopeLerp
    local abs = self.recoilRandAbs

    wmAngle[1] = wmAngle[1] - recoil * 3 - math.ease.InBounce(recoil) * 12
    wmAngle[2] = wmAngle[2] - recoil * 1
end

function SWEP:GetShellDir()
	return Vector(math.Rand(125,175),math.Rand(5,5),math.Rand(-25,25))
end

SWEP.SprayAng = Angle(6,-1,0)

SWEP.recoilBackMul = 4