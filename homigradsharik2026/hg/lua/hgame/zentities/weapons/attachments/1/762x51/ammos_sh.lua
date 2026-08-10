ammoGame.Reg({
    name = "762x51_m61",
    printname = "762x51 M61",
    desc = "762x51 M16",

    Material = "models/hmcd_ammobox_38",
    Scale = 1,

    icon = "entities/eft_attachments/ammo/762x51/m61.png",

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

    AmmoCalibre = "762x51",

    ShellSound = "heavy",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/762x51.mdl"
})

ammoGame.callibreIndex["762x51"] = "762x51_m61"