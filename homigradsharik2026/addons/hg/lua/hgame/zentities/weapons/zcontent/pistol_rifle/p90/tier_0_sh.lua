local SWEP = oop.Reg("wep_p90","hg_wep",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "P90"
SWEP.Category 				= L("weapon_category_pistol_rifle")
SWEP.IconOverride = "entities/arc9_eft_fn_p90.png"

SWEP.Slot					= 2
SWEP.SlotPos				= 1

SWEP.HoldType = "ar2"

-- Model

SWEP.Primary.Automatic = true
SWEP.Primary.ChamberAuto = true
SWEP.Primary.ChamberAutoReload = false

SWEP.Primary.Delay = 1 / 18
SWEP.Primary.Spread = 90 / 190
SWEP.Primary.DWRName = "pistol"
SWEP.Primary.AmmoCalibre = "57x28"
SWEP.Primary.MagazineModel = "models/weapons/arc9/darsu_eft/mods/p90mag_tr.mdl"
SWEP.Primary.MagazineModelAng = Angle(0,-90,0)
SWEP.Primary.ClipSize = 50

SWEP.MuzzlePos = Vector(0.3,0,0)

SWEP.Primary.Sound = {
    outdoor_close = sound.CreateFormatedList("weapons/eft/mp5/fire/mp5_outdoor_close_",1,4,".ogg"),
    outdoor_distant = sound.CreateFormatedList("weapons/eft/mp5/fire/mp5_outdoor_distant_",1,2,".ogg"),
    indoor_close = sound.CreateFormatedList("weapons/eft/mp5/fire/mp5_indoor_close_",1,4,".ogg"),
    indoor_distant = sound.CreateFormatedList("weapons/eft/mp5/fire/mp5_indoor_distant_",1,2,".ogg"),

    outdoor_close_silence = sound.CreateFormatedList("weapons/eft/mp5/fire/mp5_silence_outdoor_close_",1,4,".ogg"),
    outdoor_distant_silence = sound.CreateFormatedList("weapons/eft/mp5/fire/mp5_silence_outdoor_distant_",1,2,".ogg"),
    indoor_close_silence = sound.CreateFormatedList("weapons/eft/mp5/fire/mp5_silence_indoor_close_",1,4,".ogg"),
    indoor_distant_silence = sound.CreateFormatedList("weapons/eft/mp5/fire/mp5_silence_indoor_distant_",1,2,".ogg")
}

SWEP.Primary.SoundEmpty = "weapons/eft/p90/p90_trigger_hammer.wav"
SWEP.FootstepSounds = weapons.SoundsSpinRifle
SWEP.ScopeSounds = {
    listIn = {"weapons/ads/aim_on_smg_10.wav"},
    listOut = {"weapons/ads/aim_on_smg_1.wav"},
}

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_p90.mdl",
    vec = Vector(13,-3,-4),
    ang = Angle(-3,0,0),
    chamberBodygroup = 10,
    chamberBodygroupActive = 0,
    chamberBodygroupNoActive = 1
})

SWEP:TableLink("wmFastData",{
    model = "models/weapons/arc9/darsu_eft/c_p90.mdl",
    vec = Vector(13,0,-5),
    ang = Angle(5,0,180)
})

SWEP:TableLink("wmVeryFastData",{
    model = "models/weapons/w_smg_p90.mdl",
    vec = Vector(8,-0.5,-5),
    ang = Angle(5,0,180)
})

SWEP.dwsPos = Vector(-12,70,4.6)
SWEP.dwiSelectPos = Vector(-12,150,4.6)
SWEP.dwiPos = Vector(-12,60,-5)
SWEP.dwiAng = Angle(-45,0,0)

SWEP.vbwPos = Vector(9,-4,0)
SWEP.vbwAng = Angle(0,0,0)

SWEP.WorldModelCenter = {Vector(-19,4.25,3),Angle(0,0,0)}

-- Camera

SWEP.CameraPos = Vector(-23,0,3.2)
SWEP.CameraRecoil = 0.3

SWEP.recoilBackMul = 1
-- Others

SWEP.recoilLerp = 0.1

SWEP.MoveMulEquip = 0.95

function SWEP:GetShellDir()
	return Vector(math.Rand(125,175),math.Rand(5,5),-math.Rand(25,45))
end

function SWEP:RejectShell() end