local SWEP = oop.Reg("wep_asval","wep_ak74",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = "ASVAL"
SWEP.IconOverride = "entities/arc9_eft_asval.png"

-- Model

SWEP.Primary.Automatic = true
SWEP.Primary.ChamberAuto = true

SWEP.Primary.Delay = 1 / 14.8
SWEP.Primary.Spread = 90 / 360
SWEP.Primary.AmmoCalibre = "9x39"
SWEP.Primary.MagazineModel = "models/weapons/arc9/darsu_eft/mods/mag_val2_20.mdl"
SWEP.Primary.MagazineModelAng = Angle(0,-90,0)
SWEP.Primary.MagazineModelPos = Vector(0,-0.16,-0.2)
SWEP.Primary.ClipSize  = 30

SWEP.Primary.Silencer = true
SWEP.MuzzleFlashScale = false
SWEP.MuzzleGasSide = false
SWEP.MuzzleGasForward = 3

SWEP.MuzzlePos = Vector(0.5,0,0)

SWEP.Primary.Sound = {
    outdoor_close_silence = sound.CreateFormatedList("weapons/eft/val/fire/vss_outdoor_close_",1,3,".ogg"),
    outdoor_distant_silence = sound.CreateFormatedList("weapons/eft/val/fire/vss_outdoor_distant_",1,2,".ogg"),
    indoor_close_silence = sound.CreateFormatedList("weapons/eft/val/fire/vss_indoor_close_",1,3,".ogg"),
    indoor_distant_silence = sound.CreateFormatedList("weapons/eft/val/fire/vss_indoor_distant_",1,2,".ogg"),
}

SWEP.Primary.SoundEmpty = "weapons/eft/m4a1/mcx_magrelease_button.ogg"

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_vss_val2.mdl",
    vec = Vector(12,-4,-4),
    ang = Angle(-3,0,0),
    chamberBodygroup = 7
})

SWEP:TableLink("wmFastData",{
    model = "models/weapons/arc9/darsu_eft/c_vss_val2.mdl",
    vec = Vector(11,-0.5,-4.8),
    ang = Angle(5,5,180)
})

SWEP:TableLink("wmVeryFastData",{
    model = "models/weapons/w_rif_ak47.mdl",
})

-- Camera

SWEP.CameraPos = Vector(-30,0,1.39)
