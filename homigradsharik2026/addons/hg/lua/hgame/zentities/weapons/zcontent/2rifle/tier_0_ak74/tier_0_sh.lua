local SWEP = oop.Reg("wep_ak74","hg_wep",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "AK-74"
SWEP.Category 				= L("weapon_category_rifle")
SWEP.IconOverride = "entities/arc9_eft_ak74.png"

SWEP.Slot					= 2
SWEP.SlotPos				= 0

SWEP.HoldType = "ar2"

-- Model

SWEP.Primary.ClipSize  = 30
SWEP.Primary.Automatic = true
SWEP.Primary.ChamberAuto = true

SWEP.Primary.Delay = 1 / 14
SWEP.Primary.Spread = 90 / 360
SWEP.Primary.DWRName = "carabine"
SWEP.Primary.AmmoCalibre = "545x39"
SWEP.Primary.MagazineModel = "models/weapons/arc9/darsu_eft/mods/mag_ak74_izhmash_6l20_545x39_30.mdl"

SWEP.MuzzlePos = Vector(0.2,0,0)

SWEP.Primary.Sound = {
    outdoor_close = sound.CreateFormatedList("weapons/eft/ak/fire/ak74_outdoor_close_",1,4,".ogg"),
    outdoor_distant = sound.CreateFormatedList("weapons/eft/ak/fire/ak74_outdoor_distant_",1,2,".ogg"),
    indoor_close = sound.CreateFormatedList("weapons/eft/ak/fire/ak74_indoor_close_",1,4,".ogg"),
    indoor_distant = sound.CreateFormatedList("weapons/eft/ak/fire/ak74_indoor_distant_",1,2,".ogg"),

    outdoor_close_silence = sound.CreateFormatedList("weapons/eft/ak/fire/ak74_silence_outdoor_close_",1,4,".ogg"),
    outdoor_distant_silence = sound.CreateFormatedList("weapons/eft/ak/fire/ak74_silence_outdoor_distant_",1,2,".ogg"),
    indoor_close_silence = sound.CreateFormatedList("weapons/eft/ak/fire/ak74_silence_indoor_close_",1,4,".ogg"),
    indoor_distant_silence = sound.CreateFormatedList("weapons/eft/ak/fire/ak74_silence_indoor_distant_",1,2,".ogg")
}

SWEP.Primary.SoundEmpty = "weapons/eft/ak/ak74_trigger_empty.wav"
SWEP.FootstepSounds = weapons.SoundsSpinGeneric
SWEP.ScopeSounds = {
    listIn = {"weapons/ads/aim_on_riffle_12.wav"},
    listOut = {"weapons/ads/aim_on_riffle_11.wav"},
}

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_ak74.mdl",
    vec = Vector(11,-4,-4),
    ang = Angle(-3,0,0),
    chamberBodygroup = 5
})

SWEP:TableLink("wmFastData",{
    model = "models/weapons/arc9/darsu_eft/c_ak74.mdl",
    vec = Vector(12,-0.5,-4),
    ang = Angle(5,5,180)
})

SWEP:TableLink("wmVeryFastData",{
    model = "models/weapons/w_rif_ak47.mdl",
})

SWEP.dwsPos = Vector(-18,100,4.6)
SWEP.dwiSelectPos = Vector(-18,150,4.6)
SWEP.dwiPos = Vector(-16,80,-9)
SWEP.dwiAng = Angle(-45,0,0)

SWEP.vbwPos = Vector(2,-4,0)

SWEP.WorldModelCenter = {Vector(-19,4.25,3),Angle(0,0,0)}

-- Camera

SWEP.CameraPos = Vector(-30,0,1.94)

-- Others

SWEP.MoveMulEquip = 0.95

SWEP.recoilLerp = 0.27
SWEP.RecoilBackMul = 2