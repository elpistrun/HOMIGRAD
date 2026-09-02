local SWEP = oop.Get("wep_vss")
if not SWEP then return end

SWEP.MainAttachment.slots["3"] = nil
SWEP.MainAttachment.slots["5"] = {
    name = "Stock",
    slotPos = Vector(0,-10,0),
    slots = {
        [0] = {"vss_stock"}
    }
}

WepAtt("vss_stock",{
    printName = "VSS Stock",
    icon = "entities/eft_val_attachments/wood.png",

    bodygroupWM = {4,2}
})

