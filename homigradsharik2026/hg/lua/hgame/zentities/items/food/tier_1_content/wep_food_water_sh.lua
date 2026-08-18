local SWEP = oop.Reg("wep_food_water","wep_food_base")
if not SWEP then return end

SWEP.PrintName = L("item_food_water")
SWEP.Instructions = "Помогает от отравления!"
//https://cdns.memealerts.com/p/65041af14bfad5a7a9f54833/c4096dd0-fddc-41e5-b0d1-73ee669a3ec6/alert_orig.webm

SWEP:TableLink("wmFastData",{model = "models/jorddrink/the_bottle_of_water.mdl",vec = Vector(4,-1,-2),ang = Angle(0,0,180)})

SWEP.ParticleColor = Color(255,255,255)
SWEP.SndEet = SndEatWater

SWEP.StaminaAdd = 30
SWEP.BreathRelief = 100

SWEP.dwsPos = Vector(0,-35,0.1)
SWEP.dwiSelectPos = Vector(0,-130,0.1)
SWEP.dwsAng = Angle(0,90,0)
