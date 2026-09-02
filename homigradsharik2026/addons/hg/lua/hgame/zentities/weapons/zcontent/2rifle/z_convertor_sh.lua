local att = WepAtt("ak_grip_to_ar15",{
    printName = "CG101",
    icon = "entities/eft_ak_attachments/grip/ak2m4.png",
    model = "models/weapons/arc9/darsu_eft/mods/pistolgrip_ak_cg101_adapter.mdl",
    slots = {
        ["1"] = {
            name = "Grip",
            slotPos = Vector(0,1.6,-1.2),
            slots = {}
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"ar15_grip",Vector(0,0.6,-0.3),Angle(-2,-90,0))
att.slots["1"].slots[0] = att.slots["1"].slots["ar15_grip_colt"]
att.slots["1"].slots["ar15_grip_colt"] = nil

attachmentGame.ManualReg("ar15_grip_convertor",{
    ["ar15_grip_colt"] = {"ar15_grip_colt"},
    ["ar15_grip_skeleton"] = {"ar15_grip_skeleton"}
})

attachmentGame.ManualReg("ak_grip",{
    ["ak_grip_to_ar15"] = {"ak_grip_to_ar15"},
})

--

local att = WepAtt("ak_stock_to_ar15_me4",{
    printName = "ME4",
    icon = "entities/eft_ak_attachments/stock/me4.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_stock_utg_sfs.mdl",
    
    slots = {
        ["1"] = {
            name = "Stock",
            slotPos = Vector(0,3,0.2),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"ar15_stock",Vector(-0.8,3.1,0.2),Angle(0,-90,0))

local att = WepAtt("ak_stock_to_ar15_caa",{
    printName = "CAA AKTS",
    icon = "entities/eft_ak_attachments/stock/aktsakm.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_stock_caa_akts.mdl",
    
    slots = {
        ["1"] = {
            name = "Stock",
            slotPos = Vector(0,3,0.2),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"ar15_stock_tube",Vector(-0.69,4,-0.7),Angle(0,-90,0))

attachmentGame.ManualReg("ak_stock",{
    ["ak_stock_to_ar15_me4"] = {"ak_stock_to_ar15_me4"},
    ["ak_stock_to_ar15_caa"] = {"ak_stock_to_ar15_caa"}
})

local att = WepAtt("ak_stock_akts",{
    printName = "AKTS Stock",
    icon = "entities/eft_ak_attachments/stock/aktsakm.png",
    model = "models/weapons/arc9/darsu_eft/mods/ak_stock_caa_akts.mdl",

    slots = {
        ["1"] = {
            name = "Stock Tube",
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"ar15_stock_tube",Vector(-4,-0.06,-0.8),Angle())