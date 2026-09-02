local SWEP = oop.Get("wep_mp9")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {
        ["0"] = {slotPos = Vector(0,-12.5,-0.5)},
        ["1"] = {
            name = "Upper",
            slotPos = Vector(0,-15,0),
            slots = {
                [0] = {"mp9_upper"}
            }
        },
        ["2"] = {
            name = "Stock",
            slotPos = Vector(0,-10,0),
            slots = {
                [0] = {false},
                ["mp9_stock"] = {"mp9_stock"}
            }
        },
        ["3"] = {
            name = "Mount Right",
            slotPos = Vector(-1,-18,0),
            slots = {
                [0] = {false},
                ["mp9_mount_right"] = {"mp9_mount_right"}
            }
        },
        ["4"] = {
            name = "Mount Down",
            slotPos = Vector(0,-18.5,-1),
            slots = {
                [0] = {false},
                ["mp9_mount_down"] = {"mp9_mount_down"}
            }
        },
        ["5"] = {
            name = "Muzzle",
            slotPos = Vector(0,-20,0.4),
            slots = {
                [0] = {false},
                ["mp9_muzzle"] = {"mp9_muzzle"}
            }
        },
        ["6"] = {
            name = "FS",
            slotPos = Vector(0,-17.6,2),
            slots = {
                [0] = {false}
            }
        },
        ["7"] = {
            name = "RS",
            slotPos = Vector(0,-10,2),
            slots = {
                [0] = {false},
                ["mp9_rs"] = {"mp9_rs"}
            }
        },
        ["8"] = {
            name = "Scope",
            slotPos = Vector(0,-12.43,2),
            slots = {
                [0] = {false}
            }
        },
    }
}

SWEP.AttachmentDefault = {
    {"2","mp9_stock"},
    {"7","mp9_rs"}
}

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["8"].slots,"scope_mount",Vector(0,-13.7,1.5),Angle(0,0,0))

function SWEP:InitWorldModelBodygroup(wm,tag,typeDraw)
    wm:SetBodygroup(1,0)
    wm:SetBodygroup(3,1)
end

WepAtt("mp9_upper",{
    icon = "entities/eft_mp9_attachments/rn.png",
    bodygroupWM = {2,1}
})

WepAtt("mp9_stock",{
    icon = "entities/eft_mp9_attachments/st.png",
    bodygroupWM = {10,1}
})

WepAtt("mp9_mount_right",{
    icon = "entities/eft_mp9_attachments/side.png",
    bodygroupWM = {5,1}
})

local att = WepAtt("mp9_mount_down",{
    icon = "entities/eft_mp9_attachments/b.png",

    bodygroupWM = {8,1},

    slots = {
        ["1"] = {
            name = "Tactical",
            slotPos = Vector(0,-19,-2),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"forcegrip",Vector(0,-19,-1.35),Angle(0,-90,0))

local att = WepAtt("mp9_muzzle",{
    icon = "entities/eft_mp9_attachments/sm.png",
    bodygroupWM = {6,1},

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,-22,0),
            slots = {
                [0] = {false},
                ["mp9_silencer"] = {"mp9_silencer"}
            }
        },
        ["2"] = {
            name = "Tactical",
            slotPos = Vector(0,-21.7,-1.3),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["2"].slots,"forcegrip",Vector(0,-21.9,-1),Angle(0,-90,0))

WepAtt("mp9_silencer",{
    icon = "entities/eft_mp9_attachments/s.png",
    bodygroupWM = {7,1},

    Silencer = true,

    MuzzleFlashScale = false,
    MuzzleGasAround = false,
    MuzzleGasForwardScale = 3
})

WepAtt("mp9_rs",{
    icon = "entities/eft_mp9_attachments/rs.png",
    bodygroupWM = {4,1},
})