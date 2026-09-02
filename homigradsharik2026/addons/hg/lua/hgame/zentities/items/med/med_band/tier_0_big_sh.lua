local SWEP = oop.Reg("med_band_big","med_band",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = L("med_band") .. " (L)"
SWEP.Instructions = L("med_band_desc")

SWEP.wmFastData = {model = "models/bandages.mdl",vec = Vector(6,-3,-1),ang = Angle(10,90,-90)}

SWEP.InvCount = 10
SWEP.DelayUse = 0.5

function SWEP:UseApply(ply)
    if not SERVER then return end
    if ply.StopBleeding then ply:StopBleeding() end
    if ply.RestoreBlood then ply:RestoreBlood(150) end
end
