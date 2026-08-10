local SWEP = oop.Reg("wep_m9a3","hg_wep",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "M9A3"
SWEP.Category 				= L("weapon_category_pistol")
SWEP.IconOverride = "entities/arc9_eft_m9a3.png"

SWEP.Slot					= 2
SWEP.SlotPos				= 2

SWEP.HoldType = "revolver"
SWEP.itemType = "weaponSecondary"
-- Model


SWEP.Primary.Automatic = true
SWEP.Primary.ChamberAuto = true
SWEP.Primary.ChamberAutoReload = true

SWEP.Primary.Delay = 1 / 9.6
SWEP.Primary.Spread = 90 / 170
SWEP.Primary.DWRName = "pistol"
SWEP.Primary.AmmoCalibre = "9x19"
SWEP.Primary.MagazineModel = "models/weapons/arc9/darsu_eft/mods/mag_m9a3.mdl"
SWEP.Primary.MagazineModelAng = Angle(0,-90,0)
SWEP.Primary.ClipSize  = 17

SWEP.Primary.Sound = {
    outdoor_close = {"weapons/eft/m9a3/m9a3_outdoor_close.ogg"},
    outdoor_distant = {"weapons/eft/m9a3/m9a3_outdoor_distant.ogg"},
    indoor_close = {"weapons/eft/m9a3/m9a3_indoor_close.ogg"},
    indoor_distant = {"weapons/eft/m4a1/fire/hk416_indoor_distant.ogg"},

    outdoor_close_silence = {"weapons/eft/m9a3/m9a3_silence_outdoor_close.ogg"},
    outdoor_distant_silence = {"weapons/eft/m9a3/m9a3_silence_outdoor_distant.ogg"},
    indoor_close_silence = {"weapons/eft/m9a3/m9a3_silence_indoor_close.ogg"},
    indoor_distant_silence = {"weapons/eft/m9a3/m9a3_silence_indoor_distant.ogg"}
}

SWEP.Primary.SoundEmpty = "weapons/eft/generic_pistol/pm_trigger_hammer.wav"
SWEP.FootstepSounds = weapons.SoundsSpinPistol

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_m9a3.mdl",
    vec = Vector(13,-5,-3),
    ang = Angle(-3,0,0),
    chamberBodygroup = 10
})

SWEP:TableLink("wmFastData",{
    vec = Vector(3,-1,-3),
    ang = Angle(0,0,180)
})

SWEP:TableLink("wmVeryFastData",{
    model = "models/weapons/w_pist_p228.mdl",
    vec = Vector(3,-1,-6),
    ang = Angle(0,0,180)
})

SWEP.dwsPos = Vector(-21.5,40,4.6)
SWEP.dwiSelectPos = Vector(-21,100,4.6)
SWEP.dwiPos = Vector(-17.5,35,-12)
SWEP.dwiAng = Angle(-45,0,0)

SWEP.vbwIsHolster = true
SWEP.vbwPos = Vector(-8,-5,0)
SWEP.vbwAng = Angle(0,-90,0)

SWEP.WorldModelCenter = {Vector(-19,4.25,3),Angle(0,0,0)}

-- Camera

SWEP.CameraPos = Vector(-24,0,0.55)
SWEP.CameraRecoil = -2
SWEP.CR_Scope = 4

-- Others

SWEP.MoveMulEquip = 0.95

SWEP.recoilLerp = 0.4

function SWEP:GetShellDir()
	return Vector(math.Rand(125,175),math.Rand(5,5),-math.Rand(25,45))
end

SWEP.SprayAng = Angle(1.3,0.1,0)

SWEP.RecoilBackMul = 6

function SWEP:DoAnimationRecoil(wmAngle,wmVector)
    local recoil = self.recoil
    local scopeLerp = self.scopeLerp
    local abs = self.recoilRandAbs

    wmAngle[1] = wmAngle[1] - recoil * 35 + math.ease.InBounce(recoil) * 25
    wmAngle[2] = wmAngle[2] + recoil * abs + math.max(recoil - 0.5,0) / 0.5 * 5 * abs - math.ease.InBounce(recoil) * 5 * abs + math.cos(RealTime() * 3) * recoil * 2

    wmVector[3] = wmVector[3] + recoil
end