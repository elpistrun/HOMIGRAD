ammoGame.Reg({
    name = "12x70_def",
    printname = "12x70 DEF",
    desc = "12x70 DEF\nСкорость пули 415 м/с\nУрон: 70 едениц (если все дроби попали в цель)\n12 Стальный шариков",

    Material = "models/hmcd_ammobox_12",
    Scale = 1,

    icon = "entities/eft_attachments/ammo/12x70/def.png",

    bulletInfo = {
        Speed = 415,
        Mass = 5.38,
        Diameter = 8.5,

        DragModelName = "GS",
        BalisticCoeff = 0.5,
        
        Damage = 125,
        DamageType = DMG_BUCKSHOT,

        Count = 9,
        Spray = 0.8,

        SmokeMul = 0.1,
        
        MulPhysicsForce = 5,
    },

    AmmoCalibre = "12x70",
    
    ShellSound = "12mm",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/patron_12x70_shell.mdl"
})

ammoGame.Reg({
    name = "12x70_blank",
    printname = "12x70 BLANK",
    desc = "12x70 BLANK",

    Material = "models/hmcd_ammobox_12",
    Scale = 1,

    icon = "entities/eft_attachments/ammo/12x70/p6u.png",

    AmmoCalibre = "12x70",

    ShellSound = "12mm",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/patron_12x70_shell.mdl"
})

ammoGame.callibreIndex["12x70"] = "12x70_def"

ammoGame.uiInvUse["12mm"] = {
    pitch = 120,
    list = {
        "weapons/shells/12cal_shell_plastic1.wav",
        "weapons/shells/12cal_shell_plastic2.wav",
        "weapons/shells/12cal_shell_plastic3.wav",
        "weapons/shells/12cal_shell_plastic4.wav",
        "weapons/shells/12cal_shell_plastic5.wav"
    }
}