WepAtt("ak_grip_wood",{
    printName = "AK Бекилит",
    icon = "entities/eft_ak_attachments/grip/molot.png",
    category = "grip",
    
    model = "models/weapons/arc9/darsu_eft/mods/ak_pgrip_ak74_bakelit.mdl",

    cosmetic = {
        ["akm"] = {
            printName = "AKM Bekelit",
            icon = "entities/eft_ak_attachments/grip/akmbak.png",
            model = "models/weapons/arc9/darsu_eft/mods/ak_pgrip_akm_bakelit.mdl"
        },
        ["akm_wood"] = {
            printName = "AKM Wood",
            icon = "entities/eft_ak_attachments/grip/akmwood.png",
            model = "models/weapons/arc9/darsu_eft/mods/ak_pgrip_akm_wood.mdl"
        },
        ["aks74"] = {
            printName = "AKS-74",
            icon = "entities/eft_ak_attachments/grip/sb9.png",
            model = "models/weapons/arc9/darsu_eft/mods/ak_pgrip_aks74_bakelit.mdl"
        }
    }
})

WepAtt("ak_grip_strike_indsustries",{
    printName = "AK Strike Indsustries",
    icon = "entities/eft_ak_attachments/grip/epg.png",
    category = "grip",
    model = "models/weapons/arc9/darsu_eft/mods/ak_pgrip_strike_indsustries.mdl"
})

WepAtt("ak_grip_mg47",{
    printName = "MG47",
    icon = "entities/eft_ak_attachments/grip/mg47.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_pgrip_kgb_mg47.mdl",
    category = "grip",
})

attachmentGame.ManualReg("ak_grip",{
    ["ak_grip_wood"] = {"ak_grip_wood"},
    ["ak_grip_strike_indsustries"] = {"ak_grip_strike_indsustries"},
    ["ak_grip_mg47"] = {"ak_grip_mg47"}
})