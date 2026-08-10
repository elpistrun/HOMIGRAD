ammoGame.Reg({
    name = "9x33_fmj",
    printname = "357 Magnum FMJ",
    desc = "9x33 - 357 Magnum FMJ",

    Material = "models/hmcd_ammobox_38",
    Scale = 1,

    icon = "entities/eft_deagle_attachments/357fmj.png",

    bulletInfo = {
        Speed = 400,
        Mass = 8,
        Hardness = 1,
        Expansion = 1,
        
        Diameter = 9,
        BalisticCooperator = 0.15,

        Damage = 34,
    },

    InvSoundUse = {"weapons/shells/9mm_shell_concrete1.wav","weapons/shells/9mm_shell_concrete2.wav","weapons/shells/9mm_shell_concrete3.wav"},

    AmmoCalibre = "9x33",

    ShellSound = "9mm",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/357.mdl"
})

ammoGame.callibreIndex["9x33"] = "9x33_fmj"