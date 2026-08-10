ammoGame.Reg({
    name = "545x39_fmj",
    printname = "545x39 FMJ",
    desc = "545x39 7H10",

    Material = "models/hmcd_ammobox_556",
    Scale = 1,

    icon = "entities/eft_attachments/ammo/545/pp.png",

    bulletInfo = {
        Speed = 880,
        Mass = 3.62,
        Hardness = 1,
        Expansion = 1,

        Diameter = 5.45,
        BalisticCooperator = 0.3,

        Damage = 32
    },

    AmmoCalibre = "545x39",

    ShellSound = "556mm",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/545x39.mdl",
})

ammoGame.callibreIndex["545x39"] = "545x39_fmj"

ammoGame.uiInvUse["556mm"] = {
    pitch = 120,
    list = {
        "weapons/shells/556mm_shell_plastic1.wav",
        "weapons/shells/556mm_shell_plastic2.wav",
        "weapons/shells/556mm_shell_plastic3.wav",
        "weapons/shells/556mm_shell_plastic4.wav",
        "weapons/shells/556mm_shell_plastic5.wav"
    }
}