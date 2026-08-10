ammoGame.Reg({
    name = "556x45_m855",
    printname = "556x45 M855",
    desc = "556x45 M855",

    Material = "models/hmcd_ammobox_556",
    Scale = 1,

    icon = "entities/eft_attachments/ammo/556/m855.png",

    bulletInfo = {
        Speed = 920,
        Mass = 4.02,
        Diameter = 5.56,
        DragModelName = "G7",
        BalisticCoeff = 0.28,

        Hardness = 1,
        Expansion = 1,
        Damage = 34,
    },

    InvSoundUse = {"weapons/shells/556mm_shell_concrete1.wav","weapons/shells/556mm_shell_concrete2.wav","weapons/shells/556mm_shell_concrete3.wav"},

    AmmoCalibre = "556x45",

    ShellSound = "556mm",
    ShellModel = "models/weapons/arc9_eft_shared/shells/eft_shell_556_m855.mdl"
})

ammoGame.callibreIndex["556x45"] = "556x45_m855"