ammoGame.Reg({
    name = "9x21_p",
    printname = "9x21 П",
    desc = "9x21 П (7H28)",
    
    Material = "models/hmcd_ammobox_38",
    Scale = 1,

    icon = "entities/eft_sr2m_attachments/p.png",

    bulletInfo = {
        Speed = 360,
        Mass = 8,
        Hardness = 1,
        Expansion = 1,

        Diameter = 9,
        BalisticCooperator = 0.1,

        Damage = 21
    },

    InvSoundUse = {"weapons/shells/9mm_shell_concrete1.wav","weapons/shells/9mm_shell_concrete2.wav","weapons/shells/9mm_shell_concrete3.wav"},

    AmmoCalibre = "9x21",
    
    ShellSound = "9mm",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/9x19.mdl"
})

ammoGame.callibreIndex["9x21"] = "9x21_p"