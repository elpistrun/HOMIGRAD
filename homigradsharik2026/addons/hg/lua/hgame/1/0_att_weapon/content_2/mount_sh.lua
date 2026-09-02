local att = WepAtt("mount_keymod_tactical",{
    printName = "CASV KeyMod - Tactical",
    icon = "entities/eft_attachments/mount/casvkm4.png",
    model = "models/weapons/arc9_eft_shared/atts/mounts/keymod.mdl",
    bodygroups = {[0] = 3},

    slots = {
        ["1"] = {
            name = "Tactical",
            slotPos = Vector(0,0.4,0),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"flashlight",Vector(1.35,0.35,0),Angle(0,0,-90))

local att = WepAtt("mount_keymod_forcegrip",{
    printName = "CASV KeyMod - Force Grip",
    icon = "entities/eft_attachments/mount/casvkm4.png",
    model = "models/weapons/arc9_eft_shared/atts/mounts/keymod.mdl",
    bodygroups = {[1] = 3},

    slots = {
        ["1"] = {
            name = "Force Grip",
            slotPos = Vector(0,0.4,0),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"forcegrip",Vector(0,0.32,0),Angle(0,0,90))

local att = WepAtt("mount_mlok_tactical",{
    printName = "MLok - Tactical",
    icon = "entities/eft_attachments/mount/mlok25.png",
    model = "models/weapons/arc9_eft_shared/atts/mounts/mlok.mdl",
    bodygroups = {[0] = 0},

    slots = {
        ["1"] = {
            name = "Tactical",
            slotPos = Vector(0,0.4,0),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"flashlight",Vector(1,0.35,0),Angle(0,0,-90))

local att = WepAtt("mount_mlok_forcegrip",{
    printName = "MLok - ForceGrip",
    icon = "entities/eft_attachments/mount/mlok41.png",
    model = "models/weapons/arc9_eft_shared/atts/mounts/mlok.mdl",
    bodygroups = {[0] = 1},

    slots = {
        ["1"] = {
            name = "ForceGrip",
            slotPos = Vector(0,0.4,0),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"forcegrip",Vector(0,0.35,0),Angle(0,0,90))

local att = WepAtt("mount_rm33",{
    printName = "RM33",
    icon = "entities/eft_attachments/scopes/rm33.png",
    model = "models/weapons/arc9/darsu_eft/mods/mount_all_trijicon_rm33.mdl",

    slots = {
        ["1"] = {
            name = "Sight",
            slotPos = Vector(0,0,1),
            slots = {
                [0] = {false},
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"scope_mini",Vector(0,0,0.19),Angle(0,0,0))

local att = WepAtt("mount_um3",{
    printName = "UM3",
    icon = "entities/eft_attachments/tactical/um3.png",
    model = "models/weapons/arc9/darsu_eft/mods/tac_pistol_um3.mdl",

    slots = {
        ["1"] = {
            name = "Tactical Down",
            slots = {
                [0] = {false}
            }
        },
        ["2"] = {
            name = "Scope",
            slots = {
                [0] = {false}
            }
        }
    }
})