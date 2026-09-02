local SWEP = oop.Get("wep_p90")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {
        ["0"] = {slotPos = Vector(0,-12.5,-0.5)},
        ["1"] = {
            name = "Upper",
            slotPos = Vector(0,-16,0),
            slots = {
                [0] = {"p90_upper"},
                ["p90_upper2"] = {"p90_upper2"}
            }
        },
        ["2"] = {
            name = "Barrel",
            slotPos = Vector(0,-18,0),
            slots = {
                [0] = {"p90_barrel"},
                ["p90_barrel2"] = {"p90_barrel2"}
            }
        },
        ["3"] = {
            name = "Stock",
            slotPos = Vector(0,0,0),
            slots = {
                [0] = {"p90_stock"}
            }
        }
    }
}

SWEP.AttachmentDefault = {}

function SWEP:InitWorldModelBodygroup(wm,tag,typeDraw)
    wm:SetBodygroup(1,1)
    wm:SetBodygroup(2,1)
    wm:SetBodygroup(5,1)
end

WepAtt("p90_upper",{
    printName = "P90 Upper",
    icon = "entities/eft_p90_attachments/top.png",
    bodygroupWM = {6,1},

    slots = {
        ["1"] = {
            name = "Scope",
            slotPos = Vector(0,-16,1.8),
            slots = {
                [0] = {false},
                ["p90_sight"] = {"p90_sight",ang = Angle(0,-90,0),vec = Vector(0,0,5)},
                ["p90_sight_mount"] = {"p90_sight_mount"},
            }
        }
    }
})

WepAtt("p90_sight",{
    printName = "Sight",
    icon = "entities/eft_p90_attachments/ringscope.png",
    model = "models/weapons/arc9/darsu_eft/c_p90.mdl",

    StencilScopeAlways = true,
    Holosight = true,
    
    ScopeHeight = 1.7,
    ScopeRight = 8,
    StartSightValue = 0,
    EndSightValue = 5,

    RetricleMaterial = Material("homigrad/scopes/reticles/new/scope_all_eotech_xps3-4_marks.png"),
    RetricleSize = 1,
    Cam3D2DSize = 0.0005,
})

local att = WepAtt("p90_sight_mount",{
    printName = "Sight Mount",
    icon = "entities/eft_p90_attachments/top_rail.png",
    bodygroupWM = {7,1},

    slots = {
        ["1"] = {
            name = "Scopes",
            slotPos = Vector(0,-18,2),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"scope_mount",Vector(0,-15.3,2.55),Angle(0,0,0))

local att = WepAtt("p90_upper2",{
    printName = "P90 Upper 2",
    icon = "entities/eft_p90_attachments/top_effen.png",
    bodygroupWM = {6,3},

    slots = {
        ["1"] = {
            name = "Scope",
            slotPos = Vector(0,-18,1),
            slots = {
                [0] = {false},
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"scope_mount",Vector(0,-12,1.5),Angle(0,0,0))

local att = WepAtt("p90_barrel",{
    printName = "P90 Barrel",
    icon = "entities/eft_p90_attachments/barrel.png",
    bodygroupWM = {3,1},

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,-19.5,-1.15),
            slots = {
                [0] = {false},
                ["p90_muzzle"] = {"p90_muzzle"}
            }
        }
    }
})

local att = WepAtt("p90_barrel2",{
    printName = "P90 Barrel",
    icon = "entities/eft_p90_attachments/barrel_long.png",
    bodygroupWM = {3,2}
})

WepAtt("p90_muzzle",{
    printName = "Muzzle",
    icon = "entities/eft_p90_attachments/muzzle.png",
    bodygroupWM = {8,1},

    slots = {
        ["1"] = {
            name = "Silencer",
            slotPos = Vector(0,-21.5,-1.15),
            slots = {
                [0] = {false},
                ["p90_silencer"] = {"p90_silencer"}
            }
        }
    }
})

WepAtt("p90_silencer",{
    printName = "Silencer",
    icon = "entities/eft_p90_attachments/silencer.png",
    bodygroupWM = {9,1},

    MuzzlePos = Vector(8.5,0,0),
    Silencer = true,

    MuzzleFlashScale = false,
    MuzzleGasAround = false,
    MuzzleGasForwardScale = 3
})

WepAtt("p90_stock",{
    printName = "Stock",
    icon = "entities/eft_p90_attachments/butt.png",
    bodygroupWM = {4,1}
})