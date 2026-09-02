-- Additional weapon attachments

-- === Extra Force Grips ===

WepAtt("forcegrip_rvg",{
    printName = "Magpul RVG",
    icon = "entities/eft_attachments/foregrips/kac.png",
    category = "forcegrip",
    model = "models/weapons/arc9/darsu_eft/mods/fg_rvg.mdl",

    tpikLeft = true
})

WepAtt("forcegrip_afg",{
    printName = "Magpul AFG",
    icon = "entities/eft_attachments/foregrips/kac.png",
    category = "forcegrip",
    model = "models/weapons/arc9/darsu_eft/mods/fg_afg.mdl",

    tpikLeft = true
})

WepAtt("forcegrip_se5",{
    printName = "SE-5 Grip",
    icon = "entities/eft_attachments/foregrips/kac.png",
    category = "forcegrip",
    model = "models/weapons/arc9/darsu_eft/mods/fg_se5.mdl",

    tpikLeft = true
})

WepAtt("forcegrip_shift",{
    printName = "Shift Grip",
    icon = "entities/eft_attachments/foregrips/kac.png",
    category = "forcegrip",
    model = "models/weapons/arc9/darsu_eft/mods/fg_shift.mdl",

    tpikLeft = true
})

attachmentGame.ManualReg("forcegrip",{
    ["forcegrip_rvg"] = {
        "forcegrip_rvg",
        vec = Vector(),
        ang = Angle(0,0,0)
    },
    ["forcegrip_afg"] = {
        "forcegrip_afg",
        vec = Vector(),
        ang = Angle(0,0,0)
    },
    ["forcegrip_se5"] = {
        "forcegrip_se5",
        vec = Vector(),
        ang = Angle(0,0,0)
    },
    ["forcegrip_shift"] = {
        "forcegrip_shift",
        vec = Vector(),
        ang = Angle(0,0,0)
    },
})

-- === Extra Tactical Devices ===

WepAtt("flashlight_scout",{
    printName = "Surefire Scout",
    category = "flashlight",
    icon = "entities/eft_attachments/tactical/k2u.png",
    model = "models/weapons/arc9/darsu_eft/mods/tac_scout.mdl",
})

WepAtt("flashlight_x400",{
    printName = "X400",
    category = "flashlight",
    icon = "entities/eft_attachments/tactical/kr2.png",
    model = "models/weapons/arc9/darsu_eft/mods/tac_x400.mdl",
})

attachmentGame.ManualReg("flashlight",{
    ["flashlight_scout"] = {
        "flashlight_scout",
        vec = Vector(-0.6,0,0),
        ang = Angle()
    },
    ["flashlight_x400"] = {
        "flashlight_x400",
        vec = Vector(-0.6,0,0),
        ang = Angle()
    }
})

-- === Extra Lasers ===

WepAtt("laser_peq15",{
    printName = "AN/PEQ-15",
    category = "laser",
    icon = "entities/eft_attachments/tactical/tbl.png",
    model = "models/weapons/arc9/darsu_eft/mods/tac_peq15.mdl",
})

WepAtt("laser_dbal",{
    printName = "DBAL-A2",
    category = "laser",
    icon = "entities/eft_attachments/tactical/lastac.png",
    model = "models/weapons/arc9/darsu_eft/mods/tac_dbal.mdl",
})

attachmentGame.ManualReg("laser",{
    ["laser_peq15"] = {
        "laser_peq15",
        vec = Vector(-0.5,0,0),
        ang = Angle()
    },
    ["laser_dbal"] = {
        "laser_dbal",
        vec = Vector(-0.5,0,0),
        ang = Angle()
    }
})

-- === Extra Holosights ===

WepAtt("holosight_eotech",{
    printName = "EOTech XPS3",
    category = "kalimator",
    icon = "entities/eft_attachments/scopes/okp7.png",

    model = "models/weapons/arc9/darsu_eft/mods/scope_eotech_xps3.mdl",

    StencilScopeAlways = true,
    Holosight = true,

    ScopeHeight = 1.1,
    ScopeRight = 0.1,

    StartSightValue = 0,
    EndSightValue = 3,

    RetricleMaterial = Material("homigrad/scopes/reticles/eotech.png"),
    RetricleSize = 1,
    Cam3D2DSize = 0.00029,

    BackCamera = 5,
})

WepAtt("holosight_aimpoint",{
    printName = "Aimpoint CompM4",
    category = "kalimator",
    icon = "entities/eft_attachments/scopes/okp7.png",

    model = "models/weapons/arc9/darsu_eft/mods/scope_aimpoint_compm4.mdl",

    StencilScopeAlways = true,
    Holosight = true,

    ScopeHeight = 1.1,
    ScopeRight = 0.1,

    StartSightValue = 0,
    EndSightValue = 3,

    RetricleMaterial = Material("homigrad/scopes/reticles/aimpoint.png"),
    RetricleSize = 1,
    Cam3D2DSize = 0.00029,

    BackCamera = 5,
})

WepAtt("holosight_vortex_razor",{
    printName = "Vortex Razor AMR",
    category = "kalimator",
    icon = "entities/eft_attachments/scopes/okp7.png",

    model = "models/weapons/arc9/darsu_eft/mods/scope_vortex_razor_amr.mdl",

    StencilScopeAlways = true,
    Holosight = true,

    ScopeHeight = 1.1,
    ScopeRight = 0.1,

    StartSightValue = 0,
    EndSightValue = 3,

    RetricleMaterial = Material("homigrad/scopes/reticles/vortex_razor.png"),
    RetricleSize = 1,
    Cam3D2DSize = 0.00029,

    BackCamera = 5,
})
