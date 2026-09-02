local SWEP = oop.Get("wep_mp5")
if not SWEP then return end

SWEP.MainAttachment = {
    slots = {
        ["0"] = {slotPos = Vector(0,-12.5,-0.5)},
        ["1"] = {
            name = "Barrel",
            slotPos = Vector(0,-15.6,0),
            slots = {
                [0] = {"m5p_barrel"},
                ["mp5sd_barrel"] = {"mp5sd_barrel"}
            }
        },
        ["2"] = {
            name = "Stock",
            slotPos = Vector(0,-8,0),
            slots = {
                [0] = {"mp5_stock"},
                ["mp5_stock_a3"] = {"mp5_stock_a3"},
                ["mp5_stock_end_cap"] = {"mp5_stock_end_cap"}
            }
        },
        ["3"] = {
            name = "Mount",
            slotPos = Vector(0,-12.5,1),
            slots = {
                [0] = {false},
                ["mp5_mount_mfi_hk"] = {"mp5_mount_mfi_hk"},
                ["mp5_mount_tri_rail"] = {"mp5_mount_tri_rail"}
            }
        },
        ["4"] = {
            name = "RS",
            slotPos = Vector(0,-10,1.5),
            slots = {
                [0] = {false},
                ["mp5_rs"] = {"mp5_rs"}
            }
        }
    }
}

SWEP.AttachmentDefault = {
    {"1.2","mp5_muzzle"},
    {"4","mp5_rs"},
}

function SWEP:InitWorldModelBodygroup(wm,tag,typeDraw)
    wm:SetBodygroup(2,1)
end

WepAtt("m5p_barrel",{
    printName = "MP5",
    icon = "entities/eft_mp5_attachments/hk_mp5_9x19_upper_receiver.png",
    bodygroupWM = {1,1},
    slots = {
        ["1"] = {
            name = "Handguard",
            slotPos = Vector(0,-18,0),
            slots = {
                [0] = {"mp5_handguard"},
                ["mp5_handguard_mount_tl99"] = {"mp5_handguard_mount_tl99"},
                ["mp5_handguard_mount_hx5"] = {"mp5_handguard_mount_hx5"}
            }
        },
        ["2"] = {
            name = "Muzzle",
            slotPos = Vector(0,-23,0),
            slots = {
                [0] = {false},
                ["mp5_muzzle"] = {"mp5_muzzle"},
                ["mp5_muzzle_adapter"] = {"mp5_muzzle_adapter"}
            }
        }
    }
})

WepAtt("mp5_handguard",{
    printName = "Handguard",
    icon = "entities/eft_mp5_attachments/hk_mp5_wide_tropical_polymer_handguard.png",
    bodygroupWM = {3,1}
})

WepAtt("mp5sd_barrel",{
    printName = "MP5 Handguard",
    icon = "entities/eft_mp5_attachments/hk_mp5sd_9x19_upper_receiver.png",
    bodygroupWM = {1,2},
    slots = {
        ["1"] = {
            name = "Handguard",
            slotPos = Vector(0,-18,0),
            slots = {
                [0] = {"mp5sd_handguard"}
            }
        },
        ["2"] = {
            name = "Muzzle",
            slotPos = Vector(0,-23,0),
            slots = {
                [0] = {"mp5sd_silencer"}
            }
        }
    },

    PrimarySound = {
        outdoor_close_silence = sound.CreateFormatedList("weapons/eft/mp5/fire/mp5sd_outdoor_close_",1,4,".ogg"),
        outdoor_distant_silence = sound.CreateFormatedList("weapons/eft/mp5/fire/mp5sd_outdoor_distant_",1,2,".ogg"),
        indoor_close_silence = sound.CreateFormatedList("weapons/eft/mp5/fire/mp5_silence_indoor_close_",1,4,".ogg"),
        indoor_distant_silence = sound.CreateFormatedList("weapons/eft/mp5/fire/mp5_silence_indoor_distant_",1,2,".ogg")
    }
})

WepAtt("mp5sd_handguard",{
    printName = "Handguard",
    icon = "entities/eft_mp5_attachments/hk_mp5sd_polymer_handguard.png",
    bodygroupWM = {3,5}
})

WepAtt("mp5sd_silencer",{
    printName = "Silencer",
    icon = "entities/eft_mp5_attachments/hk_mp5sd_9x19_sound_suppressor.png",
    bodygroupWM = {8,3},

    Silencer = true,
    MuzzleFlashScale = false,
    MuzzleGasSide = false,
    MuzzleGasForward = 3
})

WepAtt("mp5_handguard_mount_tl99",{
    printName = "TL-99",
    icon = "entities/eft_mp5_attachments/hk_mp5_b&t_tl99_aluminum_handguard.png",
    bodygroupWM = {3,2}
})

WepAtt("mp5_handguard_mount_hx5",{
    printName = "HX5",
    icon = "entities/eft_mp5_attachments/hk_mp5_caa_hx5_handguard.png",
    bodygroupWM = {3,3}
})

WepAtt("mp5_stock",{
    printName = "MP5 Stock",
    icon = "entities/eft_mp5_attachments/hk_mp5_a2_stock.png",

    bodygroupWM = {5,1}
})

WepAtt("mp5_stock_a3",{
    printName = "MP5 Stock A3",
    icon = "entities/eft_mp5_attachments/hk_mp5_a3_old_model_stock.png",

    bodygroupWM = {5,3}
})

WepAtt("mp5_stock_end_cap",{
    printName = "MP5 End Cap",
    icon = "entities/eft_mp5_attachments/hk_mp5_end_cap_stock.png",

    bodygroupWM = {5,2}
})

local att = WepAtt("mp5_mount_mfi_hk",{
    printName = "MFI HK",
    icon = "entities/eft_mp5_attachments/hk_mp5_mfi_hk_universal_low_profile_scope_mount.png",

    bodygroupWM = {6,1},
    slots = {
        ["1"] = {
            name = "Scope",
            slotPos = Vector(0,-13.5,2),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"scope_mount",Vector(0,-12,1.5),Angle(0,0,0))

local att = WepAtt("mp5_mount_tri_rail",{
    printName = "Tri-Rail",
    icon = "entities/eft_mp5_attachments/hk_mp5_b&t_trirail_receiver_mount.png",

    bodygroupWM = {6,2},
    slots = {
        ["1"] = {
            name = "Scope",
            slotPos = Vector(0,-13.5,2),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"scope_mount",Vector(0,-12,1.5),Angle(0,0,0))

WepAtt("mp5_muzzle",{
    printName = "MP5 Muzzle",
    icon = "entities/eft_mp5_attachments/hk_mp5_3lug_thread_protector.png",
    bodygroupWM = {8,1}
})

local att = WepAtt("mp5_muzzle_adapter",{
    printName = "MP5 Muzzle Adapter",
    icon = "entities/eft_mp5_attachments/hk_mp5_navy_style_3lug_suppressor_adapter.png",
    bodygroupWM = {8,2},

    slots = {
        ["1"] = {
            name = "Muzzle",
            slotPos = Vector(0,-25,0),
            slots = {
                [0] = {false},
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"muzzle_9",Vector(0,-23.1,-0.25),Angle(0,-90,0),{bone = "weapon"})

WepAtt("mp5_rs",{
    printName = "RS",
    icon = "entities/eft_mp5_attachments/hk_mp5_drum_rear_sight.png",
    bodygroupWM = {4,1}
})