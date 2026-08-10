WepAtt("suppressor_9x19_illusion",{
    printName = "Supressor Illusion 9x19",
    icon = "entities/eft_attachments/muzzles/illusion.png",
    model = "models/weapons/arc9_eft_shared/atts/muzzle/silencer_all_aac_illusion_9_9x19.mdl",
    MuzzlePos = Vector(7.3,0,0),

    Silencer = true,
    
    MuzzleFlashScale = false,
    MuzzleGasAround = false,
    MuzzleGasForwardScale = 3
})

WepAtt("suppressor_9x19_osprey",{
    printName = "Supressor Osprey 9x19",
    icon = "entities/eft_attachments/muzzles/osprey9.png",
    model = "models/weapons/arc9_eft_shared/atts/muzzle/silencer_all_silencerco_osprey_9_9x19.mdl",
    MuzzlePos = Vector(7.2,0,0),

    Silencer = true,

    MuzzleFlashScale = false,
    MuzzleGasAround = false,
    MuzzleGasForwardScale = 3
})

WepAtt("muzzle_crissvector9",{
    printName = "Muzzle",
    icon = "entities/eft_ump_attachments/vectorfh.png",
    model = "models/weapons/arc9/darsu_eft/mods/muzzle_vector_kriss_flash_hider_9.mdl",
    MuzzlePos = Vector(1.5,0,0)
})

attachmentGame.ManualReg("muzzle_9",{
    ["suppressor_9x19_illusion"] = {"suppressor_9x19_illusion",bone = "mod_muzzle"},
    ["suppressor_9x19_osprey"] = {"suppressor_9x19_osprey",bone = "mod_muzzle"},
    ["muzzle_crissvector9"] = {"muzzle_crissvector9",bone = "mod_muzzle"}
})