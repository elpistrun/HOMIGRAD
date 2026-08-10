local SWEP = oop.Get("wep_ar15")
if not SWEP then return end

SWEP.AttachmentAngle = Angle(0,-90,0)

SWEP.MainAttachment = {
    slots = {
        ["0"] = {
            slotPos = Vector(0,-14.9,-1.5),
            skin = {
                ["camo"] = 1
            }
        },
        ["1"] = {
            name = "Barrel",
            slotPos = Vector(0,-21,0),
            slots = {
                [0] = {"ar15_barrel_348",vec = Vector(0,-16.65,-0.06),ang = Angle(0,-90,0)}
            }
        },
        ["2"] = {
            name = "Receiver",
            slotPos = Vector(0,-13,0),
            slots = {
                [0] = {"ar15_receiver",vec = Vector(0,-16.51,-0.95),ang = Angle(0,-90,0)}
            }
        },
        ["3"] = {
            name = "Stock",
            slotPos = Vector(0,-8,0),
            slots = {}
        },
        ["4"] = {
            name = "HandGuard",
            slotPos = Vector(0,-19,0),
            slots = {}
        },
        ["5"] = {
            name = "Grip",
            slotPos = Vector(0,-10,-3),
            slots = {}
        }
    }
}

SWEP.AttachmentDefault = {
    {"1.2","muzzle_556x45_colt"},
    {"2.2","ar15_carryhandle_m16"},
    {"3.1","ar15_stock_moe_carbine"}
}

if CLIENT then
    texture_uv.RegUV("models/weapons/arc9/darsu_eft/m4a1/weapon_colt_m4a1_556x45_lod0","camo",util.JSONToTable('[{"transform":[0,0,1.00013626908828,1.0000418703012253],"rotate":0,"uvScale":[0,0,1,1]}]'))
end

