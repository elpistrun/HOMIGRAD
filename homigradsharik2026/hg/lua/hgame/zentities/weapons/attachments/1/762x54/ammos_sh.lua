ammoGame.Reg({
    name = "762x54_std",
    printname = "762x54 STD",
    desc = "762x54",

    Material = "models/hmcd_ammobox_38",
    Scale = 1,

    icon = "entities/eft_attachments/ammo/762x54r/std.png",

    bulletInfo = {
        Speed = 820,
        Mass = 10,
        Hardness = 1,
        Expansion = 1,
        
        Diameter = 7.62,
        BalisticCooperator = 0.45,

        Damage = 45,
    },

    InvSoundUse = {"weapons/shells/9mm_shell_concrete1.wav","weapons/shells/9mm_shell_concrete2.wav","weapons/shells/9mm_shell_concrete3.wav"},

    AmmoCalibre = "762x54",

    ShellSound = "heavy",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/762x54r.mdl"
})

ammoGame.callibreIndex["762x54"] = "762x54_std"