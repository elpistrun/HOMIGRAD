local SWEP = oop.Reg("med_painkiller","med_kit",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = L("med_painkiller")
SWEP.Instructions = L("med_painkiller_desc")

SWEP.Spawnable = true

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP:TableLink("wmFastData",{model = "models/w_models/weapons/w_eq_painpills.mdl",vec = Vector(3.6,-2,1),ang = Angle(0,0,180)})

SWEP.dwsPos = Vector(0,-20,-3)
SWEP.dwiSelectPos = Vector(0,-120,-4)
SWEP.dwsAng = Angle(0,-90,0)

function SWEP:vbwFunc(ply)
    local ent = ply:GetWeapon("medkit")
    if ent and ent.vbwActive then return self.vbwPos,self.vbwAng end
    return self.vbwPos2,self.vbwAng2
end