local att = WepAtt("ar15_barrel_348",{
    printName = "Hanson Carabine 348",
    icon = "entities/eft_ar15_attachments/barrel/ar15_556x45_18_inch_barrel.png",
    model = "models/weapons/arc9/darsu_eft/mods/barrel_ar15_ba_hanson_carbine_pro_348mm.mdl",

    MuzzlePos = Vector(14,0,0),
    slots = {
        ["1"] = {
            name = "GasBlock",
            slotPos = Vector(0,0,8.8),
            slots = {
                [0] = {"ar15_gasblock_colt",vec = Vector(8.41,0,-0.2)},
                ["ar15_gasblock_balopro"] = {"ar15_gasblock_balopro",vec = Vector(8.41,0,-0.2)}
            }
        },
        ["2"] = {
            name = "Muzzle",
            slotPos = Vector(0,0,15),
            slots = {
                [0] = {false},
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["2"].slots,"muzzle_556",Vector(13.79,0,0),Angle(0,0,0))

WepAtt("ar15_gasblock_colt",{
    printName = "GasBlock Colt",
    icon = "entities/eft_ar15_attachments/gas/m4a1_front_sight_with_gas_block.png",
    model = "models/weapons/arc9/darsu_eft/mods/gas_block_ar15_colt_m4_front_sight_gas_block_std.mdl",

    CameraPos = Vector(0,0,2.6)
})

WepAtt("ar15_gasblock_balopro",{
    printName = "Ba Lo Pro",
    icon = "entities/eft_ar15_attachments/gas/lopro.png",
    model = "models/weapons/arc9/darsu_eft/mods/gas_block_ar15_ba_lo_pro.mdl"
})

local att = WepAtt("ar15_receiver",{
    printName = "M4A1",
    icon = "entities/eft_ar15_attachments/rec/m4a1_556x45_upper_receiver.png",

    model = "models/weapons/arc9/darsu_eft/mods/reciever_ar15_colt_m4a1_std.mdl",
    slots = {
        ["1"] = {
            name = "Charge",
            slotPos = Vector(0,7,1.5),
            slots = {
                [0] = {"ar15_charge_colt",bone = "mod_charge",parentWM = true,ang = Angle(0,-90,0),vec = Vector(0,0.15,0)}
            }
        },
        ["2"] = {
            name = "Close",
            slotPos = Vector(0,3.5,3),
            slots = {
                [0] = {false},
                ["ar15_carryhandle_m16"] = {"ar15_carryhandle_m16",vec = Vector(-4.8,0,2.1)}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["2"].slots,"scope_mount",Vector(-3.1,0,2.15),Angle(0,90,0))

WepAtt("ar15_charge_colt",{
    printName = "Charge Colt",
    icon = "entities/eft_ar15_attachments/charge/ar15_colt_charging_handle.png",
    model = "models/weapons/arc9/darsu_eft/mods/charge_ar15_colt_charging_handle.mdl",

    cosmetic = {
        ["raptor"] = {
            printName = "Raptor",
            icon = "entities/eft_ar15_attachments/charge/ar15_radian_weapons_raptor_charging_handle_gray.png",
            model = "models/weapons/arc9/darsu_eft/mods/charge_ar15_radian_raptor_ambidextrous_charging_handle.mdl"
        },
        ["rainer"] = {
            printName = "Rainer",
            icon = "entities/eft_ar15_attachments/charge/ar15_rainier_arms_avalanche_mod2_charging_handle.png",
            model = "models/weapons/arc9/darsu_eft/mods/charge_ar15_rainer_arms_avalanche_mod2.mdl"
        },
        ["HK"] = {
            printName = "HK",
            icon = "entities/eft_ar15_attachments/charge/ar15_hk_extended_latch_charging_handle.png",
            model = "models/weapons/arc9/darsu_eft/mods/charge_ar15_hk_extended_latch_charging_handle.mdl"
        },
        ["tactical"] = {
            printName = "tactical",
            icon = "entities/eft_ar15_attachments/charge/ar15_badger_ordnance_tactical_charging_handle_latch.png",
            model = "models/weapons/arc9/darsu_eft/mods/charge_ar15_badger_ordnance_tactical_latch.mdl"
        },
        ["geissele"] = {
            printName = "Geissele",
            icon = "entities/eft_ar15_attachments/charge/ar15_geissele_ach_charging_handle.png",
            model = "models/weapons/arc9/darsu_eft/mods/charge_ar15_geissele_ach.mdl"
        },
        ["nrip"] = {
            printName = "nrip",
            icon = "entities/eft_ar15_attachments/charge/gnr.png",
            model = "models/weapons/arc9/darsu_eft/mods/charge_ar15_dd_grip_n_rip.mdl"
        }
    }
})

WepAtt("ar15_carryhandle_m16",{
    printName = "Carry Handle M16",
    
    icon = "entities/eft_attachments/ironsights/carry.png",
    model = "models/weapons/arc9_eft_shared/atts/ironsight/eft_rearsight_m4carry.mdl",

    CameraRecoil_Scope = 1,
    RecoilCameraMulScope = 0,

    ScopeHeight = 1.4,
    FOV = 70
})

--

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["3"].slots,"ar15_stock",Vector(0,-8.8,-0.06),Angle(0,-90,0))
SWEP.MainAttachment.slots["3"].slots[0] = SWEP.MainAttachment.slots["3"].slots["ar15_stock_tube"]
SWEP.MainAttachment.slots["3"].slots["ar15_stock_tube"] = nil

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["4"].slots,"ar15_handguard",Vector(0,-16.62,0.05),Angle(0,0,0))
SWEP.MainAttachment.slots["4"].slots[0] = SWEP.MainAttachment.slots["4"].slots["ar15_handguard_colt"]
SWEP.MainAttachment.slots["4"].slots["ar15_handguard_colt"] = nil

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["5"].slots,"ar15_grip",Vector(0,-11.25,-2.04),Angle(0,-90,0))
SWEP.MainAttachment.slots["5"].slots[0] = SWEP.MainAttachment.slots["5"].slots["ar15_grip_colt"]
SWEP.MainAttachment.slots["5"].slots["ar15_grip_colt"] = nil