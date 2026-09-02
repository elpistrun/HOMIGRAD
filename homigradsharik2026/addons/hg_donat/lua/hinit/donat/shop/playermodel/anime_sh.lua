DonatItem_PlayerModelEasyReg("models/zenlesszonezero/Corin Wickes.mdl","Corin Wickes","","rary",{
    xp = 1000,
    [2] = {
        name = "Мишка",
        max = 1
    }
})

modelSetting.Reg("models/zenlesszonezero/corin wickes.mdl",{
    ArmorOffset = {
        ["ValveBiped.Bip01_Head1"] = {
            vec = Vector(-2.5,0.5,0),
            size = Vector(0.15,0.15,0.15),
        },
        ["ValveBiped.Bip01_Spine2"] = {
            vec = Vector(3.5,-1,0),
            size = -Vector(0.25,0.3,0.1)
        }
    }
})

DonatItem_PlayerModelEasyReg("models/gamespy/mesmerizer/MSMikuHatsune.mdl","MS Miku Hatsune","","rary",{
    xp = 1000,
    [1] = {
        name = "Кепка",
        max = 1
    }
})

DonatItem_PlayerModelEasyReg("models/gamespy/mesmerizer/MSKasaneTeto.mdl","MS Kasane Teto","","rary",{
    xp = 1000,
    [1] = {
        name = "Кепка",
        max = 1
    }
})

local ArmorOffset = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1.5,0,0),
        size = -Vector(0,0,0)
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(1.5,-2.5,0),
        size = -Vector(0.2,0.3,0.1)
    }
}

local Ragdoll = {
    spineVelocity = 500,
    weightBonesLerp = 1
}

DonatItem_PlayerModelEasyReg("models/player/gfl2_lenna.mdl","Lenna","","rary",{
    xp = 1000,
    raryType = "rary",
    [1] = {
        name = "Голова",
        max = 2
    },
    [2] = {
        name = "Бантики",
        max = 1
    },
    [4] = {
        name = "Светошумовые гранаты",
        max = 1
    },
    [7] = {
        name = "Кобура слева",
        max = 1
    },
    [8] = {
        name = "Кобура справа",
        max = 2
    },
    [9] = {
        name = "Дубинка",
        max = 2
    },
    [10] = {
        name = "Наколеник",
        max = 1
    }
},
{
    [1] = 2,
    [2] = 1,
    [4] = 1,
    [7] = 1,
    [8] = 2,
    [9] = 2,
    [10] = 1
})

modelSetting.Reg("models/player/gfl2_lenna.mdl",{
    ArmorOffset = ArmorOffset,
    Ragdoll = Ragdoll
})

DonatItem_PlayerModelEasyReg("models/player/gfl2_lenna_dorm.mdl","Lenna Dorm","","rary",{
    xp = 1000,
    raryType = "rary",
    [1] = {
        name = "Голова",
        max = 2
    },
    [3] = {
        name = "Бантики",
        max = 1
    },
    [5] = {
        name = "Браслет Слева",
        max = 1
    },
    [6] = {
        name = "Браслет Справа",
        max = 1
    },
    [7] = {
        name = "Чулки",
        max = 1
    },
    [8] = {
        name = "Сандали",
        max = 1
    }
},{
    [3] = 1,
    [5] = 1,
    [6] = 1
})

modelSetting.Reg("models/player/gfl2_lenna_dorm.mdl",{
    ArmorOffset = ArmorOffset,
    Ragdoll = Ragdoll
})

DonatItem_PlayerModelEasyReg("models/player/gfl2_lenna_energetic_magic.mdl","Lenna Energetic","","rary",{
    xp = 1000,
    raryType = "rary",
    [1] = {
        name = "Голова",
        max = 2
    },
    [2] = {
        name = "Наушники",
        max = 1
    },
    [3] = {
        name = "Бантики",
        max = 1
    },
    [6] = {
        name = "Уточка",
        max = 1
    },
    [7] = {
        name = "Платок",
        max = 1
    },
    [9] = {
        name = "Дубинка",
        max = 2
    }
},{
    [1] = 2,
    [2] = 1,
    [3] = 1,
    [6] = 1,
    [7] = 1,
    [9] = 2

})

