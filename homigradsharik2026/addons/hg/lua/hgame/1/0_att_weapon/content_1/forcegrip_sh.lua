attachmentGame.RegCategory("forcegrip",{printName = "Force Grip",prio = 7})

WepAtt("forcegrip_kac",{
    printName = "ForceGrip KAC",
    icon = "entities/eft_attachments/foregrips/kac.png",
    category = "forcegrip",
    model = "models/weapons/arc9/darsu_eft/mods/fg_kac.mdl",

    tpikLeft = true
})

attachmentGame.ManualReg("forcegrip",{
    ["forcegrip_kac"] = {
        "forcegrip_kac",
        vec = Vector(),
        ang = Angle(0,0,0)
    },
})