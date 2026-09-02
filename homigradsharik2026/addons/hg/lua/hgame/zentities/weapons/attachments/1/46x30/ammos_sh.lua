ammoGame.Reg({
    name = "46x30_fmj",
    printname = "46x30 FMJ",
    desc = "46x30 FMJ",

    Material = "models/hmcd_ammobox_38",
    Scale = 1,

    icon = "entities/eft_mp7_attachments/fmj.png",

    bulletInfo = {
        Speed = 600,
        Mass = 2,
        Hardness = 1,
        Expansion = 1,
        
        Diameter = 4.6,
        BalisticCooperator = 0.1,

        Damage = 30,
    },

    InvSoundUse = {"weapons/shells/9mm_shell_concrete1.wav","weapons/shells/9mm_shell_concrete2.wav","weapons/shells/9mm_shell_concrete3.wav"},

    AmmoCalibre = "46x30",

    ShellSound = "9mm",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/9x19.mdl"
})

ammoGame.callibreIndex["46x30"] = "46x30_fmj"