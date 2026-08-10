local SWEP = oop.Get("wep_asval")
if not SWEP then return end

SWEP.AttachmentAngle = Angle(0,-90,0)

SWEP.MainAttachment = {
    slots = {
        ["0"] = {
            slotPos = Vector(0,-17.8,-1),
            skin = {
                ["camo"] = 1
            }
        },
        ["1"] = {
            name = "Handguard",
            slotPos = Vector(0,-21,0),
            slots = {
                [0] = {"val_handguard"},
            }
        },
        ["3"] = {
            name = "Grip",
            slotPos = Vector(0,-12.67,-2),
            slots = {
                [0] = {"val_grip"}
            }
        },
        ["4"] = {
            name = "DustCover",
            slotPos = Vector(0,-16,0),
            slots = {
                [0] = {false},
                ["val_dustcover"] = {"val_dustcover"}
            }
        },
        ["5"] = {
            name = "Stock",
            slotPos = Vector(0,-10,0),
            slots = {
                [0] = {false},
                ["val_stock"] = {"val_stock"}
            }
        },
        ["6"] = {
            name = "Sight",
            slotPos = Vector(0,-25,1.2),
            slots = {
                [0] = {false},
                ["val_sight"] = {"val_sight"}
            }
        },
        ["7"] = {
            name = "NMount",
            slotPos = Vector(0,-13.8,-0.2),
            slots = {
                [0] = {false}
            }
        },
        ["8"] = {
            name = "BarrelMount",
            slotPos = Vector(0,-26,0),
            slots = {
                [0] = {false},
                ["vss_mount_6p29m"] = {"vss_mount_6p29m"},
                ["vss_mount_b3"] = {"vss_mount_b3"},
                ["vss_mount_b3sparka"] = {"vss_mount_b3sparka"}
            }
        }
    }
}

SWEP.AttachmentDefault = {
    {"4","val_dustcover"},
    {"5","val_stock"},
    {"6","val_sight"}
}

function SWEP:InitWorldModelBodygroup(wm)
    wm:SetBodygroup(5,1)
end

WepAtt("val_handguard",{
    printName = "VAL HandGuard",
    icon = "entities/eft_val_attachments/hg.png",

    bodygroupWM = {8,1},

    cosmetic = {
        ["ak100"] = {
            printName = "VSS",
            icon = "entities/eft_val_attachments/hgb.png",
            bodygroupWM = {8,2},
        },
    }
})

WepAtt("val_grip",{
    printName = "VAL Grip",
    icon = "entities/eft_val_attachments/grip.png",

    bodygroupWM = {3,1}
})

WepAtt("val_stock",{
    printName = "VAL Grip",
    icon = "entities/eft_val_attachments/stock.png",

    bodygroupWM = {4,1}
})

WepAtt("val_dustcover",{
    printName = "VAL DustCover",
    icon = "entities/eft_val_attachments/dcval.png",

    bodygroupWM = {1,1}
})

WepAtt("val_sight",{
    printName = "VAL Sight",
    icon = "entities/eft_val_attachments/rs.png",

    bodygroupWM = {2,1}
})

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["7"].slots,"nmount",Vector(0,-12,2.2),Angle())

local att = WepAtt("vss_mount_6p29m",{
    printName = "Mount 6P29M",
    icon = "entities/eft_val_attachments/6p.png",

    bodygroupWM = {6,2},

    slots = {
        ["1"] = {
            name = "Force Grip",
            slotPos = Vector(0,-26,-1.5),
            slots = {
                [0] = {false}
            }
        }
    }
})
attachmentGame.ManualCreate(att.slots["1"].slots,"forcegrip",Vector(0,-26,-1.25),Angle(0,-90,01))

local att = WepAtt("vss_mount_b3",{
    printName = "Mount B3",
    icon = "entities/eft_val_attachments/b3.png",

    bodygroupWM = {6,1}
})

local att = WepAtt("vss_mount_b3sparka",{
    printName = "Mount B3Sparka",
    icon = "entities/eft_val_attachments/b3sparka.png",

    bodygroupWM = {6,3},
})
