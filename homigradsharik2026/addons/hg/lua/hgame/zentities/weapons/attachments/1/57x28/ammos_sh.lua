ammoGame.Reg({
    name = "r57x28f",
    printname = "R 57x28 F",
    desc = "R 57x28 F",

    Material = "models/hmcd_ammobox_38",
    Scale = 1,

    icon = "entities/eft_57_attachments/r37f.png",

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

    AmmoCalibre = "57x28",

    ShellSound = "9mm",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/9x19.mdl"
})

ammoGame.callibreIndex["57x28"] = "r57x28f"