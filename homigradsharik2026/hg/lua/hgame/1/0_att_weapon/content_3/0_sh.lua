WepAtt("muzzle_dt_hybrid_46",{
    printName = "Muzzle DT Hybrid 46",
    icon = "entities/eft_attachments/muzzles/dthybrid.png",
    model = "models/weapons/arc9_eft_shared/atts/muzzle/muzzle_all_silencerco_hybrid_46_multi.mdl",

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,0,0),
            slots = {
                [0] = {false},
                ["silencer_hybrid_46"] = {"silencer_hybrid_46"}
            }
        }
    }
})

WepAtt("silencer_hybrid_46",{
    printName = "Silencer Hybrid 46",
    icon = "entities/eft_attachments/muzzles/hybridslinecer.png",
    model = "models/weapons/arc9_eft_shared/atts/muzzle/silencer_mount_silencerco_hybrid_46_multi.mdl",

    MuzzlePos = Vector(7.4,0,0),

    Silencer = true,
    MuzzleFlashScale = false,
    MuzzleGasSide = false,
    MuzzleGasForward = 3
})