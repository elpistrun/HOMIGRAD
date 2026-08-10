local SWEP = oop.Reg("wep_ar15","wep_ak74",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "AR-15"
SWEP.IconOverride = "entities/arc9_eft_m4a1.png"

-- Model

SWEP.Primary.Automatic = true
SWEP.Primary.ChamberAuto = true
SWEP.Primary.ChamberAutoReload = true

SWEP.Primary.Delay = 1 / 14
SWEP.Primary.Spread = 90 / 360
SWEP.Primary.AmmoCalibre = "556x45"
SWEP.Primary.MagazineModel = "models/weapons/arc9/darsu_eft/mods/mag_stanag_colt_ar15_std_556x45_30.mdl"
SWEP.Primary.MagazineModelAng = Angle(0,-90,0)
SWEP.Primary.ClipSize  = 30

SWEP.MuzzlePos = Vector(-18.2,0,0)

SWEP.Primary.Sound = {
    outdoor_close = sound.CreateFormatedList("weapons/eft/m4a1/fire/m4_outdoor_close_",1,4,".ogg"),
    outdoor_distant = sound.CreateFormatedList("weapons/eft/m4a1/fire/m4_outdoor_distant_",1,2,".ogg"),
    indoor_close = sound.CreateFormatedList("weapons/eft/m4a1/fire/m4_indoor_close_",1,4,".ogg"),
    indoor_distant = sound.CreateFormatedList("weapons/eft/m4a1/fire/hk416_indoor_distant_",1,2,".ogg"),

    outdoor_close_silence = sound.CreateFormatedList("weapons/eft/m4a1/fire/m4_silence_outdoor_close_",1,4,".ogg"),
    outdoor_distant_silence = sound.CreateFormatedList("weapons/eft/m4a1/fire/m4_silence_outdoor_distant_",1,2,".ogg"),
    indoor_close_silence = sound.CreateFormatedList("weapons/eft/m4a1/fire/m4_silence_indoor_close_",1,4,".ogg"),
    indoor_distant_silence = sound.CreateFormatedList("weapons/eft/m4a1/fire/m4_silence_indoor_distant_",1,2,".ogg")
}

SWEP.Primary.SoundEmpty = "weapons/eft/m4a1/mcx_magrelease_button.ogg"

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_m4a1.mdl",
    vec = Vector(12,-4,-4),
    ang = Angle(-3,0,0),
    chamberBodygroup = 1
})

SWEP:TableLink("wmFastData",{
    model = "models/weapons/arc9/darsu_eft/c_m4a1.mdl",
    vec = Vector(11,-0.5,-4.8),
    ang = Angle(5,5,180)
})

SWEP:TableLink("wmVeryFastData",{
    model = "models/weapons/w_rif_m4a1.mdl",
})

-- Camera

SWEP.CameraPos = Vector(-14,0,2)
