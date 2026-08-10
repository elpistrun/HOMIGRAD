local SWEP = oop.Reg("fumos_flandere",{"fumos_fumo"})
if not SWEP then return end

SWEP.PrintName = "Flandere"
SWEP.WorldModel = "models/tadano/fumo/pack/flandere.mdl"
SWEP.NextBotClass = "npc_flandrenextbot"

SWEP.dwsPos = Vector(0,-45,-8)
SWEP.dwsAng = Angle(0,90,0)

SWEP.wmFastVector = Vector(4,-3,4)
SWEP.wmFastAngle = Angle(0,180,180)