ammoGame.Reg({
    name = "9x39_sp5",
    printname = "9x39 SP5",
    desc = "9x39 SP5",
    
    Material = "models/hmcd_ammobox_38",
    Scale = 1,

    icon = "entities/eft_val_attachments/sp5.png",

    bulletInfo = {
        Speed = 290,
        Mass = 16.1,
        Hardness = 1,
        Expansion = 1,
        
        Diameter = 9,
        BalisticCooperator = 0.1,

        Damage = 38,
    },

    InvSoundUse = {"weapons/shells/9mm_shell_concrete1.wav","weapons/shells/9mm_shell_concrete2.wav","weapons/shells/9mm_shell_concrete3.wav"},

    AmmoCalibre = "9x39",
    
    ShellSound = "9mm",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/9x19.mdl"
})

ammoGame.callibreIndex["9x39"] = "9x39_sp5"