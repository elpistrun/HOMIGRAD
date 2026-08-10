local SWEP = oop.Get("wep_m60")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {
        ["0"] = {slotPos = Vector(0,-10,0)},
        ["1"] = {
            name = "Sight",
            slotPos = Vector(0,-10,3),
            slots = {
                [0] = {false},
            }
        },
        ["2"] = {
            name = "Handguard",
            slotPos = Vector(0,-20,0),
            slots = {
                [0] = {"m60_handguard_e6"},
                ["m60_handguard_e4"] = {"m60_handguard_e4"}
            }
        },
        ["3"] = {
            name = "Grip",
            slotPos = Vector(0,-12,-4),
            slots = {
                [0] = {"m60_grip_e6"},
                ["m60_grip_e4"] = {"m60_grip_e4"},
            }
        },
        ["4"] = {
            name = "Stock",
            slotPos = Vector(0,0,0),
            slots = {
                [0] = {"m60_stock_e6"},
                ["m60_stock_e4"] = {"m60_stock_e4"}
            }
        },
        ["5"] = {
            name = "RS",
            slotPos = Vector(0,-16.5,2),
            slots = {
                [0] = {false},
                ["m60_rs"] = {"m60_rs"}
            }
        },
        ["6"] = {
            name = "FS",
            slotPos = Vector(0,-32.5,0),
            slots = {
                [0] = {false},
                ["m60_fs"] = {"m60_fs",vec = Vector(0,-32.4,-0.3),ang = Angle(0,-90,0)}
            }
        },
        ["7"] = {
            name = "Muzzle",
            slotPos = Vector(0,-37,-0.3),
            slots = {
                [0] = {false},
                ["muzzle_762x51_m60_e3"] = {"muzzle_762x51_m60_e3",vec = Vector(0,-35.3,-0.34),ang = Angle(0,-90,0)},
                ["muzzle_762x51_m60_e6"] = {"muzzle_762x51_m60_e6",vec = Vector(0,-35.3,-0.34),ang = Angle(0,-90,0)},
                ["muzzle_dt_hybrid_46"] = {"muzzle_dt_hybrid_46",vec = Vector(0,-35.3,-0.34),ang = Angle(0,-90,0)}
            }
        },
    }
}

SWEP.AttachmentDefault = {
    {"7","muzzle_762x51_m60_e3"},
    {"5","m60_rs"},
    {"6","m60_fs"}
}

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["1"].slots,"scope_mount",Vector(0,5,1),Angle(),{bone = "mod_dustcover"})

function SWEP:InitWorldModelBodygroup(wm,tag,typeDraw)
    wm:SetBodygroup(1,1)
    wm:SetBodygroup(4,2)
    wm:SetBodygroup(7,1)
end

WepAtt("m60_handguard_e6",{
    printName = "Handguard E6",
    icon = "entities/eft_m60_attachments/m60e4_mod_1_handguard.png",
    bodygroupWM = {6,3}
})

WepAtt("m60_handguard_e4",{
    printName = "E4 Mod 1",
    icon = "entities/eft_m60_attachments/m60e6_handguard.png",
    bodygroupWM = {6,1}
})

WepAtt("m60_grip_e4",{
    printName = "Grip E4",
    icon = "entities/eft_m60_attachments/m60e4_pistol_grip.png",
    bodygroupWM = {8,1}
})

WepAtt("m60_grip_e6",{
    printName = "Grip E4",
    icon = "entities/eft_m60_attachments/m60e6_pistol_grip.png",
    bodygroupWM = {8,2}
})

WepAtt("m60_stock_e4",{
    printName = "Stock E4",
    icon = "entities/eft_m60_attachments/m60e4_buttstock.png",
    bodygroupWM = {10,1}
})

WepAtt("m60_stock_e6",{
    printName = "Stock E6",
    icon = "entities/eft_m60_attachments/m60e6_buttstock.png",
    bodygroupWM = {10,2}
})

WepAtt("m60_rs",{
    printName = "RS",
    icon = "entities/eft_m60_attachments/m60_rear_sight.png",
    bodygroupWM = {9,1}
})

WepAtt("m60_fs",{
    printName = "FS",
    icon = "entities/eft_m60_attachments/m60e4_front_sight.png",
    model = "models/weapons/arc9/darsu_eft/mods/sight_front_m60_usord_m60e4.mdl",
    
    ScopeHeight = 3.3,
    ScopeRight = 0.075,
    FOV = 60
})

WepAtt("muzzle_762x51_m60_e3",{
    printName = "Muzzle 762x51 M60 E3",
    icon = "entities/eft_m60_attachments/m60e3_762x51_flash_hider.png",
    model = "models/weapons/arc9/darsu_eft/mods/muzzle_m60_usord_e3.mdl",
    MuzzlePos = Vector(1.7,0,0),
})

WepAtt("muzzle_762x51_m60_e6",{
    printName = "Muzzle 762x51 M60 E6",
    icon = "entities/eft_m60_attachments/m60e6_762x51_flash_hider.png",
    model = "models/weapons/arc9/darsu_eft/mods/muzzle_m60_usord_e6.mdl",
    MuzzlePos = Vector(2.1,0,0),
})