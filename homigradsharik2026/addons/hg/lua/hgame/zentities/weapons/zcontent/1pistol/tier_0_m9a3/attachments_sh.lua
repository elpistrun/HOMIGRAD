local SWEP = oop.Get("wep_m9a3")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {
        ["0"] = {slotPos = Vector(0,-20,0)},
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,-26,1),
            slots = {
                [0] = {false},
                ["m9a3_muzzle"] = {"m9a3_muzzle"}
            }
        },
        ["2"] = {
            name = "RS",
            slotPos = Vector(0,-18,1),
            slots = {
                [0] = {false},
                ["m9a3_rs"] = {"m9a3_rs"},
                ["m9a3_mount"] = {"m9a3_mount"}
            }
        },
        ["3"] = {
            name = "FS",
            slotPos = Vector(0,-24.5,1),
            slots = {
                [0] = {false},
                ["m9a3_fs"] = {"m9a3_fs"}
            }
        },
        ["4"] = {
            name = "Tactical Down",
            slotPos = Vector(0,-23.3,-0.5),
            slots = {
                [0] = {false},
                ["mount_um3"] = {"mount_um3",vec = Vector(0,-23.4,-0.28),ang = Angle(0,-90,180)}
            }
        }
    }
}

SWEP.AttachmentDefault = {
    {"1","m9a3_muzzle"},
    {"2","m9a3_rs"},
    {"3","m9a3_fs"}
}

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["1"].slots,"muzzle_9",Vector(0,-24.9,1),Angle(0,-90,0),{bone = "weapon"})
attachmentGame.ManualCreate(SWEP.MainAttachment.slots["4"].slots,"flashlight",Vector(0,-24.2,-0.3),Angle(0,-90,180))

function SWEP:InitWorldModelBodygroup(wm,tag,typeDraw)
    wm:SetBodygroup(1,1)
    wm:SetBodygroup(2,1)
    wm:SetBodygroup(4,1)
end

WepAtt("m9a3_muzzle",{
    printName = "Cap",
    icon = "entities/eft_m9a3_attachments/c.png",

    bodygroupWM = {3,1}
})

WepAtt("m9a3_rs",{
    printName = "RS",
    icon = "entities/eft_m9a3_attachments/rs.png",
    bodygroupWM = {5,1}
})

WepAtt("m9a3_fs",{
    printName = "FS",
    icon = "entities/eft_m9a3_attachments/fs.png",
    bodygroupWM = {6,1}
})

local att = WepAtt("m9a3_mount",{
    printName = "RMS",
    icon = "entities/eft_m9a3_attachments/rsm.png",
    bodygroupWM = {5,2},
    
    slots = {
        ["1"] = {
            name = "Sight",
            slotPos = Vector(0,-19,1),
            slots = {
                [0] = {false},
                ["mount_rm33"] = {"mount_rm33",vec = Vector(0,0.5,1),ang = Angle(0,-90,0),bone = "mod_reciever"}
            }
        }
    }
})