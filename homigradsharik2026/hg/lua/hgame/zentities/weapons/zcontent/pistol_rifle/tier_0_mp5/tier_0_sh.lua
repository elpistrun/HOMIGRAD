local SWEP = oop.Reg("wep_mp5","hg_wep",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "MP5"
SWEP.Category 				= L("weapon_category_pistol_rifle")
SWEP.IconOverride = "entities/arc9_eft_mp5.png"

SWEP.Slot					= 2
SWEP.SlotPos				= 1

SWEP.HoldType = "ar2"

-- Model

SWEP.Primary.Automatic = true
SWEP.Primary.ChamberAuto = true

SWEP.Primary.Delay = 1 / 16
SWEP.Primary.Spread = 90 / 190
SWEP.Primary.DWRName = "pistol"
SWEP.Primary.AmmoCalibre = "9x19"
SWEP.Primary.MagazineModel = "models/weapons/arc9/darsu_eft/mods/mag_mp5_hk_std_curved_9x19_30.mdl"
SWEP.Primary.MagazineModelAng = Angle(0,-90,0)
SWEP.Primary.ClipSize  = 30

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

SWEP.Primary.SoundEmpty = "weapons/eft/mp5/ar_jam_boltlock_grab1.ogg"
SWEP.FootstepSounds = weapons.SoundsSpinRifle
SWEP.ScopeSounds = {
    listIn = {"weapons/ads/aim_on_smg_10.wav"},
    listOut = {"weapons/ads/aim_on_smg_1.wav"},
}


SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_mp5.mdl",
    vec = Vector(13,-3,-4),
    ang = Angle(-3,0,0),
    chamberBodygroup = 7
})

SWEP:TableLink("wmFastData",{
    model = "models/weapons/arc9/darsu_eft/c_mp5.mdl",
    vec = Vector(13,0,-5),
    ang = Angle(5,0,180)
})

SWEP:TableLink("wmVeryFastData",{
    model = "models/weapons/w_smg_mp5.mdl",
    vec = Vector(7,0,-5),
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

SWEP.CameraPos = Vector(-23,0,1.8)
SWEP.CameraRecoil = 1

-- Others

SWEP.recoilLerp = 0.3

SWEP.MoveMulEquip = 0.95

function SWEP:GetShellDir()
	return Vector(math.Rand(125,175),math.Rand(5,5),-math.Rand(25,45))
end