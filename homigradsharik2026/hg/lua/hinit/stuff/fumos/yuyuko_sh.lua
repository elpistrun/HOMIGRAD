local SWEP = oop.Reg("fumos_yuyuko",{"fumos_fumo"})
if not SWEP then return end

SWEP.PrintName = "Yuyuko"
SWEP.NextBotClass = "npc_yuyuko"
SWEP.WorldModel = "models/tadano/fumo/pack/yuyu.mdl"

SWEP.dwsPos = Vector(10,-60,-9)
SWEP.dwsAng = Angle(0,0,0)

SWEP.wmFastVector = Vector(11,-12,3)
SWEP.wmFastAngle = Angle(0,-90,180)