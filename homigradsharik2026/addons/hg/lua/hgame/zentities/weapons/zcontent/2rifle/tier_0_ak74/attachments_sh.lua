local SWEP = oop.Get("wep_ak74")
if not SWEP then return end

SWEP.AttachmentAngle = Angle(0,0,0)

SWEP.MainAttachment = {
    slots = {
        ["0"] = {
            slotPos = Vector(0,-18,0),
            skin = {
                ["camo"] = 0
            }
        },
        ["1"] = {
            name = "Stock",
            slotPos = Vector(0,-9,-0.5),
            slots = {
                [0] = {false}
            }
        },
        ["2"] = {
            name = "Gas",
            slotPos = Vector(0,-24,1.2),
            slots = {
                [0] = {"ak74_gasblock_std",vec = Vector(0,-21.35,1)}
            }
        },
        ["4"] = {
            name = "Grip",
            slotPos = Vector(0,-11.5,-1.75),
            slots = {}
        },
        ["5"] = {
            name = "DustCover",
            slotPos = Vector(0,-15,1.5),
            canFunc = function(self,path,key)
                if self.attachments["5"][2][1] and self.attachments["5"][2][1] != "ak74_dustcover" and self.attachments["6"][2][1] and self.attachments["6"][2][1] != "ak74_rs" then return false,"RS" end
            end,
            slots = {
                [0] = {false},
                ["ak74_dustcover"] = {"ak74_dustcover",vec = Vector(0,-18.9,1.5)},
                ["ak74_dustcover_defence"] = {"ak74_dustcover_defence",vec = Vector(0,-18.9,1.5)}
            }
        },
        ["6"] = {
            name = "RS",
            slotPos = Vector(0,-20.5,2),
            slots = {
                [0] = {false},
                ["ak74_rs"] = {"ak74_rs",vec = Vector(0,-20.56,1.8)},
                ["ak74_rs_mount"] = {"ak74_rs_mount",vec = Vector(0,-20.56,1.8)}
            }
        },
        ["7"] = {
            name = "NMount",
            slotPos = Vector(1,-13,-0.65),
            canFunc = function(self,path,key)
                if self.attachments["7"][2][1] and self.attachments["5"][2][1] and self.attachments["5"][2][1] != "ak74_dustcover" then return false,"NMount" end
            end,
            slots = {
                [0] = {false}
            }
        },
        ["8"] = {
            name = "Muzzle",
            slotPos = Vector(0,-36,0),
            slots = {
                [0] = {false},
                ["ak74_muzzle_556x45"] = {"ak74_muzzle_556x45",bone = "mod_muzzle",ang = Angle(0,-90,0)}
            }
        }
    }
}

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["4"].slots,"ak_grip",Vector(0,-12.2,-1.4),Angle(0,90,0))
attachmentGame.ManualCreate(SWEP.MainAttachment.slots["7"].slots,"nmount",Vector(0,-11.2,1.8),Angle())

if CLIENT then
    texture_uv.RegUV("models/weapons/arc9/darsu_eft/ak/weapon_izhmash_ak74_545x39_lod0","camo",util.JSONToTable('[{"transform":[0,0.739964459304795,0.5705335765259889,0.09286778649891676],"rotate":180,"uiHide":false,"uvScale":[0,0,2,0.3]},{"transform":[0,0.9032875458668964,0.5889932520597767,0.09593222350904636],"rotate":0,"uiHide":false,"uvScale":[0,0,2,0.3]},{"transform":[0.810219107882937,0.22348472209078776,0.011111704215652897,0.1663585461744141],"rotate":270,"uiHide":false,"uvScale":[0.5,0.316,0,0.3]},{"transform":[0.35093020660057006,0.041842469057678904,0.04537523104487466,0.011225641322555302],"rotate":0,"uiHide":false,"uvScale":[0.3,0,0.346,0.1]},{"transform":[0.9317480162096508,0.27758283437038855,0.016666676725146854,0.3929112538884693],"rotate":270,"uiHide":true,"uvScale":[1,0.26,0.345,0.222]},{"transform":[0.794775462962963,0.24497500255076013,0.014818644724429238,0.4244958614838147],"rotate":90,"uiHide":false,"uvScale":[0,0.255,1.3825,0.3]},{"transform":[0.5268572473467862,0.8479881558857916,0.14354340927459333,0.016327484899214463],"rotate":180,"uiHide":false,"uvScale":[1.46,0.2,2,0.3]},{"transform":[0.5704151146234387,0.7296068904248626,0.1565086204348792,0.1102333338992681],"rotate":0,"uiHide":false,"uvScale":[0,0,0.5,0.5]},{"transform":[0.8102912505598048,0.3898264969670121,0.01852083487722366,0.6102825880868066],"rotate":270,"uiHide":false,"uvScale":[0,1,2.04,0.9]},{"transform":[0.8482054392137067,0.3857513737088356,0.006481919295301253,0.6143447803511085],"rotate":270,"uiHide":false,"uvScale":[0,0.9,1.947,1]},{"transform":[0.8380697942326034,0.26327430110533606,0.010186483686805125,0.39287056560292394],"rotate":90,"uiHide":false,"uvScale":[0.7,0.34,2,0.36]},{"transform":[0.6037460764992283,0.689824800330233,0.14076514974024637,0.05103395087929078],"rotate":0,"uiHide":false,"uvScale":[0,0,1,1]},{"transform":[0.0009263220784877285,0.5359581700421787,0.15747475334291383,0.11331687023748921],"rotate":0,"uiHide":false,"uvScale":[0,0,0.5,-0.5]}]'))
