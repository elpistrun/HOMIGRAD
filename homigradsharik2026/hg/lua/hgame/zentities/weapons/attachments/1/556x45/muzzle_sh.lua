WepAtt("silencer_556x45_m4sd",{
    printName = "Silencer M4SD 556x45",
    icon = "entities/eft_ar15_attachments/muzzle/ar15_griffin_armament_m4sdk_556x45_sound_suppressor.png",
    model = "models/weapons/arc9/darsu_eft/mods/silencer_sdqd_griffin_m4sd_k_silencer_556x45.mdl",
    MuzzlePos = Vector(3.6,0,0),

    Silencer = true,
    MuzzleFlashScale = false,
    MuzzleGasSide = false,
    MuzzleGasForward = 3
})

WepAtt("muzzle_556x45_colt",{
    MuzzlePos = Vector(1.5,0,0),
    icon = "entities/eft_ar15_attachments/muzzle/ar15_colt_usgi_a2_556x45_flash_hider.png",
    model = "models/weapons/arc9/darsu_eft/mods/muzzle_ar15_colt_usgi_a2_556x45.mdl",

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,0,3),
            slots = {
                [0] = {false},
                ["silencer_556x45_m4sd"] = {"silencer_556x45_m4sd"}
            }
        }
    }
})

attachmentGame.ManualReg("muzzle_556",{
    ["muzzle_556x45_colt"] = {"muzzle_556x45_colt",bone = "mod_muzzle"}
})