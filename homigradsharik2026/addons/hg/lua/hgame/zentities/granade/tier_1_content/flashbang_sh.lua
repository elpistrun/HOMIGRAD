local SWEP = oop.Reg("wep_gnade_flashbang","wep_gnade_base")
if not SWEP then return end

SWEP.PrintName = L("wep_gnade_flashbang")
SWEP.Instructions = L("wep_gnade_flashbang_desc")

SWEP:TableLink("wmFastData",{model = "models/jmod/explosives/grenades/flashbang/flashbang.mdl",vec = Vector(5,-2,1)})

SWEP.Granade = "ent_gnade_flashbang"

SWEP.dwsPos = Vector(0,-35,-1.5)
SWEP.dwiSelectPos = Vector(0,-140,-1.5)

SWEP.EnableTransformModel = true

SWEP.wmVector = Vector(5,2,1)
SWEP.wmAngle = Angle(0,180,0)

SWEP.ExplosiveClass = "explosive_flashbang"