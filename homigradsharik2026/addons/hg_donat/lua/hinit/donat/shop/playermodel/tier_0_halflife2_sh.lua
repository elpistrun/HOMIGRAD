DonatItems_PlayerModels = DonatItems_PlayerModels or {}
DonatItems_PlayerModelsBodygroups = DonatItems_PlayerModelsBodygroups or {}

function DonatItem_PlayerModelReg(modelName,model)
    if model.bodygroups then
        local newBodygroups = {}
        local max = 0
        local xp,raryType = model.bodygroups.xp,model.bodygroups.raryType

        raryType = raryType or "common"
        xp = xp or 100

        for x,info in pairs(model.bodygroups) do
            if TypeID(x) != TYPE_NUMBER then continue end

            newBodygroups[x] = {}

            if info.max then
                for y = 0,info.max do info[y] = info[y] or {} end
            end

            local raryType = info.raryType or raryType
            local xp = info.xp or xp
            local name = info.name

            for y = 0,#info do
                local info = info[y]
                newBodygroups[x][y] = {
                    xp = info.xp or xp,
                    raryType = info.raryType or raryType,
                    name = info.name or name
                }
            end

            max = math.max(max,x)
        end

        model.bodygroupsMax = max
        model.bodygroups = newBodygroups
    else
        model.bodygroupsMax = -2
        model.bodygroups = {}
    end

    DonatItems_PlayerModels[modelName] = model

    return model
end

function DonatItem_PlayerModelEasyReg(modelName,name,desc,raryType,bodyrgoups,bodygroupsEmpty,colorable)
    local model = {
        name = name,
        desc = desc,
        raryType = raryType,
        colorable = colorable,
        cantTrade = false,

        bodygroups = bodyrgoups,
        bodygroupsEmpty = bodygroupsEmpty
    }

    return DonatItem_PlayerModelReg(modelName,model)
end

//

local bodygroups = {
    [-1] = {
        name = "donat_item_playermodel_bg_face",
        xp = 100,
        max = 23
    },
    [1] = {
        name = "donat_item_playermodel_bg_tors",
        xp = 100,
        max = 37,
        [8] = {raryType = "uncommon"},
        [9] = {raryType = "uncommon"},
        [14] = {raryType = "uncommon"},
        [15] = {raryType = "uncommon"},
        [16] = {raryType = "uncommon"},
        [20] = {raryType = "uncommon"},
        [21] = {raryType = "uncommon"},
        [33] = {raryType = "rary",xp = 500},
        [34] = {raryType = "rary",xp = 1000},
        [35] = {raryType = "rary",xp = 1000},
        [36] = {raryType = "legendary",xp = 10000},
        [37] = {raryType = "legendary",xp = 10000},
    },
    [2] = {
        name = "donat_item_playermodel_bg_legs",
        xp = 100,
        max = 19,
        [8] = {raryType = "rary",xp = 500},
        [12] = {raryType = "rary",xp = 500},
        [13] = {raryType = "rary",xp = 500},
        [14] = {raryType = "rary",xp = 500},
        [15] = {raryType = "rary",xp = 500},
        [18] = {raryType = "legendary",xp = 10000},
        [19] = {raryType = "legendary",xp = 10000},
    },
    [3] = {
        name = "donat_item_playermodel_bg_hands",
        xp = 1000,
        raryType = "rary",
        max = 4,
        [2] = {raryType = "legendary",xp = 10000},
    },
    [4] = {
        name = "donat_item_playermodel_bg_headress",
        xp = 300,
        max = 6,
        [11] = {raryType = "rary",xp = 500},
        [12] = {raryType = "rary",xp = 500},
        [6] = {raryType = "rary",xp = 500},
    },
    [6] = {
        name = "donat_item_playermodel_bg_glasses",
        xp = 300,
        max = 3,
        [3] = {raryType = "legendary",xp = 10000},
    },
    [8] = {
        name = "donat_item_playermodel_bg_mask",
        xp = 300,
        max = 6,
        [4] = {raryType = "rary",xp = 1000},
        [5] = {raryType = "rary",xp = 1000},
        [6] = {raryType = "rary",xp = 1000}
    },
    [12] = {
        name = "donat_item_playermodel_bg_beard",
        raryType = "legendary",
        xp = 3000,
        max = 8
    }
}

