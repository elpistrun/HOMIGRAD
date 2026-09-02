ammoGame.Reg({
    name = "762x39_hp",
    printname = "762x39 HP",
    desc = "762x39 HP",

    Material = "models/hmcd_ammobox_38",
    Scale = 1,

    icon = "entities/eft_attachments/ammo/762x39/ps.png",

    bulletInfo = {
        Speed = 760,
        Mass = 7.9,
        Hardness = 1,
        Expansion = 1,
        
        Diameter = 7.62,
        BalisticCooperator = 0.27,

        Damage = 45,
        effectMul = 1.8,
    },

    AmmoCalibre = "762x39",
    
    ShellSound = "heavy",
    ShellModel = "models/weapons/arc9/darsu_eft/shells/762x39.mdl"
})

ammoGame.callibreIndex["762x39"] = "762x39_hp"

ammoGame.uiInvUse["heavy"] = {
    pitch = 120,
    list = {
        "weapons/shells/heavy_shell_plastic1.wav",
        "weapons/shells/heavy_shell_plastic2.wav",
        "weapons/shells/heavy_shell_plastic3.wav",
        "weapons/shells/heavy_shell_plastic4.wav",
        "weapons/shells/heavy_shell_plastic5.wav"
    }
}