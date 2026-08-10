local SWEP = oop.Get("wep_rsh12")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {
        ["1"] = {
            name = "Scope",
            slotPos = Vector(0,-26,3),
            slots = {
                [0] = {false}
            }
        },
        ["2"] = {
            name = "Tactical Downb",
            slotPos = Vector(0,-28,0),
            slots = {
                [0] = {false}
            }
        }
    }
}

SWEP.AttachmentDefault = {}

function SWEP:InitWorldModelBodygroup(wm)
    wm:SetBodygroup(1,1)
    wm:SetBodygroup(2,1)
end

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["1"].slots, "scope_mount", Vector(0, -26.5, 2.65), Angle(0, 0, 0),{bone = "weapon"})
attachmentGame.ManualCreate(SWEP.MainAttachment.slots["2"].slots, "forcegrip", Vector(0, -28, 0.1), Angle(0, -90, 0),{bone = "weapon"})