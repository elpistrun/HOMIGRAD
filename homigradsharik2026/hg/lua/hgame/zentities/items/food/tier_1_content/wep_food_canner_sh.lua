local SWEP = oop.Reg("wep_food_canner","wep_food_base")
if not SWEP then return end

SWEP.PrintName = L("item_food_canner")

SWEP:TableLink("wmFastData",{model = "models/jordfood/can.mdl",vec = Vector(4.5,-3,-3),ang = Angle(0,0,10)})

SWEP.ParticleColor = Color(75,65,25)

SWEP.HungryAdd = 2

SWEP.dwsPos = Vector(0.45,-25,-3.5)
SWEP.dwiSelectPos = Vector(0.45,-80,-3.5)
SWEP.dwsAng = Angle(-2.8,0,0)