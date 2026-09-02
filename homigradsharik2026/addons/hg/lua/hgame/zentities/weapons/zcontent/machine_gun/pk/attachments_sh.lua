local SWEP = oop.Get("wep_pk")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {

    }
}

function SWEP:InitWorldModelBodygroup(wm,tag,typeDraw)
    wm:SetBodygroup(4,1)
    wm:SetBodygroup(8,1)
    wm:SetBodygroup(9,1)
    wm:SetBodygroup(10,1)
    wm:SetBodygroup(11,1)
end