local bodygroupsHead = {5}

local setupPlayerModel = function(item,ent)
    if levelActive.red and levelActive.blue then
        ent:SetBodygroup(8,levelActive.teamEncoder[ent:Team()] == "red" and 4 or 5)
    end
end

for i = 1,7 do
    local name = "Female0" .. i
    if i == 5 then i = i + 1 end

    DonatItem_PlayerModelReg("models/player/pandafishizens/female_0" .. i .. ".mdl",{
        name = name,
        desc = "donat_item_playermodel_halflife2_female_desc",
        raryType = "common",
        bodygroups = bodygroups,
        bodygroupsHead = bodygroupsHead,
        cantTrade = true,

        setupPlayerModel = setupPlayerModel,
    })
end

for i = 1,9 do
    DonatItem_PlayerModelReg("models/player/pandafishizens/male_0" .. i .. ".mdl",{
        name = "Male0" .. i,
        desc = "donat_item_playermodel_halflife2_male_desc",
        raryType = "common",
        bodygroups = bodygroups,
        bodygroupsHead = bodygroupsHead,
        cantTrade = true,
        
        setupPlayerModel = setupPlayerModel
    })
end

DonatItem_PlayerModelReg("models/player/pandafishizens/male_10.mdl",{
    name = "Male10",
    desc = "Сdonat_item_playermodel_halflife2_male_desc",
    raryType = "common",
    bodygroups = bodygroups,
    bodygroupsHead = bodygroupsHead,
    cantTrade = true,

    setupPlayerModel = setupPlayerModel
})

local femaleSettings = {
    ArmorOffset = {
        ["ValveBiped.Bip01_Head1"] = {
            vec = Vector(0,-1,0),
            size = -Vector(0,0.1,0)
        },
        ["ValveBiped.Bip01_Spine2"] = {
            vec = Vector(-2,-2,0),
            size = -Vector(0.05,0.1,0.01)
        }
    }
}

for i = 1,9 do modelSetting.Reg("models/player/pandafishizens/female_0" .. i .. ".mdl",femaleSettings) end--enchaned
for i = 10,25 do modelSetting.Reg("models/player/pandafishizens/female_" .. i .. ".mdl",femaleSettings) end--enchaned

for i = 1,9 do modelSetting.Reg("models/player/group01/female_0" .. i .. ".mdl",femaleSettings) end--hl2
for i = 1,9 do modelSetting.Reg("models/player/group03/female_0" .. i .. ".mdl",femaleSettings) end--hl2 rebels
for i = 1,6 do
    modelSetting.Reg("models/monolithservers/mpd/female_0" ..i.. ".mdl",femaleSettings)
    modelSetting.Reg("models/monolithservers/mpd/female_0" ..i.. "_2.mdl",femaleSettings)
end

local maleSettings = {
    ArmorOffset = {
        ["ValveBiped.Bip01_Spine2"] = {
            vec = Vector(0,-1,0),
        }
    }
}

for i = 1,9 do modelSetting.Reg("models/player/pandafishizens/male_0" .. i .. ".mdl",maleSettings) end--enchaned
for i = 10,25 do modelSetting.Reg("models/player/pandafishizens/male_" .. i .. ".mdl",maleSettings) end--enchaned

for i = 1,9 do modelSetting.Reg("models/player/group01/male_0" .. i .. ".mdl",maleSettings) end--hl2
for i = 1,9 do modelSetting.Reg("models/player/group03/male_0" .. i .. ".mdl",maleSettings) end--hl2 rebels
for i = 1,6 do
    modelSetting.Reg("models/monolithservers/mpd/male_0" ..i.. ".mdl",maleSettings)
    modelSetting.Reg("models/monolithservers/mpd/male_0" ..i.. "_2.mdl",maleSettings)
end