modelSetting.Reg("models/player/gfl2_lenna_energetic_magic.mdl",{
    ArmorOffset = ArmorOffset,
    Ragdoll = Ragdoll
})

DonatItem_PlayerModelEasyReg("models/player/gfl2_lenna_flying_phantom.mdl","Lenna Flying","","rary",{
    xp = 1000,
    raryType = "rary",
    [1] = {
        name = "Наушники",
        max = 2
    },
    [3] = {
        name = "Бантик",
        max = 1
    },
    [5] = {
        name = "Мыс",
        max = 1
    },
    [7] = {
        name = "Сумка",
        max = 1
    },
    [8] = {
        name = "Граната",
        max = 1
    },
    [10] = {
        name = "Кобура",
        max = 2
    },
    [11] = {
        name = "Дубинка",
        max = 2
    },
    [12] = {
        name = "Наколеник",
        max = 1
    },
    [13] = {
        name = "Ботинки",
        max = 2
    }
},{
    [1] = 2,
    [3] = 1,
    [5] = 1,
    [7] = 1,
    [8] = 1,
    [10] = 2,
    [11] = 2,
    [12] = 1,
    [13] = 2
})

modelSetting.Reg("models/player/gfl2_lenna_flying_phantom.mdl",{
    ArmorOffset = ArmorOffset,
    Ragdoll = Ragdoll
})

DonatItem_PlayerModelEasyReg("models/player/gfl2_mosin_nagant.mdl","Mosin Nagant","","rary",{
    xp = 1000,
    raryType = "rary",
    [1] = {
        name = "Шапка",
        max = 1
    },
    [3] = {
        name = "Гранаты",
        max = 1
    },
    [4] = {
        name = "Рация",
        max = 1
    },
    [7] = {
        name = "Сумка слева",
        max = 1
    },
    [8] = {
        name = "Сумка справа",
        max = 1
    }
},{
    [1] = 1,
    [3] = 1,
    [4] = 1,
    [7] = 1,
    [8] = 1
})

modelSetting.Reg("models/player/gfl2_mosin_nagant.mdl",{
    ArmorOffset = ArmorOffset,
    Ragdoll = Ragdoll
})

DonatItem_PlayerModelEasyReg("models/player/gfl2_mosin_nagant_dorm.mdl","Mosin Nagat Dorm","","rary",{
    xp = 1000,
    raryType = "rary",
    [3] = {
        name = "Браслет Справа",
        max = 1
    },
    [4] = {
        name = "Браслет Слева",
        max = 1
    },
    [5] = {
        name = "Чулки",
        max = 1
    },
    [6] = {
        name = "Сандали",
        max = 1
    }
},{
    [3] = 1,
    [4] = 1
})

modelSetting.Reg("models/player/gfl2_mosin_nagant_dorm.mdl",{
    ArmorOffset = ArmorOffset,
    Ragdoll = Ragdoll
})

DonatItem_PlayerModelEasyReg("models/player/gfl2_mosin_nagant_siberian_slide.mdl","Mosin Nagar Snow","","rary",{
    xp = 1000,
    raryType = "rary",
    [2] = {
        name = "Шапка",
        max = 1
    },
},{
    [2] = 1,
})

modelSetting.Reg("models/player/gfl2_mosin_nagant_siberian_slide.mdl",{
    ArmorOffset = ArmorOffset,
    Ragdoll = Ragdoll
})

DonatItem_PlayerModelEasyReg("models/MiSide/Player.mdl","MiSide Player","ты.... такой класный XD","rary",{
    raryType = "rary",
    xp = 500,
    [-1] = {
        name = "Скин",
        max = 5
    },
    [1] = {
        name = "Одеджа",
        max = 1
    },
    [2] = {
        name = "Волосы",
        max = 1
    },
    [4] = {
        name = "Ошейник",
        max = 1
    }
})

