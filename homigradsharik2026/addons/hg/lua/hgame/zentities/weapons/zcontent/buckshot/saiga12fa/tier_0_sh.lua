local SWEP = oop.Reg("wep_saiga12fa","wep_saiga12k",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "Сайга-12K FA"
SWEP.IconOverride = "entities/arc9_eft_saiga12fa.png"

SWEP.Primary.Automatic = true
SWEP.Primary.ChamberAuto = true

SWEP.AttachmentDefault = {
    {"1","saiga12_dustcover"},

    {"2","saiga12_handguard_quad_rail"},
    {"3","ak_grip_to_ar15"},
    {"4","ak_stock_rpk"},
    {"4.1","ar15_stock_kriss_defence"},
    {"8","saiga12_handguard_quad_rail_upper"},
    {"8.1","saiga12_dustcover_quad_rail"},
    {"8.1.1","kalimator_walther_mrs"}
}
