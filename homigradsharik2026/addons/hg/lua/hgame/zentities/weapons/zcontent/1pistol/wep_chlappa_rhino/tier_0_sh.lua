local SWEP = oop.Reg("wep_chiappa_rhino","wep_rsh12",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "Chiappa Rhino"
SWEP.IconOverride = "entities/eft_rhino_attachments/60ds.png"

-- Model

SWEP.Primary.ClipSize = 6
SWEP.Primary.Automatic = false
SWEP.Primary.ChamberAuto = true

SWEP.Primary.Delay = 1 / 7
SWEP.Primary.Spread = 90 / 170
SWEP.Primary.AmmoCalibre = "9x33"
SWEP.Primary.DWRName = "pistol"

SWEP.Primary.Sound = {
    outdoor_close = sound.CreateFormatedList("weapons/eft/rhino/rhino_outdoor_close_",1,1,".ogg"),
    outdoor_distant = sound.CreateFormatedList("weapons/eft/rhino/rhino_outdoor_distant_",1,1,".ogg"),
    indoor_close = sound.CreateFormatedList("weapons/eft/rhino/rhino_indoor_close_",1,1,".ogg"),
    indoor_distant = sound.CreateFormatedList("weapons/eft/rhino/rhino_indoor_distant_",1,1,".ogg"),

    outdoor_close_silence = sound.CreateFormatedList("weapons/eft/rhino/rhino_silence_outdoor_close_",1,1,".ogg"),
    outdoor_distant_silence = sound.CreateFormatedList("weapons/eft/rhino/rhino_silence_outdoor_distant_",1,1,".ogg"),
    indoor_close_silence = sound.CreateFormatedList("weapons/eft/rhino/rhino_silence_indoor_close_",1,1,".ogg"),
    indoor_distant_silence = sound.CreateFormatedList("weapons/eft/rhino/rhino_silence_indoor_distant_",1,1,".ogg")
}

SWEP.Primary.SoundEmpty = "weapons/eft/generic_pistol/pm_trigger_hammer.wav"

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_chiappa_rhino.mdl",
    vec = Vector(13,-5,-3.9),
    ang = Angle(-5,0,0),
    chamberBodygroup = 5
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

SWEP.CameraPos = Vector(-25,-0.055,1.25)
SWEP.CameraRecoil = -0.33
SWEP.RecoilCameraMulScope = 0

-- Others

SWEP.MoveMulEquip = 0.95

SWEP.recoilLerp = 0.13

SWEP.SprayAng = Angle(3.6,0,0)

SWEP.recoilBackMul = 1

SWEP.ShellBoneIndex = {
    "patron_in_weapon_001",
    "patron_in_weapon_002",
    "patron_in_weapon_003",
    "patron_in_weapon_004",
    "patron_in_weapon_005",
    "patron_in_weapon_006",
}