attachmentGame.RegCategory("kalimator",{printName = "Калиматоры",prio = 5})

WepAtt("kalimator_okp7",{
    printName = "OKP-7",
    desc = "nШирина треугольника 10 MOA\nВысота треугольника 5 MOA\nРастояния от боковых линий 30 MOA\nРастояния от центра прицела до нижней вертикальной линии 20 MOA.",
    category = "kalimator",
    icon = "entities/eft_attachments/scopes/okp7.png",

    model = "models/weapons/arc9/darsu_eft/mods/scope_all_ekb_okp7.mdl",

    StencilScopeAlways = true,
    Holosight = true,
    
    ScopeHeight = 1.1,
    ScopeRight = 0.1,

    StartSightValue = 0,
    EndSightValue = 3,

    RetricleMaterial = Material("homigrad/scopes/reticles/okp7.png"),
    RetricleSize = 1,
    Cam3D2DSize = 0.00029,

    BackCamera = 5,

    pp_cc_tab = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0.05,
        ["$pp_colour_addb"] = 0.05,
        ["$pp_colour_brightness"] = -0.06,
        ["$pp_colour_contrast"] = 1.1,
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0.01,
        ["$pp_colour_mulb"] = 0.01
    },
})

WepAtt("kalimator_okp7_nmount",{
    printName = "OKP-7 NMount",
    desc = "Ширина треугольника 10 MOA\nВысота треугольника 5 MOA\nРастояния от боковых линий 30 MOA\nРастояния от центра прицела до нижней вертикальной линии 20 MOA.",
    category = "kalimator",
    icon = "entities/eft_attachments/scopes/s_okp.png",

    model = "models/weapons/arc9_eft_shared/atts/optic/dovetail/okp7.mdl",

    StencilScopeAlways = true,
    Holosight = true,

    ScopeHeight = 0.6,
    ScopeRight = 0.23,

    StartSightValue = 0,
    EndSightValue = 3,

    RetricleMaterial = Material("homigrad/scopes/reticles/okp7.png"),
    RetricleSize = 1,
    Cam3D2DSize = 0.00029,

    pp_cc_tab = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0.,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    },
})

local retricleIndex = {
    {Material("homigrad/scopes/reticles/new/scope_all_walther_mrs_mark_000"),1},
    {Material("homigrad/scopes/reticles/new/scope_all_walther_mrs_mark_002"),2},
    {Material("homigrad/scopes/reticles/new/scope_all_walther_mrs_mark_003"),3},
}

WepAtt("kalimator_walther_mrs",{
    printName = "Walther Multi-Reticle Sight",
    icon = "entities/eft_attachments/scopes/mrs.png",
    desc = "1 прицел 5 MOA\n2 прицел 2 MOA",
    category = "kalimator",
    model = "models/weapons/arc9/darsu_eft/mods/scope_all_walther_mrs.mdl",

    Holosight = true,
    StencilScopeAlways = true,

    ScopeHeight = 1.445,
    StartSightValue = 0,
    EndSightValue = 5,
    
    RetricleSize = 1,
    Cam3D2DSize = 0.0005,

    pp_cc_tab = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0.04,
        ["$pp_colour_addb"] = 0.07, 
        ["$pp_colour_brightness"] = -0.1,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    },

    onWheel = function(attConfig,wep,wheel)
        wep.scopeValue = ((wep.scopeValue or 0) + wheel) % (#retricleIndex - 1)

        local retricle = retricleIndex[wep.scopeValue + 1]
        attConfig.RetricleMaterial = retricle[1]

        sound.EmitScreen("arc9_eft_shared/weapon_light_switcher2.ogg",1,150)
    end
})

WepAtt("kalimator_rmr",{
    printName = "RMR",
    desc = "",
    category = "kalimator",
    icon = "entities/eft_attachments/scopes/rmr.png",

    model = "models/weapons/arc9/darsu_eft/mods/scope_base_trijicon_rmr.mdl",

    StencilScopeAlways = true,
    Holosight = true,

    ScopeHeight = 0.6,

    StartSightValue = 0,
    EndSightValue = 3,

    RetricleMaterial = Material("homigrad/scopes/reticles/new/scope_all_walther_mrs_mark_001"),
    RetricleSize = 1,
    Cam3D2DSize = 0.0005,
})

attachmentGame.ManualReg("scope_mini",{
    ["kalimator_rmr"] = {
        "kalimator_rmr",
        vec = Vector(),
        ang = Angle(0,0,0)
    },
})

WepAtt("holosight_vortex_razor",{
    model = "models/weapons/arc9/darsu_eft/mods/scope_all_vortex_razor_amg_uh-1.mdl",
    icon = "entities/eft_attachments/scopes/uh1.png",

    StencilScopeAlways = true,
    Holosight = true,
    
    ScopeHeight = 1.7,
    StartSightValue = 0,
    EndSightValue = 5,

    RetricleMaterial = Material("homigrad/scopes/reticles/new/scope_all_vortex_razor_amg_uh-1_marks.png"),
    RetricleSize = 1,
    Cam3D2DSize = 0.0005,
})


WepAtt("holosight_eotech",{
    model = "models/weapons/arc9_eft_shared/atts/optic/eft_optic_exps3.mdl",
    icon = "entities/eft_attachments/scopes/exps3.png",
    
    StencilScopeAlways = true,
    Holosight = true,
    
    ScopeHeight = 1.7,
    StartSightValue = 0,
    EndSightValue = 5,

    RetricleMaterial = Material("homigrad/scopes/reticles/new/scope_all_eotech_xps3-4_marks.png"),
    RetricleSize = 1,
    Cam3D2DSize = 0.0005,
})