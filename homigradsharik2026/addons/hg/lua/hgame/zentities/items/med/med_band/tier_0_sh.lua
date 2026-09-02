local SWEP = oop.Reg("med_band","med_kit",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = L("med_band")
SWEP.Instructions = L("med_band_desc")

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP:TableLink("wmFastData",{model = "models/bandages.mdl",vec = Vector(6,-3,-1),ang = Angle(10,90,-90)})

SWEP.dwsPos = Vector(0,-33,0)
SWEP.dwiPos = Vector(0.1,-33,0.3)
SWEP.dwiAng = Angle(45,0,-90)
SWEP.dwiSelectPos = Vector(0,-120,0)
SWEP.dwsAng = Angle(0,0,-90)

function SWEP:vbwFunc(ply)
    local ent = ply:GetWeapon("medkit")
    if ent and ent.vbwActive then return self.vbwPos,self.vbwAng end
    return self.vbwPos2,self.vbwAng2
end

SWEP.InvCount = 6