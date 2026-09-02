WepAtt("silencer_545x39_hexagon",{
    printName = "Silencer Hexagon 545x39",

    icon = "entities/eft_ak_attachments/muzzle/hexa.png",
    model = "models/weapons/arc9/darsu_eft/mods/silencer_akm_hexagon_akm_762x39.mdl",
    MuzzlePos = Vector(7.3,0,0),

    Silencer = true,
    MuzzleFlashScale = false,
    MuzzleGasSide = false,
    MuzzleGasForward = 3
})

WepAtt("muzzle_545x39_reactor",{
    printName = "Muzzle Hexagon Reactor 545x39",

    icon = "entities/eft_ak_attachments/muzzle/reactor.png",
    model = "models/weapons/arc9/darsu_eft/mods/muzzle_ak_hexagon_reactor_muzzle_brake_545x39.mdl",
    MuzzlePos = Vector(1.9,0,0),

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,0,4),
            slots = {
                [0] = {false},
                ["suppressor_waffle"] = {"suppressor_waffle"}
            }
        }
    }
})

WepAtt("suppressor_waffle",{
    printName = "Supressor Waffle 545x39",
    icon = "entities/eft_ak_attachments/muzzle/waffle.png",
    model = "models/weapons/arc9/darsu_eft/mods/silencer_hex_hexagon_wafflemaker_suppressor_545x39.mdl",
    MuzzlePos = Vector(4.1,0,0),

    Silencer = true,
    MuzzleFlashScale = false,
    MuzzleGasSide = false,
    MuzzleGasForward = 3
})

WepAtt("muzzle_545x39_to_556x45",{
    printName = "Muzzle CNC Warrior 556x39 To 556x45",
    icon = "entities/eft_ak_attachments/muzzle/cncwar.png",
    model = "models/weapons/arc9/darsu_eft/mods/muzzle_ak_cnc_warrior_ar15_thread_adapter.mdl",

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,-3,0),
            slots = {
                [0] = {false},
                ["muzzle_556x45_colt"] = {"muzzle_556x45_colt",vec = Vector(1.22,0,0)}
            }
        }
    },

    MuzzlePos = Vector(0.75,0,0)
})

attachmentGame.ManualReg("muzzle_545",{
    ["silencer_545x39_hexagon"] = {"silencer_545x39_hexagon",bone = "mod_muzzle"},
    ["muzzle_545x39_reactor"] = {"muzzle_545x39_reactor",bone = "mod_muzzle"},
    ["muzzle_545x39_to_556x45"] = {"muzzle_545x39_to_556x45",bone = "mod_muzzle"}
})