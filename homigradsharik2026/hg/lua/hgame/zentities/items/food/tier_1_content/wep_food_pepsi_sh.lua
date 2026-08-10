local SWEP = oop.Reg("wep_food_pepsi","wep_food_base")
if not SWEP then return end

SWEP.PrintName = "Pepsi"

SWEP:TableLink("wmFastData",{model = "models/jorddrink/pepcan01a.mdl",vec = Vector(5,-2,0),ang = Angle(0,0,180)})

SWEP.HandBack = 0
SWEP.HandRight = 0

SWEP.ParticleColor = Color(75,65,65)
SWEP.SndEet = SndEatWater

SWEP.StaminaAdd = 30

SWEP.dwsPos = Vector(0,-25,0)
SWEP.dwiSelectPos = Vector(0,-90,0)
SWEP.dwsAng = Angle(-0,-0,0)