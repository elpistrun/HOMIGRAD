attachmentGame.RegCategory("flashlight",{printName = "Фонарики",prio = 3})

WepAtt("flashlight_kleh2u",{
    printName = "KLEH2U",
    category = "flashlight",
    icon = "entities/eft_attachments/tactical/k2u.png",
    model = "models/weapons/arc9/darsu_eft/mods/tac_kleh2u.mdl",
})

WepAtt("flashlight_kr2",{
    printName = "KR2",
    category = "flashlight",
    icon = "entities/eft_attachments/tactical/kr2.png",
    model = "models/weapons/arc9/darsu_eft/mods/tac_kr2.mdl",
})

WepAtt("flashlight_kleh2",{
    printName = "KLEH2",
    category = "flashlight",
    icon = "entities/eft_attachments/tactical/kr2.png",
    model = "models/weapons/arc9/darsu_eft/mods/tac_kleh2.mdl",
})

attachmentGame.ManualReg("flashlight",{
    ["flashlight_kleh2u"] = {
        "flashlight_kleh2u",
        vec = Vector(-0.6,0,0),
        ang = Angle()
    },
    ["flashlight_kr2"] = {
        "flashlight_kr2",
        vec = Vector(-0.6,0,0),
        ang = Angle()
    },
    ["flashlight_kleh2"] = {
        "flashlight_kleh2",
        vec = Vector(-0.857,0,0),
        ang = Angle()
    }
})

attachmentGame.RegCategory("laser",{printName = "Лазеры",prio = 4})

WepAtt("laser_ncstar",{
    printName = "NCSTAR",
    category = "laser",
    icon = "entities/eft_attachments/tactical/tbl.png",
    model = "models/weapons/arc9/darsu_eft/mods/tac_ncstar_tbl.mdl",
})

WepAtt("laser_lastac2",{
    printName = "LASTAC2",
    category = "laser",
    icon = "entities/eft_attachments/tactical/lastac.png",
    model = "models/weapons/arc9/darsu_eft/mods/tac_lastac2.mdl",
})

attachmentGame.ManualReg("laser",{
    ["laser_ncstar"] = {
        "laser_ncstar",
        vec = Vector(-0.5,0,0),
        ang = Angle()
    },
    ["laser_lastac2"] = {
        "laser_lastac2",
        vec = Vector(-0.4,0,0),
        ang = Angle()
    }
})