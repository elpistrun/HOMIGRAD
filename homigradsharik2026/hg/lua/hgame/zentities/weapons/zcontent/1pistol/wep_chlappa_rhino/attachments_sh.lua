local SWEP = oop.Get("wep_chiappa_rhino")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {
        ["0"] = {
            slotPos = Vector(0,-20,0)
        },
        ["1"] = {
            name = "RS",
            slotPos = Vector(0,-18,2),
            slots = {
                [0] = {false},
                ["chiappa_rhino_rs"] = {"chiappa_rhino_rs",vec = Vector(-0.077,-19.37,1.9),ang = Angle(0,-90,0)}
            }
        },
        ["2"] = {
            name = "FS",
            slotPos = Vector(0,-26.5,2),
            slots = {
                [0] = {false},
                ["chiappa_rhino_fs"] = {"chiappa_rhino_fs",vec = Vector(-0.077,-26.55,1.85),ang = Angle(0,-90,0)}
            }
        },
        ["3"] = {
            name = "Mount",
            slotPos = Vector(0,-24.2,2),
            slots = {
                [0] = {false}
            }
        },
        ["4"] = {
            name = "Tactical Down",
            slotPos = Vector(0,-26,-1),
            slots = {
                [0] = {false}
            }
        }
    }
}

SWEP.AttachmentDefault = {
    {"1","chiappa_rhino_rs"},
    {"2","chiappa_rhino_fs"},
}

function SWEP:InitWorldModelBodygroup(wm)
    wm:SetBodygroup(0,1)
    wm:SetBodygroup(1,3)
    wm:SetBodygroup(2,1)
    wm:SetBodygroup(4,2)
end

WepAtt("chiappa_rhino_rs",{
    printName = "RS",
    model = "models/weapons/arc9/darsu_eft/mods/rhino_rs.mdl",
    icon = "entities/eft_rhino_attachments/chiappa_rhino_rear_sight.png"
})

WepAtt("chiappa_rhino_fs",{
    printName = "FS",
    model = "models/weapons/arc9/darsu_eft/mods/rhino_fs.mdl",
    icon = "entities/eft_rhino_attachments/chiappa_rhino_front_sight.png"
})

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["3"].slots,"scope_mount",Vector(0,-24.1,1.5),Angle(0,0,0),{bone = "weapon"})
attachmentGame.ManualCreate(SWEP.MainAttachment.slots["4"].slots,"forcegrip",Vector(0,-26.1,-0.3),Angle(0,-90,0),{bone = "weapon"})
