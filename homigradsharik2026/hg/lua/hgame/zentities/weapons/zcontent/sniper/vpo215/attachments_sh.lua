local SWEP = oop.Get("wep_vpo215")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {
        ["0"] = {slotPos = Vector(0,-18,0)},
        ["1"] = {
            name = "Mount",
            slotPos = Vector(0,-18,1),
            slots = {
                [0] = {false},
                ["vpo215_mount"] = {"vpo215_mount"}
            }
        }
    }
}

function SWEP:InitWorldModelBodygroup(wm,tag,typeDraw)
    wm:SetBodygroup(1,1)
    wm:SetBodygroup(2,1)
end

SWEP.AttachmentDefault = {

}

local att = WepAtt("vpo215_mount",{
    printName = "Mount 215 Rail",
    icon = "entities/eft_vpo215_attachments/vpo215_scope_rail_mount.png",
    
    bodygroupWM = {3,1},
    slots = {
        ["1"] = {
            name = "Scopes",
            slotPos = Vector(0,-18,3),
            slots = {
                [0] = {false},
            }
        },
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"scope_mount",Vector(0,-17.6,1.75),Angle(0,0,0))