DonatItem_PlayerModelEasyReg("models/MiSide/mita.mdl","Mita","ы.... такой класный XD\nа давай.. сыграем в игру.. она называется.. ПАРАВОЗИК.\nчур ты первый\nХАХА ДЕЙСТВИТЕЛЬНО ПОВЁЛСЯ!!","legendary",{
    raryType = "rary",
    xp = 500,
    [-1] = {
        name = "Скин",
        max = 8,
        [4] = {
            xp = 3000,
            raryType = "legendary"
        }
    },
    [3] = {
        name = "Одежда",
        max = 9,
        xp = 3000,
        raryType = "legendary"
    },
    [4] = {
        name = "Причёска",
        max = 10,
        [8] = {
            xp = 3000,
            raryType = "legendary"
        }
    },
    [5] = {
        name = "Уши",
        max = 1
    },
    [6] = {
        name = "Перчатки",
        max = 2
    },
    [7] = {
        name = "Обувь",
        max = 7
    },
    [8] = {
        name = "Ошейник",
        max = 4
    },
    [9] = {
        name = "Очки",
        max = 1
    }
})

modelSetting.Reg("models/miside/mita.mdl",{
    ArmorOffset = {
        ["ValveBiped.Bip01_Head1"] = {
            vec = Vector(-1,1,0),
            size = Vector(0.1,0.1,0.1),
        },
        ["ValveBiped.Bip01_Spine2"] = {
            vec = Vector(2,-6,0),
            size = -Vector(0.25,0.3,0.1)
        }
    },
    Flex = {
        "O"
    }
})

modelSetting.Reg("models/miside/chibi.mdl",{
    ArmorOffset = {
        ["ValveBiped.Bip01_Head1"] = {
            vec = Vector(-1,-0.5,0),
            size = -Vector(0.3,0.3,0.3)
        },
        ["ValveBiped.Bip01_Spine2"] = {
            vec = Vector(3,0,0),
            size = -Vector(0.75,0.75,0.75)
        },

        ["ValveBiped.Bip01_L_Clavicle"] = {
            size = -Vector(0.75,0.75,0.75)
        },
        ["ValveBiped.Bip01_R_Clavicle"] = {
            size = -Vector(0.75,0.75,0.75)
        },

        ["ValveBiped.Bip01_L_UpperArm"] = {
            vec = Vector(0,0,1),
            size = -Vector(0.75,0.75,0.75)
        },
        ["ValveBiped.Bip01_R_UpperArm"] = {
            vec = Vector(0,0,-1),
            size = -Vector(0.75,0.75,0.75)
        },

        ["ValveBiped.Bip01_L_Forearm"] = {
            vec = Vector(0,0,1),
            size = -Vector(0.75,0.75,0.75)
        },
        ["ValveBiped.Bip01_R_Forearm"] = {
            vec = Vector(1,0,-1),
            size = -Vector(0.75,0.75,0.75)
        },

        ["ValveBiped.Bip01_L_Thigh"] = {
            vec = Vector(0.5,0,1.5),
            size = -Vector(0.75,0.8,0.75)
        },
        ["ValveBiped.Bip01_R_Thigh"] = {
            vec = Vector(-0.5,0,-1),
            size = -Vector(0.75,0.8,0.75)
        },

        ["ValveBiped.Bip01_L_Calf"] = {
            vec = Vector(1,0,0.5),
            size = -Vector(0.75,0.75,0.75)
        },
        ["ValveBiped.Bip01_R_Calf"] = {
            vec = Vector(1,0,-0.5),
            size = -Vector(0.75,0.75,0.75)
        },
    }
})

