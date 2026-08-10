WepAtt("muzzle_12_mecyl",{
    printName = "Muzzle Mecyl 12",

    icon = "entities/eft_attachments/muzzles/mecyl.png",
    model = "models/weapons/arc9/darsu_eft/mods/muzzle_12g_me_muzzle_adapter.mdl",
    MuzzlePos = Vector(2.4,0,0),

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,0,3),
            slots = {
                [0] = {false},
                ["silencer_12_hexagon"] = {"silencer_12_hexagon",vec = Vector(1.34,0,0)}
            }
        }
    }
})

WepAtt("silencer_12_hexagon",{
    printName = "Silencer Hexagon 12",

    icon = "entities/eft_attachments/muzzles/hexa12k.png",
    model = "models/weapons/arc9/darsu_eft/mods/silencer_12g_hexagon_12k.mdl",
    MuzzlePos = Vector(10.1,0,0),

    Silencer = true,
    MuzzleFlashScale = false,
    MuzzleGasSide = false,
    MuzzleGasForward = 3
})

attachmentGame.ManualReg("muzzle_12",{
    ["muzzle_12_mecyl"] = {"muzzle_12_mecyl",bone = "mod_muzzle"},
    ["silencer_12_hexagon"] = {"silencer_12_hexagon",bone = "mod_muzzle"}
})