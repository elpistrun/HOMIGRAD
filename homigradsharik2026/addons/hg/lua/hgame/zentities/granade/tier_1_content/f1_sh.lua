local SWEP = oop.Reg("wep_gnade_f1","wep_gnade_base")
if not SWEP then return end

SWEP.PrintName = "F1"
SWEP.Instructions = L("wep_gnade_f1_desc")

SWEP:TableLink("wmFastData",{model = "models/pwb/weapons/w_f1.mdl"})

SWEP.dwsPos = Vector(10.4,-20,-1.1)
SWEP.dwiSelectPos = Vector(10.4,-70,-1.1)
SWEP.dwsAng = Angle(-20,0,0)

SWEP.ExplosiveClass = "explosive_f1"

function SWEP:DrawWorldModel() self:DrawModel() end
function SWEP:DrawFromPlayer() end