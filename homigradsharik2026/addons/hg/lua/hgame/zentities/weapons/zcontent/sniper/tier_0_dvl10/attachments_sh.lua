local SWEP = oop.Get("wep_dvl10")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {
        ["0"] = {slotPos = Vector(0,-18,-2)},
        ["1"] = {
            name = "Barrel",
            slotPos = Vector(0,-23,0),
            slots = {
                [0] = {"dvl10_barrel_660"},
                ["1"] = {"dvl10_barrel_500"}
            }
        },
        ["2"] = {
            name = "Stock",
            slotPos = Vector(0,-12,-1),
            slots = {
                [0] = {"dvl10_stock"}
            }
        },
        ["3"] = {
            name = "Scopes",
            slotPos = Vector(0,-19,2),
            slots = {
                [0] = {false}
            }
        },
        ["4"] = {
            name = "Grip",
            slotPos = Vector(0,-13,-3),
            slots = {
                [0] = {false}
            }
        }
    }
}

SWEP.AttachmentDefault = {
    {"1.1","dvl10_muzzle"},
    {"3","mount_optic_30mm_burris_pepr"},
    {"3.1","optic_nightforce_atacr"}
}

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["3"].slots,"scope_mount",Vector(0,-19,1.56),Angle(0,0,0))
attachmentGame.ManualCreate(SWEP.MainAttachment.slots["4"].slots,"ar15_grip",Vector(0,-14.48,-2.35),Angle(0,-90,0))
SWEP.MainAttachment.slots["4"].slots[0] = SWEP.MainAttachment.slots["4"].slots["ar15_grip_colt"]
SWEP.MainAttachment.slots["4"].slots["ar15_grip_colt"] = nil

WepAtt("dvl10_barrel_660",{
    printName = "660",
    icon = "entities/eft_dvl10_attachments/660.png",
    
    bodygroupWM = {1,1},
    MuzzlePos = Vector(26,0,0),
    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,-51,0),
            slots = {
                [0] = {false},
                ["dvl10_muzzle"] = {"dvl10_muzzle"}
            }
        },
        ["2"] = {
            name = "Handguard",
            slotPos = Vector(0,-25,0),
            slots = {
                [0] = {"dvl10_handguard"}
            }
        }
    }
})

WepAtt("dvl10_barrel_500",{
    printName = "500",
    icon = "entities/eft_dvl10_attachments/500.png",
    
    bodygroupWM = {1,2},
    MuzzlePos = Vector(26,0,0),

    Silencer = true,

    MuzzleFlashScale = false,
    MuzzleGasAround = false,
    MuzzleGasForwardScale = 3
})

WepAtt("dvl10_handguard",{
    printName = "Handguard",
    icon = "entities/eft_dvl10_attachments/hg.png",
    bodygroupWM = {3,1}
})

WepAtt("dvl10_muzzle",{
    printName = "Muzzle",
    icon = "entities/eft_dvl10_attachments/mz.png",
    bodygroupWM = {4,1},
    MuzzlePos = Vector(1.8,0,0)
})

WepAtt("dvl10_stock",{
    printName = "Stock",
    icon = "entities/eft_dvl10_attachments/s.png",
    bodygroupWM = {2,1}
})
