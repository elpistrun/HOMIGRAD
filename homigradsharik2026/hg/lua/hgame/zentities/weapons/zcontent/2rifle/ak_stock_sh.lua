WepAtt("ak_stock_wood",{
    printName = "AK Stock Wood",
    icon = "entities/eft_ak_attachments/stock/74.png",
    category = "stock",
    model = "models/weapons/arc9/darsu_eft/mods/ak_stock_ak74_std_wood.mdl",

    cosmetic = {
        ["akm"] = {
            printName = "AKM",
            icon = "entities/eft_ak_attachments/stock/akm.png",
            model = "models/weapons/arc9/darsu_eft/mods/ak_stock_akm_std_wood.mdl"
        },
        ["ak100"] = {
            printName = "AK-100",
            icon = "entities/eft_ak_attachments/stock/74poly.png",
            model = "models/weapons/arc9/darsu_eft/mods/ak_stock_ak74_std_plastic.mdl"
        },
        ["aks"] = {
            printName = "AKS-74",
            icon = "entities/eft_ak_attachments/stock/74plum.png",
            model = "models/weapons/arc9/darsu_eft/mods/ak_stock_ak74_std_plum.mdl"
        }
    }
})

WepAtt("ak_stock_opfor",{
    printName = "aa47 OPFOR",
    icon = "entities/eft_ak_attachments/stock/aa47.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_stock_opfor_aa47.mdl"
})

WepAtt("ak_stock_zhukov",{
    printName = "AK Zhukov",
    icon = "entities/eft_ak_attachments/stock/zhu.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_stock_zhukov_s.mdl"
})

attachmentGame.ManualReg("ak_stock",{
    ["ak_stock_wood"] = {"ak_stock_wood"},
    ["ak_stock_zhukov"] = {"ak_stock_zhukov"},
    ["ak_stock_zhukov"] = {"ak_stock_zhukov"}
})