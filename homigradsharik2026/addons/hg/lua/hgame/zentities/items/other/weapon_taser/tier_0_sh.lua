local SWEP = oop.Reg("weapon_taser","hg_wep_base",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = L("weapon_taser")
SWEP.Author = "Homigrad"

SWEP.Slot = 2
SWEP.SlotPos = 4
SWEP.Spawnable = true
SWEP.Category = L("weapon_category_item")

SWEP:TableLink("wmFastData",{model = "models/realistic_police/taser/w_taser.mdl"})

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "AR2AltFire"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsPos = Vector(-3,25,-1)
SWEP.dwiSelectPos = Vector(-2,100,-1)
SWEP.dwsAng = Angle(0,0,0)

SWEP.dwmUp = 0.5
SWEP.dwmRight = 0
SWEP.dwmForward = 0

SWEP.dwmARight = 180
SWEP.dwmAUp = 200
SWEP.dwmAForward = 0
SWEP.HoldType = "revolver"

SWEP.itemType = "other"

SWEP.EnableTransformModel = true

SWEP.wmFastVector = Vector(0,1,0)
SWEP.wmFastAngle = Angle(6,20,180 + 4)

if SERVER then return end

function SWEP:Render(gun)
	gun:DrawModel()
end

function SWEP:Transform_DoAnimation(wm,rag)
	local anim = math.Clamp(self:GetNWFloat("Start",0) - CurTime() + 0.2,0,0.2) / 0.2

	rag:AddBoneAng("rhand",Angle(45,0,0):Mul(anim))
end