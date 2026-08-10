local SWEP = oop.Get("wep_glock_17")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {
        ["0"] = {
            slotPos = Vector(0, -18.5, -1)
        },
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0, -25, 0.5),
            canFunc = function(self, path, key)
                if self.attachments["1"][2][1] and self.attachments["5"][2][1] and self.attachments["5"][2][1] == "glock_mount_silencer" then return false, "Mount Down" end
            end,
            slots = {
                [0] = { false },
            }
        },
        ["2"] = {
            name = "FS",
            slotPos = Vector(0, -24, 1),
            slots = {
                [0] = { false },
                ["glock_fs"] = { "glock_fs", ang = Angle(0, 90, 0), vec = Vector(0, -9.1, 0), bone = "mod_reciever" }
            }
        },
        ["3"] = {
            name = "RS",
            slotPos = Vector(0, -17.4, 1),
            slots = {
                [0] = { false },
                ["glock_rs"] = { "glock_rs", ang = Angle(0, 90, 0), vec = Vector(0, 4.18, 0.), bone = "mod_reciever" }
            }
        },
        ["4"] = {
            name = "Stock",
            slotPos = Vector(0, -16, -3),
            slots = {
                [0] = { false },
                ["glock_stock"] = { "glock_stock" }
            }
        },
        ["5"] = {
            name = "Mount Down",
            slotPos = Vector(0, -23.1, -0.7),
            slots = {
                [0] = { false },
                ["glock_mount_silencer"] = { "glock_mount_silencer" }
            }
        },
        ["6"] = {
            name = "Mount",
            slotPos = Vector(0, -20, 0),
            slots = {
                [0] = { false },
                ["glock_mount_shark"] = {"glock_mount_shark"},
                ["glock_mount_aimtech"] = {"glock_mount_aimtech"}
            }
        },
        ["7"] = {
            name = "Upper",
            canFunc = function(self, path, key)
                if self.attachments["7.1.1"] and self.attachments["7.1.1"][2][1] and self.attachments["6"][2][1] and self.attachments["6"][2][1] == "glock_mount_shark" then return false, "Mount Down" end
            end,
            slotPos = Vector(0, -21, 0.2),
            slots = {
                [0] = { "glock_upper_mount" }
            }
        }
    }
}

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["1"].slots, "muzzle_9", Vector(0, -24.33, 0.55), Angle(0, -90, 0),{ bone = "weapon" })

SWEP.AttachmentDefault = {
    {"2","glock_fs"},
    {"3","glock_rs"}
}

function SWEP:InitWorldModelBodygroup(wm)
    wm:SetBodygroup(2,5)
end

WepAtt("glock_rs",{
    printName = "RS",
    icon = "entities/eft_glock_attachments/rs.png",
    model = "models/weapons/arc9/darsu_eft/mods/glock_rs.mdl"
})

WepAtt("glock_fs",{
    printName = "FS",
    icon = "entities/eft_glock_attachments/fs.png",
    model = "models/weapons/arc9/darsu_eft/mods/glock_fs.mdl"
})

WepAtt("glock_stock",{
    printName = "Glock Stock FAD Defence",
    icon = "entities/eft_glock_attachments/stock.png",
    bodygroupWM = {5,1}
})

local att = WepAtt("glock_mount_silencer",{
    printName = "FD9217",
    icon = "entities/eft_glock_attachments/silencer.png",
    bodygroupWM = {9,1},

    Silencer = true,

    MuzzleFlashScale = false,
    MuzzleGasAround = false,
    MuzzleGasForwardScale = 3,

    slots = {
        ["1"] = {
            name = "Mount",
            slotPos = Vector(0,-23.1,-2),
            slots = {
                [0] = {false}
            }
        }
    },
    
    MuzzlePos = Vector(6.4,0,0)
})

attachmentGame.ManualCreate(att.slots["1"].slots,"forcegrip",Vector(0,-23,-2),Angle(0,-90,0),{bone = "weapon"})

local att = WepAtt("glock_mount_aimtech",{
    printName = "Mount AimTech",
    icon = "entities/eft_glock_attachments/atbase.png",
    bodygroupWM = {6,1},
    slots = {
        ["1"] = {
            name = "Scope",
            slotPos = Vector(0,-23,1.5),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"scope_mount",Vector(0,-21.74,1.57),Angle(0,0,0),{bone = "weapon"})

local att = WepAtt("glock_mount_shark",{
    printName = "Mount Tiger Shark",
    icon = "entities/eft_glock_attachments/tshark.png",
    bodygroupWM = {6,2},
    slots = {
        ["1"] = {
            name = "Scope",
            slotPos = Vector(0,-20,1.5),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"scope_mount",Vector(0,-20.23,1.37),Angle(0,0,0),{bone = "weapon"})

WepAtt("glock_upper_mount", {
    printName = "MOS",
    icon = "entities/eft_glock_attachments/slide_mos.png",
    bodygroupWM = { 1, 10 },
    slots = {
        ["1"] = {
            name = "Mount",
            slotPos = Vector(0,-18.3,0),
            slots = {
                [0] = {false},
                ["glock_mount_scope"] = {"glock_mount_scope"}
            }
        }
    }
})

local att = WepAtt("glock_mount_scope", {
    printName = "MOS",
    icon = "entities/eft_glock_attachments/slide_mos.png",
    bodygroupWM = { 7, 1 },
    slots = {
        ["1"] = {
            name = "Sight",
            slotPos = Vector(0, -18.3, 1.5),
            slots = {
                [0] = { false }
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots, "scope_mini", Vector(0, 1.05, 0.3), Angle(0, -90, 0),{bone = "mod_reciever"})
