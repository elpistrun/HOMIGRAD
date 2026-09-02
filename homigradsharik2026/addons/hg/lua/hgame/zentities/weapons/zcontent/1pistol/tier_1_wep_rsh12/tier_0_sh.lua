local SWEP = oop.Reg("wep_rsh12","wep_m9a3",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "RSH12"
SWEP.Category 				= L("weapon_category_pistol")
SWEP.IconOverride = "entities/arc9_eft_rsh12.png"

-- Model

SWEP.Primary.ClipSize  = 5
SWEP.Primary.Automatic = false
SWEP.Primary.ChamberAuto = true

SWEP.Primary.Delay = 1 / 7
SWEP.Primary.Spread = 90 / 170
SWEP.Primary.AmmoCalibre = "127x55"
SWEP.Primary.DWRName = "357"

SWEP.Primary.Sound = {
    outdoor_close = {"weapons/eft/rsh12/rsh12_outdoor_close.ogg"},
    outdoor_distant = {"weapons/eft/rsh12/rsh12_outdoor_distant.ogg"},
    indoor_close = {"weapons/eft/rsh12/rsh12_indoor_close.ogg"},
    indoor_distant = {"weapons/eft/rsh12/rsh12_indoor_distant.ogg"}
}

SWEP.Primary.SoundEmpty = "weapons/eft/generic_pistol/pm_trigger_hammer.wav"

SWEP.MuzzleGasForward = 3
SWEP.MuzzleGasSide = 2
SWEP.MuzzleGasAround = 0.4
SWEP.MuzzleGasBack = 12

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_rsh12.mdl",
    vec = Vector(13,-3,-5),
    ang = Angle(-3,0,0),
    chamberBodygroup = 3
})

SWEP:TableLink("wmFastData",{
    vec = Vector(3,-1,-3),
    ang = Angle(0,0,180)
})

SWEP:TableLink("wmVeryFastData",{
    model = "models/weapons/w_357.mdl",
    vec = Vector(-1,-1,-10),
    ang = Angle(5,0,180)
})

SWEP.dwsPos = Vector(-24,50,3.8)
SWEP.dwiSelectPos = Vector(-24,100,3.8)
SWEP.dwiPos = Vector(-19,45,-14)
SWEP.dwiAng = Angle(-45,0,0)

SWEP.PhysicsBox = {-Vector(7,1,5),Vector(8,1,2.5)}
SWEP.WorldModelCenter = {Vector(-19,4.25,3),Angle(0,0,0)}

-- Camera

SWEP.CameraPos = Vector(-25,-0.055,2.2)
SWEP.CameraRecoil = -0.33
SWEP.RecoilCameraMulScope = 1

-- Others

SWEP.MoveMulEquip = 0.95

SWEP.recoilLerp = 0.09

SWEP.GetMagazineItem = nil

SWEP.SprayAng = Angle(6,-3,0)

SWEP.RecoilBackMul = 6

SWEP.ShellBoneIndex = {
    "patron_in_weapon_001",
    "patron_in_weapon_002",
    "patron_in_weapon_003",
    "patron_in_weapon_004",
    "patron_in_weapon_005",
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

function SWEP:CanPrimaryAttackChamber() return true end