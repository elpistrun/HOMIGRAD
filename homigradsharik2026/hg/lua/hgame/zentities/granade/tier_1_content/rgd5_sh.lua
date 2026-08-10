local SWEP = oop.Reg("wep_gnade_rgd5","wep_gnade_base")
if not SWEP then return end

SWEP.PrintName = "RGD-5"
SWEP.Instructions = L("wep_gnade_rgd5_desc")

SWEP:TableLink("wmFastData",{model = "models/pwb/weapons/w_rgd5.mdl"})

SWEP.Granade = "ent_gnade_rgd5"

SWEP.dwsPos = Vector(10.4,-18,1.4)
SWEP.dwiSelectPos = Vector(10.4,-70,1.4)
SWEP.dwsAng = Angle(-32,0,0)

SWEP.ExplosiveClass = "explosive_rgd5"

function SWEP:DrawWorldModel() self:DrawModel() end
function SWEP:DrawFromPlayer() end