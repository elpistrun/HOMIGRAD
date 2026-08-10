local SWEP = oop.Get("wep_mr43")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {
        ["0"] = {
            slotPos = Vector(0,-18,1)
        }
    }
}

SWEP.AttachmentDefault = {}

function SWEP:InitWorldModelBodygroup(wm)
    wm:SetBodygroup(3,1)
end