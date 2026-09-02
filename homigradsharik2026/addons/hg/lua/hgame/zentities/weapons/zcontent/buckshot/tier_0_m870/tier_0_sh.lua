local SWEP = oop.Reg("wep_m870","hg_wep",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "M870"
SWEP.Category 				= L("weapon_category_buckshoot")
SWEP.IconOverride = "entities/arc9_eft_m870.png"

SWEP.Slot					= 2
SWEP.SlotPos				= 0

SWEP.HoldType = "ar2"

-- Model

SWEP.Primary.ClipSize  = 5
SWEP.Primary.Automatic = true
SWEP.Primary.ChamberAuto = false

SWEP.Primary.Delay = 1 / 4
SWEP.Primary.Spread = 90 / 70
SWEP.Primary.DWRName = "buckshoot"
SWEP.Primary.AmmoCalibre = "12x70"

SWEP.MuzzlePos = Vector(-18.89,0,0)

SWEP.MuzzleFlashScale = 2
SWEP.MuzzleGasForward = 3
SWEP.MuzzleGasSide = 2
SWEP.MuzzleGasAround = 0.8
SWEP.MuzzleGasBack = 0

SWEP.Primary.Sound = {
    outdoor_close = sound.CreateFormatedList("weapons/eft/m870/rem870_outdoor_close_",1,2,".ogg"),
    outdoor_distant = sound.CreateFormatedList("weapons/eft/m870/rem870_outdoor_distant_",1,2,".ogg"),
    indoor_close = {"weapons/eft/m870/rem870_indoor_close.ogg"},
    indoor_distant = {"weapons/eft/m870/rem870_indoor_distant.ogg"},

    outdoor_close_silence = {"weapons/eft/m870/mr133_silence_outdoor_close.ogg"},
    outdoor_distant_silence = {"weapons/eft/m870/mr133_silence_outdoor_distant.ogg"},
    indoor_close_silence = {"weapons/eft/m870/mr133_silence_indoor_close.ogg"},
    indoor_distant_silence = {"weapons/eft/m870/mr133_silence_indoor_distant.ogg"}
}

SWEP.Primary.SoundEmpty = "weapons/eft/ak/ak74_trigger_empty.wav"
SWEP.FootstepSounds = weapons.SoundsSpinRifle

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_m870.mdl",
    vec = Vector(12,-4,-5.3),
    ang = Angle(-3,0,0),
    chamberBodygroup = 8
})

SWEP:TableLink("wmFastData",{
    model = "models/weapons/arc9/darsu_eft/c_m870.mdl",
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

SWEP.CameraPos = Vector(-16,0,1.1)
SWEP.CR_Scope = 4
SWEP.CameraRecoil = -3
SWEP.CameraRecoil_Scope = -8

-- Others

SWEP.MoveMulEquip = 0.95

SWEP.recoilLerp = 0.088

SWEP.MuzzleFlashScale = 2
SWEP.MuzzleGasTimeScale = 3
SWEP.MuzzleGasAround = 3

function SWEP:DoAnimationRecoil(wmAngle,wmVector)
    local recoil = self.recoil
    local scopeLerp = self.scopeLerp
    local abs = self.recoilRandAbs

    wmAngle[1] = wmAngle[1] - recoil * 36 - math.ease.InBounce(recoil) * 12
    wmAngle[2] = wmAngle[2] - recoil * 6

    wmVector[3] = wmVector[3] - 1.8 * recoil
end

function SWEP:GetShellDir()
	return Vector(math.Rand(125,175),math.Rand(5,5),math.Rand(-25,25))
end

SWEP.GetMagazineItem = nil

SWEP.SprayAng = Angle(4,0,0)

SWEP.recoilBackMul = 6

function SWEP:AttackAnimation()
    self:PlayAnimation("fire")

    if CLIENT then
        -- Eject a spent shell casing on every shot from the ejection port.
        if self:IsLocal() and IsValid(self.wm) and self.GetAttachmentPos then
            local att = self.wm:GetAttachment(2)
            if att then
                local owner = self:GetOwner()
                CreateShell(self.Primary.AmmoCalibre,att.Pos,(IsValid(owner) and owner:GetVelocity() or vector_origin) + self:GetShellDir():Rotate(att.Ang),owner)
            end
        end

        timer.GameSimple(0.15,function()
            if not IsValid(self) or self.stateHandling == "holster" or not self:IsActive() then return end

            if not self.chamber then self:DoAction({name = "chamber"}) end
        end)
    end
end