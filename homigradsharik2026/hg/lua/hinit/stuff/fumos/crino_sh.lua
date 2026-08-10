local SWEP = oop.Reg("fumos_crino",{"fumos_fumo"})
if not SWEP then return end

SWEP.PrintName = "Crino"
SWEP.NextBotClass = "npc_komeiji_fumo_enemy"
SWEP.WorldModel = "models/tadano/fumo/pack/cirno.mdl"

SWEP.dwsPos = Vector(0,-45,0)
SWEP.dwsAng = Angle(0,90,0)

SWEP.wmFastVector = Vector(4,-1,-4)
SWEP.wmFastAngle = Angle(0,180,180)