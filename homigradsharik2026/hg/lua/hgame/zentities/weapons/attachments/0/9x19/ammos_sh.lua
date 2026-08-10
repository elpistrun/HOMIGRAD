ammoGame.Reg({
    name = "9x19_pst_gzh",
    printname = "9x19 ПС гж",
    desc = "9x19 ПС гж (индекс ГРАУ - 7Н21)",

    Material = "models/hmcd_ammobox_9",
    Scale = 1,

    icon = "entities/eft_attachments/ammo/9x19/pstgzh.png",

    bulletInfo = {
        Speed = 445,
        Mass = 5.4,
        Hardness = 1,
        Expansion = 1,
        
        Diameter = 9,
        BalisticCooperator = 0.1,

        Damage = 27,
    },

    AmmoCalibre = "9x19",
    
    ShellSound = "9mm",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/9x19.mdl"
})

ammoGame.callibreIndex["9x19"] = "9x19_pst_gzh"

ammoGame.uiInvUse["9mm"] = {
    pitch = 120,
    list = {
        "weapons/shells/9mm_shell_plastic1.wav",
        "weapons/shells/9mm_shell_plastic2.wav",
        "weapons/shells/9mm_shell_plastic3.wav",
        "weapons/shells/9mm_shell_plastic4.wav",
        "weapons/shells/9mm_shell_plastic5.wav"
    }
}