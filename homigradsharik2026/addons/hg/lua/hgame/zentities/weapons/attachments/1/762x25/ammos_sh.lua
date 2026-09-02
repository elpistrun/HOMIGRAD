ammoGame.Reg({
    name = "762x25",
    printname = "762x25 FMJ",
    desc = "762x25 FMJ",

    Material = "models/hmcd_ammobox_38",
    Scale = 1,

    icon = "entities/eft_attachments/ammo/762x25/fmj.png",

    bulletInfo = {
        Speed = 830,
        Mass = 9.7,
        Hardness = 1,
        Expansion = 1,
        
        Diameter = 7.62,
        BalisticCooperator = 0.4,
        
        Damage = 50,
        effectMul = 1.8,
    },

    InvSoundUse = {"weapons/shells/9mm_shell_concrete1.wav","weapons/shells/9mm_shell_concrete2.wav","weapons/shells/9mm_shell_concrete3.wav"},

    AmmoCalibre = "762x25",

    ShellSound = "heavy",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/762x25.mdl"
})

ammoGame.callibreIndex["762x25"] = "762x25_fmj"