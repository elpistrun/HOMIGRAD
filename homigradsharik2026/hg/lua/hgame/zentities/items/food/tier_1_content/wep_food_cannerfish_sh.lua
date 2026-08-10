local SWEP = oop.Reg("wep_food_cannerfish","wep_food_base")
if not SWEP then return end

SWEP.PrintName = L("item_food_cannerfish")

SWEP:TableLink("wmFastData",{model = "models/jordfood/atun.mdl",vec = Vector(5,-2,-1),ang = Angle(0,0,180)})

SWEP.ParticleColor = Color(75,65,25)

SWEP.HungryAdd = 1

SWEP.dwsPos = Vector(0,-15,-0.6)
SWEP.dwiSelectPos = Vector(0,-40,-0.7)
SWEP.dwsAng = Angle(0,0,-25)