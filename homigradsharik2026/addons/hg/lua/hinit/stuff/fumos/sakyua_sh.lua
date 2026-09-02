local SWEP = oop.Reg("fumos_sakuya",{"fumos_fumo"})
if not SWEP then return end

SWEP.PrintName = "Sakuya"
SWEP.WorldModel = "models/tadano/fumo/pack/inu.mdl"
SWEP.NextBotClass = "npc_sakuyanextbot"

SWEP.dwsPos = Vector(0,-45,-9)
SWEP.dwsAng = Angle(0,90,0)

SWEP.wmFastVector = Vector(4,-2,4)
SWEP.wmFastAngle = Angle(0,180,180)