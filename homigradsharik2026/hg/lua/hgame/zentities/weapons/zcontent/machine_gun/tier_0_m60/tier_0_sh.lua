local SWEP = oop.Reg("wep_m60","hg_wep",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "M60E6"
SWEP.Category 				= L("weapon_category_rifle")
SWEP.IconOverride = "entities/arc9_eft_m60e6.png"

SWEP.Slot					= 2
SWEP.SlotPos				= 1

SWEP.HoldType = "ar2"

-- Model

SWEP.Primary.Automatic = true
SWEP.Primary.ChamberAuto = true

SWEP.Primary.Delay = 1 / 13
SWEP.Primary.Spread = 90 / 150
SWEP.Primary.DWRAmmo = "heavy"
SWEP.Primary.AmmoCalibre = "762x51"
SWEP.Primary.MagazineModel = "models/weapons/arc9/darsu_eft/mods/mag_pkm_dropped.mdl"
SWEP.Primary.ClipSize  = 100

SWEP.MuzzlePos = Vector(-1.1,0,0)

SWEP.MuzzleFlashScale = 2
SWEP.MuzzleGasForward = 3
SWEP.MuzzleGasSide = 2
SWEP.MuzzleGasAround = 0.8
SWEP.MuzzleGasBack = 0

SWEP.Primary.Sound = {
    outdoor_close = sound.CreateFormatedList("weapons/eft/m60/fire/m60_outdoor_close_",1,4,".ogg"),
    outdoor_distant = sound.CreateFormatedList("weapons/eft/m60/fire/m60_outdoor_distant_",1,2,".ogg"),
    indoor_close = sound.CreateFormatedList("weapons/eft/m60/fire/m60_indoor_close_",1,4,".ogg"),
    indoor_distant = sound.CreateFormatedList("weapons/eft/m60/fire/m60_indoor_distant_",1,2,".ogg"),

    outdoor_close_silence = sound.CreateFormatedList("weapons/eft/m60/fire/m60_silence_outdoor_close_",1,4,".ogg"),
    outdoor_distant_silence = sound.CreateFormatedList("weapons/eft/m60/fire/m60_silence_outdoor_distant_",1,2,".ogg"),
    indoor_close_silence = sound.CreateFormatedList("weapons/eft/m60/fire/m60_silence_indoor_close_",1,4,".ogg"),
    indoor_distant_silence = sound.CreateFormatedList("weapons/eft/m60/fire/m60_silence_indoor_distant_",1,2,".ogg")
}

SWEP.Primary.SoundEmpty = "weapons/eft/m60/pk_fire_dry_armed.ogg"
SWEP.FootstepSounds = weapons.SoundsSpinHeavy
SWEP.ScopeSounds = {
    volume = 1,
    listIn = {"weapons/ads/aim_on_machinegun_8.wav"},
    listOut = {"weapons/ads/aim_on_machinegun_9.wav"},
}

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_m60.mdl",
    vec = Vector(10,-5.6,-5),
    ang = Angle(-3,-2,0)
})

SWEP:TableLink("wmFastData",{
    model = "models/weapons/arc9/darsu_eft/c_m60.mdl",
    vec = Vector(9,0,-6),
    ang = Angle(5,0,180),
})

SWEP:TableLink("wmVeryFastData",{
    model = "models/weapons/w_mach_m249para.mdl",
    vec = Vector(10,0,-4.5),
    ang = Angle(5,0,180),
})

SWEP.dwsPos = Vector(-20,130,7)
SWEP.dwiSelectPos = Vector(-20,180,7)
SWEP.dwiPos = Vector(-18,100,-9)
SWEP.dwiAng = Angle(-45,0,0)

SWEP.vbwPos = Vector(4,-4,3)
SWEP.vbwAng = Angle(0,0,0)

SWEP.WorldModelCenter = {Vector(-19,4.25,3),Angle(0,0,0)}

-- Camera

SWEP.CameraPos = Vector(-36,0.02,2.5)
SWEP.CameraRecoil = 0
SWEP.recoilLerp = 0.2

-- Others

SWEP.MoveMulEquip = 0.6

SWEP.recoilAngUp = 0
SWEP.recoilAngUp_Scope = 0

SWEP.CameraMovementMul = 0.95
SWEP.CImersiveSetL = 1

SWEP.RecoilCameraMul = 0.5
SWEP.RecoilCameraMulScope = 0.2

SWEP.SprayAng = Angle(0.97,0.16,0)

SWEP.RecoilBackMul = 2

SWEP.ImmersiveAngleSetMul = 0.6
SWEP.ImmersiveAngleVelocityMul = 1.6
SWEP.ImmersiveAngleSmooth = 12
SWEP.ImmersiveAngleBreathMul = 1.7

function SWEP:GetShellDir()
	return Vector(math.Rand(125,175),math.Rand(90,160),math.Rand(-25,25))
end