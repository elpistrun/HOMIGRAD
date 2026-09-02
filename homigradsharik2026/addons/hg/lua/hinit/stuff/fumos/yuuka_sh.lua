local SWEP = oop.Reg("fumos_yuuka",{"fumos_fumo"})
if not SWEP then return end

SWEP.PrintName = "Koishi"
SWEP.NextBotClass = "npc_koishinextbot"
SWEP.WorldModel = "models/tadano/fumo/pack/yuuka.mdl"

SWEP.wmFastVector = Vector(3,-2,2.7)
SWEP.wmFastAngle = Angle(0,-90,180)