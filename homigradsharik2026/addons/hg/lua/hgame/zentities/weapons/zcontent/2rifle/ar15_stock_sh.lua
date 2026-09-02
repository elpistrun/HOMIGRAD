WepAtt("ar15_stock_kriss_defence",{
    printName = "Kriss Defence",
    icon = "entities/eft_attachments/stocks/ds150.png",
    model = "models/weapons/arc9/darsu_eft/mods/stock_ar15_kriss_defiance_ds150.mdl"
})

WepAtt("ar15_stock_moe_carbine",{
    printName = "MOE Carabine",
    icon = "entities/eft_attachments/stocks/moe.png",
    model = "models/weapons/arc9/darsu_eft/mods/stock_ar15_magpul_moe_carbine.mdl"
})

attachmentGame.ManualReg("ar15_stock_tube",{
    ["ar15_stock_kriss_defence"] = {"ar15_stock_kriss_defence"},
    ["ar15_stock_moe_carbine"] = {"ar15_stock_moe_carbine"}
})

local att = WepAtt("ar15_stock_tube",{
    printName = "Stock Tube Colt",
    icon = "entities/eft_attachments/stocks/colttube.png",
    model = "models/weapons/arc9/darsu_eft/mods/stock_ar15_colt_stock_tube_std.mdl",

    slots = {
        ["1"] = {
            slotPos = Vector(0,2,0),
            slots = {
                [0] = {false},
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"ar15_stock_tube",Vector(-4,-0.06,-0.8),Angle())

WepAtt("ar15_stock_star_ace_arfx",{
    printName = "Star Ace ARFX",
    icon = "entities/eft_attachments/stocks/arfx.png",
    model = "models/weapons/arc9/darsu_eft/mods/stock_ar15_double_star_ace_arfx.mdl"
})

WepAtt("ar15_stock_baskak",{
    printName = "Armacon Baskak",
    icon = "entities/eft_attachments/stocks/baskak.png",
    model = "models/weapons/arc9/darsu_eft/mods/stock_ar15_armacon_baskak.mdl"
})

WepAtt("ar15_stock_troy_m7a1",{
    printName = "Troy M7A1 PDW",
    icon = "entities/eft_attachments/stocks/m7a1.png",
    model = "models/weapons/arc9/darsu_eft/mods/stock_ar15_troy_m7a1_pdw.mdl",

    slots = {
        ["1"] = {
            name = "Stock",
            slotPos = Vector(0,8,0),
            slots = {
                [0] = {"ar15_stock_butpad_20mm",vec = Vector(-3.45,0,-0.87)},
                ["1"] = {"ar15_stock_butpad_12mm",vec = Vector(-3.45,0,-0.87)}
            }
        }
    }
})

WepAtt("ar15_stock_butpad_12mm",{
    printName = "Stock Base DD Buttpad 12mm",
    icon = "entities/eft_attachments/stocks/ddbutt12.png",
    model = "models/weapons/arc9/darsu_eft/mods/stock_base_dd_buttpad_12mm.mdl"
})

WepAtt("ar15_stock_butpad_20mm",{
    printName = "Stock Base DD Buttpad 12mm",
    icon = "entities/eft_attachments/stocks/ddbutt20.png",
    model = "models/weapons/arc9/darsu_eft/mods/stock_base_dd_buttpad_20mm.mdl"
})

attachmentGame.ManualReg("ar15_stock",{
    ["ar15_stock_tube"] = {"ar15_stock_tube"},
    ["ar15_stock_star_ace_arfx"] = {"ar15_stock_star_ace_arfx"},
    ["ar15_stock_baskak"] = {"ar15_stock_baskak"},
    ["ar15_stock_troy_m7a1"] = {"ar15_stock_troy_m7a1"}
})