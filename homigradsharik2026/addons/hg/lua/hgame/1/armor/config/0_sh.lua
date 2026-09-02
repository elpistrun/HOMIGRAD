armorGame.RegCategory("helmet",{prio = 1,printName = "Шлем"})
armorGame.RegCategory("mask",{prio = 2,printName = "Маски"})
armorGame.RegCategory("headset",{prio = 3,printName = "Наушники"})

armorGame.RegCategory("neck",{prio = 4,printName = "Шея"})
armorGame.RegCategory("pelvis",{prio = 5,printName = "Живот"})

armorGame.RegCategory("armor",{prio = 6,printName = "Бронижелеты"})
armorGame.RegCategory("dump",{prio = 7,printName = "Бронижелеты с разгрузкой"})
armorGame.RegCategory("updump",{prio = 8,printName = "Разгрузка"})

armorGame.RegCategory("backpack",{prio = 9,printName = "Рюкзаки"})

armorGame.RegCategory("other",{prio = 10,printName = "Разное"})
armorGame.RegAttCategory("other",{prio = 10,printName = "Разное"})

armorGame.BoneToSlot = {
    ["ValveBiped.Bip01_Head1"] = {head = true,mask = true},
    ["ValveBiped.Bip01_Spine2"] = {chest = true},
    ["ValveBiped.Bip01_Spine"] = {chest = true},
    ["ValveBiped.Bip01_Spine4"] = {chest = true},
    ["ValveBiped.Bip01_Pelvis"] = {pelvis = true}
}

armorGame.entityClassAttachmentMap = armorGame.entityClassAttachmentMap or {}

armorGame.ArmorTierIndex = {
    [2] = {
        name = "2 Класс защиты"
    },
    [3] = {
        name = "3 Класс защиты"
    },
    [4] = {
        name = "4 Класс защиты"
    },
    [5] = {
        name = "5 Класс защиты"
    }
}

armorGame.ArmorAtletichIndex = {
    [1] = {name = "Лёгкая"},
    [2] = {name = "Средняя"},
    [3] = {name = "Тяжёлая"},
}
--

armorGame.head_vec = Vector(2.5,-0.5,0)
armorGame.head_ang = Angle(0,-90,-90) + Angle(0,15,0)

armorGame.backpack_vec = Vector(-1.7,4.5,0)
armorGame.backpack_ang = Angle(0,90,90)

armorGame.body_vec = Vector(-1.5,3,0)
armorGame.body_ang = Angle(0,90 + 5,90)

armorGame.pelvis_vec = Vector(0,5.5,-1)
armorGame.pelvis_ang = Angle(-90 + 5,-90,0)

armorGame.neck_vec = Vector(-11,-10,0)
armorGame.neck_ang = Angle(0,-60,-90)

--

armorGame.sound_helmet = {
    soundPickup = "eft_gear_sounds/gear_helmet_pickup.wav",
    soundUse = "eft_gear_sounds/gear_helmet_use.wav",
    soundDrop = "eft_gear_sounds/gear_helmet_drop.wav",
    isHelmetEffect = true
}

armorGame.sound_armor = {
    soundPickup = "eft_gear_sounds/gear_armor_pickup.wav",
    soundUse = "eft_gear_sounds/gear_backpack_use.wav",
    soundDrop = "eft_gear_sounds/gear_armor_drop.wav",
}

armorGame.sound_generic = {
    soundPickup = "eft_gear_sounds/gear_generic_pickup.wav",
    soundUse = "eft_gear_sounds/gear_generic_use.wav",
    soundDrop = "eft_gear_sounds/gear_generic_drop.wav",
}

armorGame.sound_goggles = {
    soundPickup = "eft_gear_sounds/gear_goggles_pickup.wav",
    soundUse = "eft_gear_sounds/gear_goggles_use.wav",
    soundDrop = "eft_gear_sounds/gear_goggles_drop.wav",
}

armorGame.sound_backpack = {
    soundPickup = "eft_gear_sounds/gear_backpack_pickup.wav",
    soundUse = "eft_gear_sounds/gear_armor_use.wav",
    soundDrop = "eft_gear_sounds/gear_backpack_drop.wav",
}

--

armorGame.dump_inventory_1 = {
    inventoryClass = "inv_dump",
    inventorySize = {3,2},
    invColor = Color(40,80,200),
}

armorGame.dump_inventory_2 = {
    inventoryClass = "inv_dump",
    inventorySize = {3,3},
    invColor = Color(120,80,255),
}

armorGame.backpack_inventory_1 = {
    inventoryClass = "inv_backpack",
    inventorySize = {2,3},
    invColor = Color(90,90,255),

    loadCapacity = 0.25,
}

armorGame.backpack_inventory_2 = {
    inventoryClass = "inv_backpack",
    inventorySize = {3,4},
    invColor = Color(90,90,255),

    loadCapacity = 0.1,
}

armorGame.headset_1 = {
    ExtinguishGunShoot = true
}

--[[
    голова, лицо
    наушники, шея.

    торс, разгрузка,
    живот, рюкзак

    левое плево, правое плечо,
    левое запастье, правое запастье,

    левое бедро, правое бедро,
    левая ногна, правая нога
]]

if Initialize and not overridedevarmorconfig then
    overridedevarmorconfig = true
    IncludeDir("hgame/1/armor/config/")
    overridedevarmorconfig = nil
end