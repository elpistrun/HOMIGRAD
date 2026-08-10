DonatItem_PlayerModelEasyReg("models/player/furry/wolfy.mdl","Wolfy","","uncommon")
DonatItem_PlayerModelEasyReg("models/Keith3201/Ligeia/Ligeia_pm.mdl","Ligeia Furry","","rary",{
    [-1] = {
        name = "Скин",
        max = 10
    },
    [1] = {
        name = "Глаза",
        max = 2
    },
    [2] = {
        name = "Торс",
        max = 2
    },
    [3] = {
        name = "Ноги",
        max = 1
    }
})

modelSetting.Reg("models/keith3201/ligeia/ligeia_pm.mdl",{
    ArmorOffset = {
        ["ValveBiped.Bip01_Head1"] = {
            vec = Vector(-1.9,2.4,0),
            size = Vector(0.2,0.35,0.2)
        },
        ["ValveBiped.Bip01_Spine2"] = {
            vec = Vector(3,-3,0),
            size = -Vector(0.3,0.3,0.2)
        }
    },
    hitBoxBounds = {
        ["ValveBiped.Bip01_Head1"] = {-Vector(1,5,6),Vector(13,6,6)}
    }
})

DonatItem_PlayerModelEasyReg("models/kuma96/chinesesoldier/chinesesoldier_pm.mdl","Chinese Soldier","","common",{
    [-1] = {
        name = "Скин",
        max = 5
    }
})

local bodygroups = {
    xp = 100,
    [-1] = {
        name = "Скин",
        max = 3
    },
    [2] = {
        name = "Кепка",
        max = 1
    },
}

local bodygroupsEmpty = {
    [2] = 1
}

for i = 1,9 do
    DonatItem_PlayerModelEasyReg("models/player/Rusty/NatGuard/male_0" .. i .. ".mdl","Militry Male " .. i,"","uncommon",bodygroups,bodygroupsEmpty)
end

DonatItem_PlayerModelEasyReg("models/ebmage/funnyrat.mdl","Rat","","uncommon",{
    xp = 1000,
    [-1] = {
        xp = 1000,
        name = "Скин",
        max = 1
    },
    [1] = {
        name = "Шляпа",
        max = 8
    }
},nil,true)

modelSetting.Reg("models/ebmage/funnyrat.mdl",{
    ArmorOffset = {
        ["ValveBiped.Bip01_Head1"] = {
            vec = Vector(3,5,0),
            size = Vector(0.2,0.35,0.2)
        },
        ["ValveBiped.Bip01_Spine2"] = {
            vec = Vector(0,0,0),
            size = Vector(0.3,0.3,0.2)
        }
    }
})

DonatItem_PlayerModelEasyReg("models/gruchk/oc/cool_skeleton.mdl","Cool Skeleton!","","uncommon",{
    xp = 100,
    [-1] = {
        name = "Скин",
        max = 3
    }
})
DonatItem_PlayerModelEasyReg("models/player/hellmentor.mdl","Hell Mentor","","uncommon")

DonatItem_PlayerModelEasyReg("models/player/boykisser/Boykisser.mdl","Boy Kisser","","rary",{
    xp = 5000,
    raryType = "rary",
    [0] = {
        name = "Skin",
        max = 1
    },
    [1] = {
        name = "Fluff Hands",
        max = 1
    },
    [2] = {
        name = "Fluff Arms",
        max = 1
    },
    [3] = {
        name = "Fluff Chest",
        max = 1
    },
    [4] = {
        name = "Fluff Hips",
        max = 1
    },
    [5] = {
        name = "Hoodie",
        max = 5
    },
    [6] = {
        name = "Socks",
        max = 5
    }
})

DonatItem_PlayerModelEasyReg("models/kapuyas/kemono/kurena/asdfg_kurena_pm.mdl","Kurena Furry","","rary",{
    [1] = {
        name = "Шляпа",
        max = 1
    },
    [2] = {
        name = "Ошейник",
        max = 1
    },
    [4] = {
        name = "Одежда",
        max = 1
    },
    [10] = {
        name = "Ноги",
        max = 3
    }
},{
    [3] = 1,
    [6] = 1,
    [9] = 1
})

