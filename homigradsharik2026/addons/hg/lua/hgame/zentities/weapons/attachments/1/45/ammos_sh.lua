ammoGame.Reg({
    name = "45_fmj",
    printname = "45FMJ",
    desc = ".45 AUTO FMJ",

    Material = "models/hmcd_ammobox_38",
    Scale = 1,

    icon = "entities/eft_attachments/ammo/45acp/fmj.png",

    bulletInfo = {
        Speed = 250,
        Mass = 15,
        Hardness = 1,
        Expansion = 1,
        
        Diameter = 4.5,
        BalisticCooperator = 0.08,

        Damage = 30,
    },

    InvSoundUse = {"weapons/shells/9mm_shell_concrete1.wav","weapons/shells/9mm_shell_concrete2.wav","weapons/shells/9mm_shell_concrete3.wav"},

    AmmoCalibre = "45",
    
    ShellSound = "9mm",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/9x19.mdl"
})

ammoGame.callibreIndex["45"] = "45_fmj"