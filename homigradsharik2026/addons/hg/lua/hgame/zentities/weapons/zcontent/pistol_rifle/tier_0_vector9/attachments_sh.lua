local SWEP = oop.Get("wep_vector9")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {
        ["0"] = {slotPos = Vector(0,-12.5,-0.5)},
        ["1"] = {
            name = "Barrel",
            slotPos = Vector(0,-20,0.5),
            slots = {
                [0] = {"vector9_barrel"},
                ["vector9_barrel2"] = {"vector9_barrel2"}
            }
        },
        ["2"] = {
            name = "Stock",
            slotPos = Vector(0,-8.5,0.8),
            slots = {
                [0] = {false},
                ["vector9_stock"] = {"vector9_stock"},
                ["vector9_stock_tube"] = {"vector9_stock_tube"}
            }
        },
        ["3"] = {
            name = "FS",
            slotPos = Vector(0,-22,2),
            slots = {
                [0] = {false}
            }
        },
        ["4"] = {
            name = "RS",
            slotPos = Vector(0,-11,2),
            slots = {
                [0] = {false}
            }
        },
        ["5"] = {
            name = "Mount Left",
            slotPos = Vector(2,-21.5,0),
            slots = {
                [0] = {false},
                ["vector9_mount"] = {"vector9_mount",vec = Vector(0.8,-22,-0.8),ang = Angle(0,-90,0)}
            }
        },
        ["6"] = {
            name = "Mount Right",
            slotPos = Vector(-2,-21.5,0),
            slots = {
                [0] = {false},
                ["vector9_mount"] = {"vector9_mount",vec = Vector(-0.8,-22,-0.8),ang = Angle(180,90,0)}
            }
        },
        ["7"] = {
            name = "Mount Down",
            slotPos = Vector(0,-21,-1),
            slots = {
                [0] = {false},
                ["vector9_mount_down"] = {"vector9_mount_down"},
                ["vector9_mount_mod"] = {"vector9_mount_mod"}
            }
        }
    }
}

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["4"].slots,"scope_mount",Vector(0,-14,1.55),Angle(0,0,0),{bone = "weapon"})

SWEP.AttachmentDefault = {
    {"1.1","muzzle_crissvector9"},
    {"2","vector9_stock"},
    {"4","kalimator_walther_mrs"}
}

function SWEP:InitWorldModelBodygroup(wm,tag,typeDraw)
    
end

local att = WepAtt("vector9_barrel",{
    printName = "Barrel",
    icon = "entities/eft_vector_attachments/95.png",
    bodygroupWM = {1,1},

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,-25,-0.75),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"muzzle_9",Vector(0,-23.9,-0.75),Angle(0,-90,0),{bone = "weapon"})

local att =  WepAtt("vector9_barrel2",{
    printName = "Barrel2",
    icon = "entities/eft_vector_attachments/96.png",
    bodygroupWM = {1,2},
    MuzzlePos = Vector(1,0,0),

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,-26,-0.75),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"muzzle_9",Vector(0,-24.8,-0.75),Angle(0,-90,0),{bone = "weapon"})

local att = WepAtt("vector9_stock",{
    printName = "Stock",
    icon = "entities/eft_vector_attachments/s.png",
    bodygroupWM = {2,1}
})

local att = WepAtt("vector9_stock_tube",{
    printName = "Stock Tube",
    icon = "entities/eft_vector_attachments/adap.png",
    bodygroupWM = {2,3},
    slots = {
        ["1"] = {
            name = "Stock",
            slotPos = Vector(0,-7,0.6),
            slots = {
                [0] = {false},
                ["ar15_stock_tube"] = {"ar15_stock_tube",vec = Vector(-0.07,-7.74,0.5),ang = Angle(0,-90,0)}
            }
        }
    }
})

local att = WepAtt("vector9_mount",{
    printName = "Mount Side",
    icon = "entities/eft_vector_attachments/side.png",
    model = "models/weapons/arc9/darsu_eft/mods/mount_vector_side_rail.mdl",
    slots = {
        ["1"] = {
            name = "Tactical",
            slotPos = Vector(0,0,0),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"flashlight",Vector(0.6,0.3,0),Angle(0,0,-90),{bone = "weapon"})

local att = WepAtt("vector9_mount_down",{
    printName = "Mount Down",
    icon = "entities/eft_vector_attachments/bot.png",
    bodygroupWM = {4,1},

    slots = {
        ["1"] = {
            name = "ForceGrip",
            slotPos = Vector(0,-21,-2.5),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"forcegrip",Vector(0,-21.3,-1.8),Angle(0,-90,0),{bone = "weapon"})

local att =  WepAtt("vector9_mount_mod",{
    printName = "Barrel2",
    icon = "entities/eft_vector_attachments/mod.png",
    bodygroupWM = {4,2},

    slots = {
        ["1"] = {
            name = "ForceGrip",
            slots = {
                [0] = {false}
            }
        }
    }
})