WepAtt("ar15_grip_colt",{
    printName = "Colt",
    icon = "entities/eft_attachments/pgrips/ar15grips/a2.png",
    model = "models/weapons/arc9/darsu_eft/mods/pistolgrip_ar15_colt_a2.mdl"
})

WepAtt("ar15_grip_skeleton",{
    printName = "ST2 Skeleton",
    icon = "entities/eft_attachments/pgrips/ar15grips/f1s1.png",
    model = "models/weapons/arc9/darsu_eft/mods/pistolgrip_ar15_f1_firearms_st2_skeletonized.mdl"
})

WepAtt("ar15_grip_stark",{
    printName = "Stark",
    icon = "entities/eft_attachments/pgrips/ar15grips/stark.png",
    model = "models/weapons/arc9/darsu_eft/mods/pistolgrip_ar15_stark_ar_rifle_grip.mdl"
})

attachmentGame.ManualReg("ar15_grip",{
    ["ar15_grip_colt"] = {"ar15_grip_colt"},
    ["ar15_grip_skeleton"] = {"ar15_grip_skeleton"},
    ["ar15_grip_stark"] = {"ar15_grip_stark"}
})
