local SWEP = oop.Reg("wep_food_cannerburger","wep_food_base")
if not SWEP then return end

SWEP.PrintName = L("item_food_cannerburger")

SWEP:TableLink("wmFastData",{model = "models/jordfood/canned_burger.mdl",vec = Vector(4,-4,1),ang = Angle(0,-20,180)})

SWEP.HandBack = 20
SWEP.HandRight = 20

SWEP.ParticleColor = Color(75,65,25)

SWEP.HungryAdd = 4

SWEP.dwsPos = Vector(0,-25,-1.3)
SWEP.dwiSelectPos = Vector(0,-60,-1.3)
SWEP.dwsAng = Angle(0,90,0)