end

SWEP.AttachmentDefault = {
    {"1","ak_stock_wood"},
    {"5","ak74_dustcover"},
    {"6","ak74_rs"}
}

attachmentGame.RegCosmeticCategory("ak",{name = "AL",prio = 9})

attachmentGame.RegCosmetic("akm",{
    printName = "AKM",
    desc = "Превращает стоковые модули от AK в AKM",
    icon = "entities/arc9_eft_akm.png",
    category = "ak",

    list = {
        ["akm_wood"] = true,
    }
})

attachmentGame.RegCosmetic("aks74",{
    printName = "AKS-74",
    desc = "Превращает стоковые модули от AK в AKS-74",
    icon = "entities/arc9_eft_akms.png",
    category = "ak",

    list = {
        ["ak74"] = true
    }
})

attachmentGame.RegCosmetic("ak100",{
    printName = "AK-100",
    desc = "Превращает стоковые модули от AK в AK-100",
    icon = "entities/arc9_eft_ak101.png",
    category = "ak"
})

WepAtt("ak74_dustcover",{
    printName = "AK 74 DustCover",
    icon = "entities/eft_ak_attachments/dc_74.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_dc_ak74_std.mdl",
})

WepAtt("ak74_muzzle_556x45",{
    printName = "AK74 Muzzle 556x45",
    icon = "entities/eft_ak_attachments/muzzle/74.png",
    model = "models/weapons/arc9/darsu_eft/mods/muzzle_ak74_izhmash_std_545x39.mdl",
    MuzzlePos = Vector(2.3,0,0),
})

local att = WepAtt("ak74_dustcover_defence",{
    printName = "AK DustCover Defence",
    icon = "entities/eft_ak_attachments/dc_fab.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_dc_fab_defence_pdc.mdl",

    slots = {
        ["2"] = {
            name = "Close",
            slotPos = Vector(0,1,0.5),
            slots = {
                [0] = {false}
            }
        },
        ["1"] = {
            name = "Far",
            slotPos = Vector(0,8,0.5),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"scope_mount",Vector(0,6.5,0.25),Angle())
attachmentGame.ManualCreate(att.slots["2"].slots,"scope_mount",Vector(0,1.6,0.25),Angle())

WepAtt("ak74_rs",{
    printName = "AK RS",
    icon = "entities/eft_ak_attachments/rs_74.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_rs_ak74_std.mdl"
})

local att = WepAtt("ak74_rs_mount",{
    printName = "AK RS Mount",
    icon = "entities/eft_ak_attachments/rs_tt01.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_rs_tula_tt01.mdl",

    slots = {
        ["1"] = {
            name = "Sight",
            slotPos = Vector(0,3,0),
            slots = {
                [0] = {false},
                ["mount_rm33"] = {"mount_rm33",vec = Vector(0,3,0),ang = Angle(0,-90,0)}
            }
        }
    }
})

local att = WepAtt("ak74_gasblock_std",{
    printName = "AK GasBlock 74",

    icon = "entities/eft_ak_attachments/gas_74.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_gb_akm_std.mdl",

    slots = {
        ["1"] = {
            name = "Handguard",
            slotPos = Vector(0,0,-1.4),
            slots = {}
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"ak_handguard",Vector(0,1.76,-0.46),Angle())
att.slots["1"].slots[0] = att.slots["1"].slots["ak74_handguard_wood"]
att.slots["1"].slots["ak74_handguard_wood"] = nil

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["1"].slots,"ak_stock",Vector(0.6,-9.6,-0.7),Angle())

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["4"].slots,"ak_grip",Vector(0,-12.2,-1.4),Angle())
SWEP.MainAttachment.slots["4"].slots[0] = SWEP.MainAttachment.slots["4"].slots["ak_grip_wood"]
SWEP.MainAttachment.slots["4"].slots["ak_grip_wood"] = nil

attachmentGame.ManualCreate(SWEP.MainAttachment.slots["8"].slots,"muzzle_545",Vector(),Angle(0,-90,0))
