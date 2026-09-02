WepAtt("suppressor_45x46_omega",{
    printName = "Omega",
    icon = "entities/eft_usp_attachments/omegasil.png",
    model = "models/weapons/arc9/darsu_eft/mods/silencer_base_silencerco_omega_45k.mdl",
    MuzzlePos = Vector(5.9,0,0),

    Silencer = true,

    MuzzleFlashScale = false,
    MuzzleGasAround = false,
    MuzzleGasForwardScale = 3
})

WepAtt("muzzle_omega45k",{
    printName = "Muzzle 45K",
    icon = "entities/eft_ump_attachments/omegamount.png",
    model = "models/weapons/arc9/darsu_eft/mods/muzzle_all_silencerco_omega_45k_direct_thread_adapter.mdl",

    slots = {
        ["1"] = {
            name = "Suppressor",
            slotPos = Vector(0,-3,0),
            slots = {
                [0] = {false},
                ["suppressor_45x46_omega"] = {"suppressor_45x46_omega",vec = Vector(0.55,0,0)}
            }
        }
    }
})

WepAtt("muzzle_crissvector45",{
    printName = "Muzzle",
    icon = "entities/eft_ump_attachments/vectorfh.png",
    model = "models/weapons/arc9/darsu_eft/mods/muzzle_vector_kriss_flash_hider.mdl",
    MuzzlePos = Vector(1.5,0,0)
})


attachmentGame.ManualReg("muzzle_45",{
    ["muzzle_omega45k"] = {"muzzle_omega45k",bone = "mod_muzzle"},
    ["muzzle_crissvector45"] = {"muzzle_crissvector45",bone = "mod_muzzle"}
})