local item = DonatItem_PlayerModelEasyReg("models/nuj02/ori/Realistic/Tactical Anime/pm/[tac]ukon_pm.mdl","[Tactis] UKON.","omagad, poko\nдобавлено senku mode (84iq)","epic",{
    raryType = "rary",
    xp = 500,
    [-1] = {
        name = "Скин",
        max = 3
    },
    [1] = {
        name = "Глаза",
        max = 4
    },
    [4] = {
        name = "Уши",
        max = 1
    },
    [5] = {
        name = "Хвост",
        max = 1,
        raryType = "legendary",
        xp = 3000
    },
    [6] = {
        name = "Косичка слева",
        max = 1
    },
    [7] = {
        name = "Косичка справа",
        max = 1
    },
    [8] = {
        name = "Косичка сзади",
        max = 1
    },
    [9] = {
        name = "Бантик",
        max = 1
    },
    [10] = {
        name = "Бантик слева",
        max = 1
    },
    [11] = {
        name = "Бантик справа",
        max = 1
    },
    [12] = {
        name = "Бантик сзади",
        max = 1
    },
    [13] = {
        name = "Очки",
        max = 2,
        raryType = "legendary",
        xp = 3000
    },
    [14] = {
        name = "Призрак",
        max = 1,
        raryType = "epic",
        xp = 10000
    },
    [15] = {
        name = "Маска",
        max = 1,
        raryType = "legendary",
        xp = 3000
    },
    [17] = {
        name = "Аптечка сзади",
        max = 1
    },
    [20] = {
        name = "Бронеплита",
        max = 1,
        raryType = "epic",
        xp = 10000
    },
    [21] = {
        name = "Разгрузка",
        max = 1
    },
    [22] = {
        name = "Рация",
        max = 1
    },
    [23] = {
        name = "Очки ночного виденья",
        max = 2
    },
    [24] = {
        name = "Шлем",
        max = 1,
        raryType = "legendary",
        xp = 3000
    },
    [26] = {
        name = "Кобура",
        max = 1
    },
    [27] = {
        name = "Перчатки",
        max = 1
    },
    [29] = {
        name = "Сумка",
        max = 1
    },
    [30] = {
        name = "Штаны",
        max = 1
    },
    [31] = {
        name = "Обувь",
        max = 1
    }
},{
    [4] = 1,
    [5] = 1,
    [6] = 1,
    [7] = 1,
    [8] = 1,
    [9] = 1,
    [10] = 1,
    [11] = 1,
    [12] = 1,

    [13] = 2,
    [14] = 1,
    [15] = 1,
    [16] = 1,

    [17] = 1,

    [18] = 1,

    [20] = 1,
    [21] = 1,
    [22] = 1,

    [23] = 2,
    [24] = 1,
    [27] = 1,
    [26] = 1,
    [29] = 1,
    [30] = 1,
    [31] = 1,
})

item.bodygroupsParent = {
    [20] = {21,22,17},
    [24] = {23}
}
item.cameraPos = Vector(0,0,-5)

modelSetting.Reg("models/nuj02/ori/realistic/tactical anime/pm/[tac]ukon_pm.mdl",{
    ArmorOffset = {
        ["ValveBiped.Bip01_Head1"] = {
            vec = Vector(-2.3,0,0),
            size = Vector(0.3,0.4,0.25),
        },
        ["ValveBiped.Bip01_Spine2"] = {
            vec = Vector(5,0,0),
            size = Vector(0,0,-0.1),
            ang = Angle(-15,0,0)
        }
    },
    Ragdoll = {
        wideHand = 0,
        handVelocity = 3000,
        handRepeat = 3,
        handGrabVelocity = 300,

        spineVelocity = 700,

        handForceMul = 0.35,
        weightBonesLerp = 1,

        dontTakeDamagePhysInRagdoll = true
    },
    EyeOffset = {Vector(-3,0,3),Vector(4,0,0)},
    --HeadPop = false
})

DonatItem_PlayerModelEasyReg("models/drm/vrc/Rabbit_Hole_Miku.mdl","Rabbit Hole Miku","","legendary")

DonatItem_PlayerModelEasyReg("models/hololive/Hachaama-PM.mdl","Hachaama","","rary",{
    xp = 500,
    raryType = "rary",
    [5] = {
        name = "Повязка на глазу",
        max = 1
    },
    [6] = {
        name = "Косички",
        max = 1
    },
    [7] = {
        name = "Аксесуары на косички",
        max = 1
    },
    [8] = {
        name = "Бантик на голове",
        max = 1
    },
    [9] = {
        name = "Аксесуар на голове",
        max = 1
    },
    [12] = {
        name = "Бантик",
        max = 1
    },
    [13] = {
        name = "Шейный платок",
        max = 1
    },
    [14] = {
        name = "Аксесуар на шеи",
        max = 1
    },
    [15] = {
        name = "Юбка 1",
        max = 1
    },
    [17] = {
        name = "Юбка 2",
        max = 1
    }
},{
    [5] = 1,
    [6] = 1,
    [7] = 1,
    [8] = 1,
    [9] = 1,
    [12] = 1,
    [13] = 1,
    [14] = 1,
    [15] = 1,
    [17] = 1
})

