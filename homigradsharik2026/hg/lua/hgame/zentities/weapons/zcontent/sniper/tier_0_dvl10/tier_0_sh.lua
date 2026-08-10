local SWEP = oop.Reg("wep_dvl10","hg_wep",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "DVL10"
SWEP.Category 				= L("weapon_category_sniper")
SWEP.IconOverride = "entities/arc9_eft_dvl10.png"

SWEP.Slot					= 2
SWEP.SlotPos				= 1

SWEP.HoldType = "ar2"

-- Model

SWEP.Primary.ClipSize  = 5
SWEP.Primary.Automatic = true
SWEP.Primary.ChamberAuto = false

SWEP.Primary.Delay = 1 / 3
SWEP.Primary.DWRName = "heavy"
SWEP.Primary.AmmoCalibre = "762x51"
SWEP.Primary.ShellModel = "models/weapons/arc9/darsu_eft/shells/762x51.mdl"
SWEP.Primary.MagazineModel = "models/weapons/arc9/darsu_eft/mods/mag_dvl10_5.mdl"
SWEP.Primary.MagazineModelAng = Angle(0,-90,0)

SWEP.MuzzlePos = Vector(-27,0,0.26)

SWEP.Primary.Sound = {
    outdoor_close = {"weapons/eft/dvl10/dvl_fire_close.ogg"},
    outdoor_distant = {"weapons/eft/dvl10/dvl_fire_distant.ogg"},
    indoor_close = {"weapons/eft/dvl10/dvl_fire_indoor_close.ogg"},
    indoor_distant = {"weapons/eft/dvl10/dvl_fire_indoor_distant.ogg"},

    outdoor_close_silence = {"weapons/eft/dvl10/dvl_fire_silenced_close.ogg"},
    outdoor_distant_silence = {"weapons/eft/dvl10/dvl_fire_silenced_distant.ogg"},
    indoor_close_silence = {"weapons/eft/dvl10/dvl_fire_silenced_indoor_close.ogg"},
    indoor_distant_silence = {"weapons/eft/dvl10/dvl_fire_silenced_indoor_distant.ogg"}
}

SWEP.Primary.SoundEmpty = "weapons/eft/dvl10/dvl_magbutton.ogg"

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_dvl10.mdl",
    vec = Vector(9,-7,-4.5),
    ang = Angle(0,0,0),
    chamberBodygroup = 6
})

SWEP:TableLink("wmFastData",{
    model = "models/weapons/arc9/darsu_eft/c_dvl10.mdl",
    vec = Vector(13,-0.5,-5),
    ang = Angle(5,0,180)
})

SWEP:TableLink("wmVeryFastData",{
    model = "models/weapons/w_snip_awp.mdl",
    vec = Vector(13,-0.5,-5),
    ang = Angle(5,0,180)
})

SWEP.dwsPos = Vector(-25.5,170,4.6)
SWEP.dwiPos = Vector(-18,100,-10)
SWEP.dwiAng = Angle(-45,0,0)

SWEP.vbwPos = Vector(4,-4,3)
SWEP.vbwAng = Angle(0,0,0)

SWEP.WorldModelCenter = {Vector(-23,4.25,3),Angle(0,0,0)}
SWEP.CloseWallLen = 48

-- Camera

SWEP.CameraPos = Vector(-20,0,2)
SWEP.CameraRecoil = 2
SWEP.CameraRecoil_Scope = 0.5

SWEP.recoilLerp = 0.07

-- Others

SWEP.MoveMulEquip = 0.95
SWEP.recoilAngUp = 3
SWEP.recoilAngUp_Scope = 2

SWEP.CameraMovementMul = 0.8
SWEP.CImersiveSetL = 0.3

SWEP.RecoilCameraMul = 0.5
SWEP.RecoilCameraMulScope = 1

SWEP.SprayAng = Angle(0.1,0,0)

SWEP.recoilBackMul = 2

SWEP.scopeInterp = 0.06
SWEP.cameraFollowBackRecoil = true

SWEP.ImmersiveAngleSetMul = 0.66