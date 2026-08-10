local vector = Vector(0,0,0.5)
local angle = Angle()

WepAtt("ak74_handguard_wood",{
    printName = "AK Handguard Wood",
    icon = "entities/eft_ak_attachments/hg/74.png",
    category = "handguard",
    model = "models/weapons/arc9/darsu_eft/mods/ak_hg_ak74_std_wood.mdl",

    cosmetic = {
        ["akm"] = {
            printName = "AKM",
            icon = "entities/eft_ak_attachments/hg/akm.png",
            model = "models/weapons/arc9/darsu_eft/mods/ak_hg_akm_std_wood.mdl"
        },
        ["aks"] = {
            printName = "AKS",
            icon = "entities/eft_ak_attachments/hg/136.png",
            model = "models/weapons/arc9/darsu_eft/mods/ak_hg_ak74_std_plum.mdl"
        }
    }
})

WepAtt("ak_handguard_ovgp",{
    printName = "CNC Guns 'OV GP'",

    icon = "entities/eft_ak_attachments/hg/cnc.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_hg_cncguns.mdl",

    slots = {
        ["1"] = {
            name = "Force Grip",
            slotPos = Vector(0,-3,-1.7),
            slots = {
                [0] = {false},
                ["1"] = {"mount_keymod_forcegrip",vec = Vector(0,-4.3,-1.62),ang = Angle(0,-90,-90)}
            }
        },
        ["2"] = {
            name = "Tactical Left",
            slotPos = Vector(0.7,-3,-0.5),
            slots = {
                [0] = {false},
                ["1"] = {"mount_keymod_tactical",vec = Vector(0.8,-4.75,-0.48),ang = Angle(0,-90,0)}
            }
        },
        ["3"] = {
            name = "Tactical Right",
            slotPos = Vector(-0.7,-3,-0.5),
            slots = {
                [0] = {false},
                ["1"] = {"mount_keymod_tactical",vec = Vector(-0.8,-4.75,-0.48),ang = Angle(180,90,0)}
            }
        },
    }
})

WepAtt("ak_handguard_x47",{
    printName = "TDI X47",

    icon = "entities/eft_ak_attachments/hg/x47.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_hg_x47.mdl"
})

WepAtt("ak74_handguard_hexagon",{
    printName = "Hexagon",
    category = "handguard",

    icon = "entities/eft_ak_attachments/hg/hexa.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_hg_hexagon.mdl",
    
    slots = {
        ["1"] = {
            name = "Down Close",
            slotPos = Vector(-1,-6,-0.75),
            slots = {
                [0] = {false},
                ["1"] = {"mount_hexagon_forcegrip",vec = Vector(0,-4,-1.62),ang = Angle(0,-90,-90)}
            }
        },
        ["2"] = {
            name = "Down",
            slotPos = Vector(0,-13,-1),
            slots = {
                [0] = {false},
                ["1"] = {"mount_hexagon_tactical",vec = Vector(0,-14,-1.62),ang = Angle(0,-90,-90)}
            }
        },
        ["3"] = {
            name = "Left",
            slotPos = Vector(1.5,-13,0),
            slots = {
                [0] = {false},
                ["1"] = {"mount_hexagon_tactical",vec = Vector(1.1,-14,-0.6),ang = Angle(0,-90,0)}
            }
        },
        ["4"] = {
            name = "Right",
            slotPos = Vector(-1.5,-13,0),
            slots = {
                [0] = {false},
                ["1"] = {"mount_hexagon_tactical",vec = Vector(-1.1,-14,-0.6),ang = Angle(180,90,0)}
            }
        }
    }
})

local att = WepAtt("mount_hexagon_tactical",{
    printName = "Mount Hexagon - Tactical",

    icon = "entities/eft_ak_attachments/hg/hexrail.png",
    model = "models/weapons/arc9_eft_shared/atts/mounts/hexagon.mdl",

    slots = {
        ["1"] = {
            name = "Tactical",
            slotPos = Vector(0,1,0),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"flashlight",Vector(0.9,0.45,0),Angle(0,0,-90))

local att = WepAtt("mount_hexagon_forcegrip",{
    printName = "Mount Hexagon - Force Grip",

    icon = "entities/eft_ak_attachments/hg/hexrailm.png",
    model = "models/weapons/arc9_eft_shared/atts/mounts/hkey_rail.mdl",

    slots = {
        ["1"] = {
            name = "ForceGrip",
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"forcegrip",Vector(0,0.38,0),Angle(0,0,90))

local att = WepAtt("ak_handguard_magpul_moe",{
    printName = "Magpul MOE",

    icon = "entities/eft_ak_attachments/hg/zhu.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_hg_magpul_moe.mdl",

    slots = {
        ["1"] = {
            name = "Down",
            slotPos = Vector(0,-4,-2),
            slots = {
                [0] = {false},
                ["1"] = {"mount_mlok_forcegrip",vec = Vector(0,-5.1,-1.76),ang = Angle(0,-90,-90)}
            }
        },
        ["2"] = {
            name = "Left",
            slotPos = Vector(1,-4,0),
            slots = {
                [0] = {false},
                ["1"] = {"mount_mlok_tactical",vec = Vector(0.88,-4.2,-0.35),ang = Angle(0,-90,0)}
            }
        },
        ["3"] = {
            name = "Right",
            slotPos = Vector(-1,-4,0),
            slots = {
                [0] = {false},
                ["1"] = {"mount_mlok_tactical",vec = Vector(-0.88,-4.2,-0.35),ang = Angle(180,90,0)}
            }
        }
    }
})

attachmentGame.ManualReg("ak_handguard",{
    ["ak74_handguard_wood"] = {"ak74_handguard_wood"},
    ["ak74_handguard_hexagon"] = {"ak74_handguard_hexagon",},
    ["ak_handguard_ovgp"] = {"ak_handguard_ovgp"},
    ["ak_handguard_magpul_moe"] = {"ak_handguard_magpul_moe"}
})