modelSetting.Reg("models/hololive/hachaama-pm.mdl",{
    ArmorOffset = {
        ["ValveBiped.Bip01_Head1"] = {
            vec = Vector(-2.5,1,0),
            size = Vector(0.15,0.15,0.15),
        },
        ["ValveBiped.Bip01_Spine2"] = {
            vec = Vector(2,-4,0),
            size = -Vector(0.25,0.3,0.1)
        }
    },
    Ragdoll = {
        weightBonesLerp = 1
    }
})

DonatItem_PlayerModelEasyReg("models/dih/hl2tower_angel.mdl","HL2 Tower Angel","","rary",{
    [-1] = {
        name = "Скин",
        max = 27
    }
})

DonatItem_PlayerModelEasyReg("models/linqure/yangji/linq_american_soldier_pm.mdl","Linq American Soldier","","rary")
DonatItem_PlayerModelEasyReg("models/cypo/dokibird/dokibird_pm.mdl","Dokibird","меня накрыло жёстко","rary",{
    [1] = {
        name = "Шляпа",
        max = 1
    }
},{
    [1] = 1
}).cameraPos = Vector(-50,0,-10)

DonatItem_PlayerModelEasyReg("models/xinus22/mikuhl1.mdl","Miku HL1","swag reflection","rary",{
    xp = 500,
    raryType = "rary",
    [1] = {
        name = "Лицо",
        max = 8
    },  
    [2] = {
        name = "Рот",
        max = 8
    }
},{
    [-1] = 1
},true)

DonatItem_PlayerModelEasyReg("models/player/dewobedil/maid_dragon/kanna/default_p.mdl","Kanna Kamui","","rary",{
    xp = 500,
    raryType = "rary",
    [3] = {
        name = "Розовые щёки",
        max = 1
    },
    [4] = {
        name = "Розовые щёки 2",
        max = 1
    },
    [5] = {
        name = "Глаза сердечки",
        max = 1
    },
    [6] = {
        name = "Глаза звёздочки",
        max = 1
    },
    [7] = {
        name = "Рога",
        max = 1
    },
    [8] = {
        name = "Косички",
        max = 1
    },
    [9] = {
        name = "Одежда",
        max = 1
    },
    [11] = {
        name = "Хвост",
        max = 2
    }
},{
    [7] = 1,
    [8] = 1,
    [9] = 1,
    [11] = 2
})

modelSetting.Reg("models/player/dewobedil/maid_dragon/kanna/default_p.mdl",{
    ArmorOffset = {
        ["ValveBiped.Bip01_Head1"] = {
            vec = Vector(-1.3,0.1,0),
            size = Vector(0.05,0.05,0),
        },
        ["ValveBiped.Bip01_Spine2"] = {
            vec = Vector(3,-4,0),
            size = -Vector(0.3,0.3,0.3)
        }
    }
})

DonatItem_PlayerModelEasyReg("models/yota/sunday3rd/yota_sunday3rd.mdl","Youta Sunday","","epic",{
    xp = 500,
    raryType = "rary",
    [2] = {
        name = "Cape L",
        max = 1
    },
    [3] = {
        name = "Cape R",
        max = 1
    },
    [4] = {
        name = "Halo",
        max = 1
    },
    [5] = {
        name = "Wrings",
        max = 1
    },
})

modelSetting.Reg("models/yota/sunday3rd/yota_sunday3rd.mdl",{
    ArmorOffset = {
        ["ValveBiped.Bip01_Head1"] = {
            vec = Vector(-1.7,-0.6,0),
            size = -Vector(0.05,0.05,0.),
        },
        ["ValveBiped.Bip01_Spine2"] = {
            vec = Vector(3,-4,0),
            size = -Vector(0.1,0.1,0.1)
        }
    }
})