local SWEP = oop.Get("wep_m870")
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
            name = "Barrel",
            slotPos = Vector(0,-31,1.5),
            slots = {
                [0] = {"m870_barrel_325"},
                ["m870_barrel_355"] = {"m870_barrel_355"},
                ["m870_barrel_508"] = {"m870_barrel_508"},
                ["m870_barrel_660"] = {"m870_barrel_660"}
            }
        },
        ["2"] = {
            name = "Grip",
            slotPos = Vector(0,-13,-1),
            slots = {
                [0] = {"m870_grip"}
            }
        },
        ["3"] = {
            name = "Pump",
            slotPos = Vector(0,-26,0),
            slots = {
                [0] = {"m870_pomp_7"},
                ["m870_pomp_10"] = {"m870_pomp_10"},
                ["m870_pomp_15"] = {"m870_pomp_15"}
            }
        },
        ["4"] = {
            name = "PumpHand",
            slotPos = Vector(0,-30.5,0),
            slots = {
                [0] = {"m870_pomphand"},
                ["m870_pomphand_pm"] = {"m870_pomphand_pm"}
            }
        },
        ["5"] = {
            name = "Mount",
            slotPos = Vector(0,-20,1.75),
            slots = {
                [0] = {false},
                ["m870_mount1"] = {"m870_mount1"},
                ["m870_mount2"] = {"m870_mount2"}
            }
        }
    }
}

if CLIENT then
    texture_uv.RegUV("models/weapons/arc9/darsu_eft/m870/weapon_remington_model_870_12g_lod0","camo",util.JSONToTable('[{"transform":[0,0,0.5566084556544719,0.194920299135089],"uiHide":false,"uvScale":[0,0,0.7,0.3]},{"transform":[0.10833382883502889,0.1949188885834428,0.4491437665235865,0.11123531998151431],"uiHide":false,"uvScale":[0.21,0.29,1,0.6]},{"transform":[0,0.1949027400746313,0.10833382883502889,0.11021591605765352],"uvScale":[0,0.29,0.2,0.6]},{"transform":[0,0.41735631517372657,0.5408856168653207,0.10820551319108494],"rotate":180,"uiHide":false,"uvScale":[0,0.6,1,1]},{"transform":[0.5556662086361587,0.1551156711278542,0.18059151780675156,0.09286530310943902],"rotate":0,"uiHide":false,"uvScale":[0,0,0.3,0.3]},{"transform":[0.3787195601418529,0.9531011294503516,0.5277998759923134,0.034695330194124144],"rotate":180,"uiHide":false,"uvScale":[0,0.6,1,0.9]},{"transform":[0.806892776683364,0.52379540955089,0.09908167679041524,0.3327057479074145],"rotate":0,"uiHide":false,"uvScale":[0,0,0.3,1]},{"transform":[0.9658402138326542,0.42552005557524103,0.03426278802666175,0.322456444992269],"rotate":0,"uiHide":false,"uvScale":[0,0,0.1,1]},{"transform":[0,0.9186075666061708,0.3324933410043811,0.03571479603830172],"rotate":0,"uiHide":false,"uvScale":[0,0.8,1,1]},{"transform":[0,0.9684167876326566,0.36018958327734085,0.03163426808915949],"rotate":0,"uiHide":false,"uvScale":[0,0,1,0.1]},{"transform":[0.5556476106866869,0,0.207484551870687,0.1552034464027768],"rotate":0,"uvScale":[0.7,0,0.9,0.238]},{"transform":[0.7622067474882117,0,0.06112472094073144,0.1939170559275895],"rotate":0,"uvScale":[0.9,0,1,0.3]}]'))
    texture_uv.RegUV("models/weapons/arc9/darsu_eft/mods/barrel_870_express_rifle_sights_fixed_improved_cylinder_508mm_l","barrel",util.JSONToTable('[{"transform":[0.096417204726827,0,0.7611642959724931,0.506203097371762],"rotate":0,"uiHide":false,"uvScale":[0,0,1,0.2]},{"transform":[0,0.5238970588235294,0.5851851851851851,0.41564542483660133],"rotate":0,"uiHide":false,"uvScale":[0,0,1,0.2]}]'))
    texture_uv.RegUV("models/weapons/arc9/darsu_eft/mods/barrel_870_vent_rib_barrel_cut_off_325mm_lod0","barrel",'[{"transform":[0.10000000000000002,0.01327415187130116,0.8990740740740741,0.5279028090355923],"rotate":0,"uvScale":[0,0,1,0.4]}]')--bodygroup 1 5
end

