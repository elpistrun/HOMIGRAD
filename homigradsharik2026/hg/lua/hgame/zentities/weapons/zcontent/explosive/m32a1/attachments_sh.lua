local SWEP = oop.Get("wep_m32a1")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {
        ["0"] = {slotPos = Vector(0,-16,-2)},
        ["1"] = {
            name = "Grip",
            slotPos = Vector(0,-10,-3),
            slots = {
                [0] = {false}
            }
        },
        ["2"] = {
            name = "Scope",
            slotPos = Vector(0,-16.7,2.),
            slots = {
                [0] = {false}
            }
        },
        ["3"] = {
            name = "Stock",
            slotPos = Vector(0,-8,0.3),
            slots = {
                [0] = {false}
            }
        },
        ["4"] = {
            name = "Grip Force",
            slotPos = Vector(0,-24,-2),
            slots = {
                [0] = {false}
            }
        }
    }
}

SWEP.AttachmentDefault = {
    {"2","kalimator_walther_mrs"},
    {"3","ar15_stock_moe_carbine"},
    {"4","forcegrip_kac"}
}

function SWEP:InitWorldModelBodygroup(wm,tag,typeDraw)
    wm:SetBodygroup(1,1)
end

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["3"].slots,"ar15_stock_tube",Vector(-0.2,-6,-0.6),Angle(0,-90,0))
attachmentGame.ManualCreate(SWEP.MainAttachment.slots["1"].slots,"ar15_grip",Vector(-0.2,-10.86,-2.3),Angle(0,-90,0))
SWEP.MainAttachment.slots["1"].slots[0] = SWEP.MainAttachment.slots["1"].slots["ar15_grip_colt"]
SWEP.MainAttachment.slots["1"].slots["ar15_grip_colt"] = nil

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["4"].slots,"forcegrip",Vector(-0.2,-25,-2.15),Angle(0,-90,0))
attachmentGame.ManualCreate(SWEP.MainAttachment.slots["2"].slots,"scope_mount",Vector(-0.2,-16,1.95),Angle(0,0,0))