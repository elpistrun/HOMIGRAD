ammoGame.Reg({
    name = "127x55_std",
    printname = "127x55 STD",
    desc = "127x55",

    Material = "models/hmcd_ammobox_38",
    Scale = 1,

    icon = "entities/eft_attachments/ammo/127x55/std.png",

    bulletInfo = {
        Speed = 820,
        Mass = 67,
        Hardness = 3,
        Expansion = 1,
        
        Diameter = 12.7,
        BalisticCooperator = 0.45,

        Damage = 75,
    },

    InvSoundUse = {"weapons/shells/9mm_shell_concrete1.wav","weapons/shells/9mm_shell_concrete2.wav","weapons/shells/9mm_shell_concrete3.wav"},

    AmmoCalibre = "127x55",

    ShellSound = "heavy",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/762x54r.mdl"
})

ammoGame.callibreIndex["127x55"] = "127x55_std"