WepAtt("ar15_handguard_colt",{
    printName = "Handguard Colt",
    icon = "entities/eft_ar15_attachments/hg/ar15_colt_m4_carbine_length_handguard.png",
    model = "models/weapons/arc9/darsu_eft/mods/handguard_ar15_colt_m4_length_std.mdl",
    slots = {
        ["1"] = {
            slotPos = Vector(0,-1,0),
            slots = {
                [0] = {"ar15_handguard_colt_bottom",vec = Vector(0,-0.65,-0.1)}
            }
        }
    }
})

WepAtt("ar15_handguard_colt_bottom",{
    printName = "Handguard Colt Lower",
    icon = "entities/eft_ar15_attachments/hg/ar15_colt_m4_carbine_length_lower_handguard.png",
    model = "models/weapons/arc9/darsu_eft/mods/handguard_ar15_colt_m4_length_std_bottom.mdl"
})

attachmentGame.ManualReg("ar15_handguard",{
    ["ar15_handguard_colt"] = {"ar15_handguard_colt"}
})