SWEP.AttachmentDefault = {
    {"2.1.1","ar15_stock_moe_carbine"}
}

local att = WepAtt("m870_barrel_325",{
    printName = "325",
    icon = "entities/eft_m870_attachments/325.png",
    bodygroupWM = {1,5},
    MuzzlePos = Vector(12.4,0,0),

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,-36,1.5),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"muzzle_12",Vector(0,-35,1.47),Angle(0,-90,0),{bone = "weapon"})

local att = WepAtt("m870_barrel_355",{
    printName = "355",
    icon = "entities/eft_m870_attachments/355.png",
    bodygroupWM = {1,2},
    MuzzlePos = Vector(13.6,0,0),
})

local att = WepAtt("m870_barrel_508",{
    printName = "508",
    icon = "entities/eft_m870_attachments/508.png",
    bodygroupWM = {1,3},
    MuzzlePos = Vector(19,0,0),

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,-42.5,1.5),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"muzzle_12",Vector(0,-41.55,1.47),Angle(0,-90,0),{bone = "weapon"})

local att = WepAtt("m870_barrel_660",{
    printName = "660",
    icon = "entities/eft_m870_attachments/660.png",
    bodygroupWM = {1,4},
    MuzzlePos = Vector(24.7,0,0),

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,-48,1.5),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"muzzle_12",Vector(0,-47.4,1.47),Angle(0,-90,0),{bone = "weapon"})

WepAtt("m870_grip",{
    printName = "Grip",
    icon = "entities/eft_m870_attachments/agr.png",
    bodygroupWM = {3,1},
    slots = {
        ["1"] = {
            name = "Stock",--lol
            slotPos = Vector(0,-11,0.5),
            slots = {
                [0] = {"ar15_stock_tube",vec = Vector(0,-12.11,0.35),ang = Angle(-8,-90,0)}
            }
        }
    }
})

if CLIENT then texture_uv.RegUV("models/weapons/arc9/darsu_eft/m870/weapon_remington_model_870_12g_lod0","barreldown_1",util.JSONToTable('[{"transform":[0,0.30512297673582445,0.8047898921747031,0.10919326849131843],"rotate":0,"uvScale":[0,0,1,0.2]},{"transform":[0.00926077766101535,0.7215368526264295,0.39550766291381256,0.13062034093230665],"rotate":0,"uvScale":[0,0,1,0.24]}]')) end

WepAtt("m870_pomp_7",{
    printName = "Pomp 7",
    icon = "entities/eft_m870_attachments/7.png",
    bodygroupWM = {5,1},
    skin = {
        ["barreldown_1"] = 1
    }
})

WepAtt("m870_pomp_10",{
    printName = "Pomp 10",
    icon = "entities/eft_m870_attachments/10.png",
    bodygroupWM = {5,2}
})

WepAtt("m870_pomp_15",{
    printName = "Pomp 15",
    icon = "entities/eft_m870_attachments/xs.png",
    bodygroupWM = {5,3}
})

WepAtt("m870_pomphand",{
    printName = "MOE",
    icon = "entities/eft_m870_attachments/moe.png",
    bodygroupWM = {2,3}
})

local att = WepAtt("m870_pomphand_pm",{
    printName = "PM",
    icon = "entities/eft_m870_attachments/pr.png",
    bodygroupWM = {2,1},

    slots = {
        ["1"] = {
            name = "Force Grip",
            slotPos = Vector(0,-30.5,-1),
            slots = {[0] = {false}}
        },
        ["2"] = {
            name = "Left",
            slotPos = Vector(1.5,-32.5,0.4),
            slots = {[0] = {false}}
        },
        ["3"] = {
            name = "Right",
            slotPos = Vector(-1.5,-32.5,0.4),
            slots = {[0] = false}
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"forcegrip",Vector(0,0,-1.2),Angle(0,-90,0),{bone = "mod_handguard"})

local att = WepAtt("m870_mount1",{
    printName = "MTU 028SG",
    icon = "entities/eft_m3s90_attachments/rail.png",
    bodygroupWM = {7,2},
    slots = {
        ["1"] = {
            name = "Sight",
            slotPos = Vector(0,-20,3),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"scope_mount",Vector(0,-19.8,2.4),Angle(0,0,0))

local att = WepAtt("m870_mount2",{
    printName = "XS",
    icon = "entities/eft_m3s90_attachments/rail.png",
    bodygroupWM = {7,1},
    slots = {
        ["1"] = {
            name = "Sight",
            slotPos = Vector(0,-20,3),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"scope_mount",Vector(0,-19.8,2.4),Angle(0,0,0))