DonatItem_PlayerModelEasyReg("models/eradium/nardo/lepetitnardo.mdl","Lepetitnardo Furry","","uncommon",{
    [1] = {
        name = "Шорты",
        max = 1
    },
    [2] = {
        name = "Причёска",
        max = 1
    },
},{
    [1] = 1,
    [2] = 1
})

DonatItem_PlayerModelEasyReg("models/player/pissbaby.mdl","Палочник","не оборачивайся....","legendary",{
    [-1] = {
        name = "Лицо",
        max = 6
    }
},nil,true)

modelSetting.Reg("models/player/pissbaby.mdl",{
    ArmorOffset = {
        ["ValveBiped.Bip01_Head1"] = {
            vec = Vector(-1,1,0),
            size = -Vector(0.5,0,0)
        },
        ["ValveBiped.Bip01_Spine2"] = {
            vec = Vector(1,0.8,0),
            size = -Vector(0.4,0.4,0.1)
        }
    }
})

DonatItem_PlayerModelEasyReg("models/player/SGG/hev_helmet.mdl","HEV SUIT","чисто косметика","common",{
    [-1] = {
        name = "Скин",
        max = 1
    }
})

local ArmorOffset = {
    ["ValveBiped.Bip01_Head1"] = {
        vec = Vector(-1.1,2.4,0),
        size = Vector(0.2,0.2,0.2)
    },
    ["ValveBiped.Bip01_Spine2"] = {
        vec = Vector(0,0,0),
        size = -Vector(0,0,0)
    }
}

DonatItem_PlayerModelEasyReg("models/Ultrakill/V2.mdl","V2","ULTRAKILL","uncommon",{
    [-1] = {
        name = "Скин",
        max = 3
    },
    [1] = {
        name = "Крылья",
        max = 1
    },
    [2] = {
        name = "Рука",
        max = 1
    }
},{
    [1] = 1
})

modelSetting.Reg("models/ultrakill/v2.mdl",{
    ArmorOffset = ArmorOffset
})

DonatItem_PlayerModelEasyReg("models/Ultrakill/V1_PM.mdl","V1","ULTRAKILL","uncommon",{
    [1] = {
        name = "Крылья",
        max = 1
    },
    [2] = {
        name = "Рука",
        max = 1
    }
},{
    [1] = 1
})

modelSetting.Reg("models/ultrakill/v1.mdl",{
    ArmorOffset = ArmorOffset
})

DonatItem_PlayerModelEasyReg("models/player/ghost_rider/ghost_rider.mdl","Ghost Rider","","uncommon",{
    [-1] = {
        name = "Скин",
        max = 7
    }
})

DonatItem_PlayerModelEasyReg("models/player/gasmask.mdl","Gas Mask","","common")
DonatItem_PlayerModelEasyReg("models/player/riot.mdl","Riot","","common")
DonatItem_PlayerModelEasyReg("models/player/swat.mdl","SWAT","","common")
DonatItem_PlayerModelEasyReg("models/player/urban.mdl","Urban","","common")

DonatItem_PlayerModelEasyReg("models/player/arctic.mdl","Artic","","common")
DonatItem_PlayerModelEasyReg("models/player/guerilla.mdl","guerilla","","common",nil,nil,true)
DonatItem_PlayerModelEasyReg("models/player/leet.mdl","leet","","common",nil,nil,true)
DonatItem_PlayerModelEasyReg("models/player/phoenix.mdl","Phoenix","","common",nil,nil,true)

DonatItem_PlayerModelEasyReg("models/player/dod_american.mdl","Dod American","","common",{
    [0] = {
        name = "Body",
        max = 5
    },
    [1] = {
        name = "Helmet",
        max = 1
    }
},{
    [1] = 1
})

DonatItem_PlayerModelEasyReg("models/player/dod_german.mdl","Dod German","","common",{
    [0] = {
        name = "Body",
        max = 5
    },
    [1] = {
        name = "Helmet",
        max = 1
    }
},{
    [1] = 1
})

DonatItem_PlayerModelEasyReg("models/splinks/hotline_miami/jacket/drive/player_jacket_drive.mdl","Райн гослинг","","legendary")

modelSetting.Reg("models/splinks/hotline_miami/jacket/drive/player_jacket_drive.mdl",{
    HeadPop = true
})