local SWEP = oop.Reg("wep_vss","wep_asval",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = "VSS"
SWEP.IconOverride = "entities/arc9_eft_vss.png"

SWEP.AttachmentDefault = {
    {"4","val_dustcover"},
    {"6","val_sight"}
}