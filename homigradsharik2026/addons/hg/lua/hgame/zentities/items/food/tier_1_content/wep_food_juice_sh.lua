local SWEP = oop.Reg("wep_food_juice","wep_food_base")
if not SWEP then return end

SWEP.PrintName = L("item_food_juice")

SWEP:TableLink("wmFastData",{model = "models/foodnhouseholditems/juice.mdl",vec = Vector(6,-3,-5),ang = Angle(0,0,180)})

SWEP.HandBack = 20
SWEP.HandRight = 20

SWEP.ParticleColor = Color(255,125,75)
SWEP.SndEet = SndEatWater

SWEP.HungryAdd = 0.33
SWEP.StaminaAdd = 30

SWEP.dwsPos = Vector(0,-50,3.6)
SWEP.dwiSelectPos = Vector(0,-200,3.6)
SWEP.dwsAng = Angle(0,90,0)