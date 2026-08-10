local SWEP = oop.Reg("med_adrenaline","med_kit",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = L("med_adrenaline")
SWEP.Instructions = L("med_adrenaline_desc")

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP:TableLink("wmFastData",{model = "models/weapons/w_models/w_jyringe_jroj.mdl",vec = Vector(4,-1.5,-1.4),ang = Angle(-25,-15,0)})

SWEP.dwmModeScale = 1
SWEP.dwmForward = 4
SWEP.dwmRight = 1
SWEP.dwmUp = 0

SWEP.dwmAUp = 0
SWEP.dwmARight = 90
SWEP.dwmAForward = 0

SWEP.dwsPos = Vector(1,25,-1)
SWEP.dwiSelectPos = Vector(1,120,-1)
SWEP.dwsAng = Angle(90 - 45,0,0)