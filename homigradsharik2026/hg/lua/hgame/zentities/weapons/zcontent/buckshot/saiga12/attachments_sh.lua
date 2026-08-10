local SWEP = oop.Get("wep_saiga12k")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {
        ["0"] = {
            slotPos = Vector(0,-20,0),
            skin = {
                ["camo"] = 0,
            }
        },
        ["1"] = {
            name = "Dust Cover",
            slotPos = Vector(0,-14,1),
            slots = {
                [0] = {false},
                ["saiga12_dustcover"] = {"saiga12_dustcover"},
            }
        },
        ["2"] = {
            name = "HandGuard",
            slotPos = Vector(0,-23.4,0),
            slots = {
                [0] = {"saiga12_handguard"},
                ["saiga12_handguard_quad_rail"] = {"saiga12_handguard_quad_rail"},
                ["saiga12_handguard_usp340"] = {"saiga12_handguard_usp340"},
                ["saiga12_handguard_bravo18"] = {"saiga12_handguard_bravo18"},
                ["saiga12_handguard_mtu002"] = {"saiga12_handguard_mtu002"},
                ["saiga12_handguard_mtu002s"] = {"saiga12_handguard_mtu002s"}
            }
        },
        ["3"] = {
            name = "Grip",
            slotPos = Vector(0,-11,-3),
            slots = {}
        },
        ["4"] = {
            name = "Stock",
            slotPos = Vector(0,-7.5,-0.5),
            slots = {
                [0] = {false},
                ["saiga12_stock"] = {"saiga12_stock"},
                ["ak_stock_rpk"] = {"ak_stock_rpk",vec = Vector(0.65,-9.41,-0.67),ang = Angle(0,0,-2)}
            }
        },
        ["5"] = {
            name = "Muzzle",
            slotPos = Vector(0,-36,0),
            slots = {
                [0] = {false},
                ["saiga12_muzzle"] = {"saiga12_muzzle"}
            }
        },
        ["8"] = {
            name = "Sight",
            slotPos = Vector(0,-19,1.5),
            slots = {
                [0] = {false},
                ["saiga12_sight"] = {"saiga12_sight"},
                ["saiga12_handguard_quad_rail_upper"] = {"saiga12_handguard_quad_rail_upper"}
            }
        }
    }
}

SWEP.AttachmentDefault = {
    {"1","saiga12_dustcover"},
    {"4","saiga12_stock"},
    {"8","saiga12_sight"}
}

function SWEP:InitWorldModelBodygroup() end

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["3"].slots,"ak_grip",Vector(0,-12.6,-1.35),Angle(0,0,0))
SWEP.MainAttachment.slots["3"].slots[0] = SWEP.MainAttachment.slots["3"].slots["ak_grip_wood"]
SWEP.MainAttachment.slots["3"].slots["ak_grip_wood"] = nil

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["5"].slots,"muzzle_12",Vector(0,-34.56,-0.06),Angle(0,-90,0),{bone = "weapon"})

local att = WepAtt("saiga12_dustcover",{
    printName = "DustCover",
    icon = "entities/eft_ak_attachments/saiga12/dc.png",
    bodygroupWM = {1,1},
})

local att = WepAtt("saiga12_handguard",{
    printName = "HandGuard",
    icon = "entities/eft_ak_attachments/saiga12/hg.png",
    bodygroupWM = {2,3},
})

local att = WepAtt("saiga12_handguard_usp340",{
    printName = "ИСП340",
    icon = "entities/eft_ak_attachments/saiga12/340.png",
    bodygroupWM = {2,2},
})

local att = WepAtt("saiga12_handguard_quad_rail",{
    printName = "Titan Quad Rail Handguard",
    icon = "entities/eft_ak_attachments/saiga12/chaos.png",
    bodygroupWM = {2,6},

    slots = {
        ["1"] = {
            name = "ForceGrip",
            slotPos = Vector(0,-24,-1),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"forcegrip",Vector(0,-23.5,-1.4),Angle(0,-90,0),{bone = "weapon"})


local att = WepAtt("saiga12_handguard_quad_rail_upper",{
    printName = "Titan Quad Rail Handguard Upper",
    icon = "entities/eft_ak_attachments/saiga12/chaostop.png",
    bodygroupWM = {5,3},

    slots = {
        ["1"] = {
            name = "Extend",
            slotPos = Vector(0,-20.5,1.5),
            slots = {
                [0] = {false},
                ["saiga12_dustcover_quad_rail"] = {"saiga12_dustcover_quad_rail"}
            }
        }
    }
})

local att = WepAtt("saiga12_dustcover_quad_rail",{
    printName = "DustCover Tutan Quad Rail",
    icon = "entities/eft_ak_attachments/saiga12/chaosback.png",
    bodygroupWM = {9,1},
    slots = {
        ["1"] = {
            name = "Scope",
            slotPos = Vector(0,-13,2),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"scope_mount",Vector(0,-15,1.9),Angle(0,0,0))

local att = WepAtt("saiga12_handguard_bravo18",{
    printName = "Bravo 18",
    icon = "entities/eft_ak_attachments/saiga12/bravo.png",
    bodygroupWM = {2,1},
    slots = {}
})

local att = WepAtt("saiga12_handguard_mtu002",{
    printName = "MTU 002",
    icon = "entities/eft_ak_attachments/saiga12/utg.png",
    bodygroupWM = {2,4},
})

local att = WepAtt("saiga12_handguard_mtu002s",{
    printName = "MTU 002 S",
    icon = "entities/eft_ak_attachments/saiga12/utgs.png",
    bodygroupWM = {2,5},
    slots = {}
})

local att = WepAtt("saiga12_stock",{
    printName = "COK-12",
    icon = "entities/eft_m870_attachments/325.png",
    bodygroupWM = {6,1},
})

local att = WepAtt("ak_stock_rpk",{
    printName = "РПК-16",
    model = "models/weapons/arc9/darsu_eft/mods/ak_stock_rpk_stock_tube.mdl",
    icon = "entities/eft_ak_attachments/rpk/tube.png",

    slots = {
        ["1"] = {
            slotPos = Vector(0,4,0),
            name = "Stock Tube",
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"ar15_stock_tube",Vector(-0.7,4,-0.7),Angle(0,-90,0))

local att = WepAtt("saiga12_sight",{
    printName = "SOK-12 Rear Sight",
    icon = "entities/eft_ak_attachments/saiga12/rs.png",
    bodygroupWM = {5,1},
})

local att = WepAtt("saiga12_sight_rail",{
    printName = "SOK-12 Rear Sight Rail",
    icon = "entities/eft_ak_attachments/saiga12/mount.png",
    bodygroupWM = {5,2},
})

local att = WepAtt("saiga12_muzzle",{
    printName = "Muzzle",
    icon = "entities/eft_ak_attachments/saiga12/mount.png",
    bodygroupWM = {3,1},
})