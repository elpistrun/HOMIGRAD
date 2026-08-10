local SWEP = oop.Reg("med_kit","hg_wep_base",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = L("weapon_medkit")
SWEP.Author = "0oa"
SWEP.Instructions = L("weapon_medkit_desc")

SWEP.Spawnable = true
SWEP.Category = L("weapon_category_medical")

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP:TableLink("wmFastData",{model = "models/w_models/weapons/w_eq_medkit.mdl",vec = Vector(3.6,-1,-3),ang = Angle(0,0,90)})

SWEP.dwsPos = Vector(0,-35,-4)
SWEP.dwiSelectPos = Vector(0,-120,-4)
SWEP.dwsAng = Angle(0,-90,0)

SWEP.InvCount = 3
SWEP.itemType = "medical"

SWEP.HoldType = "slam"

SWEP.SupportFake = true