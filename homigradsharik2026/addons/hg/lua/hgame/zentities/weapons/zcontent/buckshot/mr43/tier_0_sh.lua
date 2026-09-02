local SWEP = oop.Reg("wep_mr43","hg_wep",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "MR43"
SWEP.Category 				= L("weapon_category_buckshoot")
SWEP.IconOverride = "entities/arc9_eft_mr43.png"

SWEP.Slot					= 2
SWEP.SlotPos				= 0

SWEP.HoldType = "ar2"

SWEP.Primary.ClipSize  = 2
SWEP.Primary.Automatic = true
SWEP.Primary.ChamberAuto = false

SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 1 / 11
SWEP.Primary.Spread = 90 / 70
SWEP.Primary.DWRName = "buckshoot"
SWEP.Primary.AmmoCalibre = "12x70"

SWEP.MuzzlePos = Vector(0,0,0)

SWEP.Primary.Sound = {
    outdoor_close = {"weapons/eft/mr43/mr43_fire_close1.ogg","weapons/eft/mr43/mr43_fire_close2.ogg"},
    outdoor_distant = {"weapons/eft/mr43/mr43_fire_distant1.ogg","weapons/eft/mr43/mr43_fire_distant2.ogg"},
    indoor_close = {"weapons/eft/mr43/mr43_fire_indoor_close1.ogg"},
    indoor_distant = {"weapons/eft/mr43/mr43_fire_indoor_distant.ogg"}
}

SWEP.HolsterSound = "weapons/eft/mr43/mr133_holster.ogg"
SWEP.DeploySound = "weapons/eft/mr43/mr133_draw.ogg"

SWEP.Primary.SoundEmpty = "weapons/eft/mr43/mr43_hammer_release.wav"
SWEP.FootstepSounds = weapons.SoundsSpinRifle

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_mr43.mdl",
    vec = Vector(12,-4,-5.3),
    ang = Angle(-3,0,0)
})

SWEP:TableLink("wmFastData",{
    model = "models/weapons/arc9/darsu_eft/c_mr43.mdl",
    vec = Vector(9,-1.5,-4),
    ang = Angle(5,5,180)
})

SWEP:TableLink("wmVeryFastData",{
    model = "models/weapons/w_shot_xm1014.mdl",
    vec = Vector(11,-0.8,-6),
    ang = Angle(10,1,180)
})

SWEP.dwsPos = Vector(-21,100,4.6)
SWEP.dwiSelectPos = Vector(-21,150,4.6)
SWEP.dwiPos = Vector(-19,90,-13)
SWEP.dwiAng = Angle(-45,0,0)

SWEP.vbwPos = Vector(2,-4,0)

SWEP.WorldModelCenter = {Vector(-19,4.25,3),Angle(0,0,0)}

-- Camera

SWEP.CameraPos = Vector(-35,0,0.9)
SWEP.CR_Scope = 4
SWEP.CameraRecoil = 1
SWEP.CameraRecoil_Scope = 3

-- Others

SWEP.MoveMulEquip = 0.95

SWEP.recoilLerp = 0.1

SWEP.MuzzleFlashScale = 2
SWEP.MuzzleGasTimeScale = 3
SWEP.MuzzleGasAround = 3

function SWEP:DoAnimationRecoil(wmAngle,wmVector)
    local recoil = self.recoil
    local scopeLerp = self.scopeLerp
    local abs = self.recoilRandAbs

    wmAngle[1] = wmAngle[1] - math.max(recoil - 0.2,0) / 0.8 * 20 + math.ease.InBounce(recoil) * 15 + math.sin(CurTime() * 3) * recoil * 2
    wmAngle[1] = wmAngle[1] - math.max(recoil - 0.5,0) / 0.5 * 45
    wmAngle[1] = wmAngle[1] - recoil * 15

    wmAngle[2] = wmAngle[2] + recoil * abs + math.max(recoil - 0.5,0) / 0.5 * 15 * abs - math.ease.InBounce(recoil) * 5 * abs + math.cos(CurTime() * 3) * recoil * 2
    wmVector[3] = wmVector[3] + 4 * recoil
end

function SWEP:GetShellDir()
	return Vector(math.Rand(125,175),math.Rand(5,5),math.Rand(-25,25))
end

SWEP.GetMagazineItem = nil

SWEP.SprayAng = Angle(4,0,0)

SWEP.recoilBackMul = 6

function SWEP:CanPrimaryAttackChamber()
    return self.chamber1 != false and self.chamber1 != nil
        or self.chamber2 != false and self.chamber2 != nil
end

SWEP.ShellBoneIndex = {
    "patron_in_weapon_000",
    "patron_in_weapon_001",
}

SWEP.CustomRejectShell = true

function SWEP:RejectShell(number)
    local wm = self.wm
    if not IsValid(wm) then return end--ez

    local mat = wm:GetBoneMatrix(wm:LookupBone(self.ShellBoneIndex[number or 1]))
    if not mat then return end--ez

    local Pos,Ang = mat:GetTranslation(),mat:GetAngles()

    CreateShell(self.Primary.AmmoCalibre,Pos,Vector(16,0,0):Rotate(Ang),not noFilter and self:GetOwner())
end
