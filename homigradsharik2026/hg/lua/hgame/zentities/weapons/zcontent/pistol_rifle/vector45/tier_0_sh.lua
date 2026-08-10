local SWEP = oop.Reg("wep_vector45","wep_vector9",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "VECTOR45"
SWEP.IconOverride = "entities/arc9_eft_vector45.png"

SWEP.Primary.Sound = {
    outdoor_close = sound.CreateFormatedList("weapons/eft/vector/fire/vector45_outdoor_close_",1,4,".ogg"),
    outdoor_distant = sound.CreateFormatedList("weapons/eft/vector/fire/vector45_outdoor_distant_",1,2,".ogg"),
    indoor_close = sound.CreateFormatedList("weapons/eft/vector/fire/vector45_indoor_close_",1,4,".ogg"),
    indoor_distant = sound.CreateFormatedList("weapons/eft/vector/fire/vector45_indoor_distant_",1,2,".ogg"),

    outdoor_close_silence = sound.CreateFormatedList("weapons/eft/vector/fire/vector9_silence_outdoor_close_",1,4,".ogg"),
    outdoor_distant_silence = sound.CreateFormatedList("weapons/eft/vector/fire/vector9_silence_outdoor_distant_",1,2,".ogg"),
    indoor_close_silence = sound.CreateFormatedList("weapons/eft/vector/fire/vector45_silence_indoor_close_",1,4,".ogg"),
    indoor_distant_silence = sound.CreateFormatedList("weapons/eft/vector/fire/vector45_silence_indoor_distant_",1,2,".ogg")
}

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_vector_45.mdl",
    vec = Vector(13,-3,-4),
    ang = Angle(-3,0,0),
    chamberBodygroup = 5
})

SWEP:TableLink("wmFastData",{
    model = "models/weapons/arc9/darsu_eft/c_vector_45.mdl",
    vec = Vector(13,0,-5),
    ang = Angle(5,0,180)
})

SWEP.MainAttachment.slots["1"] = {
    name = "Barrel",
    slotPos = Vector(0,-20,0.5),
    slots = {
        [0] = {"vector45_barrel"},
        ["vector45_barrel2"] = {"vector45_barrel2"}
    }
}

local att = WepAtt("vector45_barrel",{
    name = "Barrel",
    icon = "entities/eft_vector_attachments/95.png",
    bodygroupWM = {1,1},

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,-25,-0.75),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"muzzle_45",Vector(0,-23.9,-0.75),Angle(0,-90,0),{bone = "weapon"})

local att = WepAtt("vector45_barrel2",{
    name = "Barrel",
    icon = "entities/eft_vector_attachments/95.png",
    bodygroupWM = {1,1},

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,-25,-0.75),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"muzzle_45",Vector(0,-23.9,-0.75),Angle(0,-90,0),{bone = "weapon"})