local SWEP = oop.Reg("med_needle","med_kit",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = L("med_needle")
SWEP.Instructions = L("med_needle_desc")

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP:TableLink("wmFastData",{model = "models/bloocobalt/l4d/items/w_eq_adrenaline.mdl",vec = Vector(3.6,-1,-1),ang = Angle(0,0,90)})

SWEP.dwsPos = Vector(-0.5,26,-1.5)
SWEP.dwiSelectPos = Vector(-0.5,120,-1.5)
SWEP.dwsAng = Angle(0,-90,45)

function SWEP:vbwFunc(ply)
    local ent = ply:GetWeapon("medkit")
    if ent and ent.vbwActive then return self.vbwPos,self.vbwAng end
    return self.vbwPos2,self.vbwAng2
end