local SWEP = oop.Reg("wep_glock_17","wep_m9a3",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "Glock 17"
SWEP.Category 				= L("weapon_category_pistol")
SWEP.IconOverride = "entities/arc9_eft_glock17.png"

-- Model

SWEP.Primary.Automatic = false
SWEP.Primary.ChamberAuto = true

SWEP.Primary.Delay = 1 / 13
SWEP.Primary.Spread = 90 / 170
SWEP.Primary.AmmoCalibre = "9x19"
SWEP.Primary.DWRName = "pistol"

SWEP.Primary.Sound = {
    outdoor_close = sound.CreateFormatedList("weapons/eft/glock/glock17_outdoor_close_",1,3,".ogg"),
    outdoor_distant = sound.CreateFormatedList("weapons/eft/glock/glock17_outdoor_distant_",1,2,".ogg"),
    indoor_close = sound.CreateFormatedList("weapons/eft/glock/glock17_indoor_close_",1,1,".ogg"),
    indoor_distant = sound.CreateFormatedList("weapons/eft/glock/glock17_indoor_distant_",1,1,".ogg"),

    outdoor_close_silence = sound.CreateFormatedList("weapons/eft/glock/glock17_silence_outdoor_close_",1,2,".ogg"),
    outdoor_distant_silence = sound.CreateFormatedList("weapons/eft/glock/glock17_silence_outdoor_distant_",1,1,".ogg"),
    indoor_close_silence = sound.CreateFormatedList("weapons/eft/glock/glock17_silence_indoor_close_",1,1,".ogg"),
    indoor_distant_silence = sound.CreateFormatedList("weapons/eft/glock/glock17_silence_indoor_distant_",1,1,".ogg"),
}

SWEP.Primary.SoundEmpty = "weapons/eft/generic_pistol/pm_trigger_hammer.wav"

SWEP.Primary.MagazineModel = "models/weapons/arc9/darsu_eft/mods/mag_glock_pmag_21.mdl"
SWEP.Primary.MagazineModelAng = Angle(0,-90,0)
SWEP.Primary.ClipSize = 30

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_glock.mdl",
    vec = Vector(13,-4,-2.8),
    ang = Angle(-3,0,0),
    chamberBodygroup = 8
})

SWEP:TableLink("wmFastData",{
    vec = Vector(3,-1,-3),
    ang = Angle(0,0,180)
})

SWEP.dwsPos = Vector(-24,50,3.8)
SWEP.dwiSelectPos = Vector(-24,100,3.8)
SWEP.dwiPos = Vector(-19,45,-14)
SWEP.dwiAng = Angle(-45,0,0)

SWEP.PhysicsBox = {-Vector(7,1,5),Vector(8,1,2.5)}
SWEP.WorldModelCenter = {Vector(-19,4.25,3),Angle(0,0,0)}

-- Camera

SWEP.CameraPos = Vector(-25,-0.055,0.7)
SWEP.CameraRecoil = -3
SWEP.RecoilCameraMulScope = -3

-- Others

SWEP.MoveMulEquip = 0.95

SWEP.recoilLerp = 0.33

SWEP.SprayAng = Angle(1,0,0)

SWEP.recoilBackMul = 3