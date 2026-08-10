inventoryManager.listClass = inventoryManager.listClass or {}
inventoryManager.listGame = inventoryManager.listGame or {}

function inventoryManager:ItemReg(name,base,isFolder) return oop.Reg(name,base,isFolder,0,inventoryManager.listClass) end
function inventoryManager:ItemGet(name) return oop.Get(name,inventoryManager.listClass) end

function inventoryManager:GetItemClassFromData(item)
    return inventoryManager.listClass[item.class]
end

function inventoryManager:InvertItemData(item)
    local newItem = {
        id = item.id,
        class = item.class,
        type = item.type,
        steamid64 = item.steamid64,

        timestamp_create = item.timestamp_create,
        timestamp_update = item.timestamp_update
    }

    if item.data then
        newItem.data = item.data
    else
        local data = {}
        newItem.data = data
        util.tableLink(data,item)

        data.class = nil
        data.type = nil
        data.steamid64 = nil

        data.atimestamp_create = nil
        data.timestamp_update = nil
    end
    
    return newItem
end

function inventoryManager:CreateItemObjectFromData(item)
    item = inventoryManager:InvertItemData(item)

    self:LinkItemObjectByClass(item)
    
    return item
end

function inventoryManager:LinkItemObjectByClass(item)
    local class = inventoryManager:GetItemClassFromData(item)

    if class then
        util.tableLink(item,class[1])
    else
        util.tableLink(item,inventoryManager.listClass.missing[1])
    end
end

DonatCategories = {
    ["1_models"] = "donat_ui_category_models",
    ["2_accessories"] = "donat_ui_category_accessories",
    ["3_icons"] = "donat_ui_category_icons",
    ["4_items"] = "donat_ui_category_items",
    ["5_case"] = "Cases"
}

DonatCategoriesDefaultNone = "3_icons"

//

DonatItemsRaryData = {
    common = {
        Color(0,0,0),
        Color(255,255,255),
        Color(255,255,255),
        "points50",
        {
            "physics/flesh/flesh_impact_hard2.wav",
            "physics/flesh/flesh_impact_hard3.wav"
        },
        {
            "physics/flesh/flesh_impact_bullet1.wav",
            "physics/flesh/flesh_impact_bullet2.wav",
            "physics/flesh/flesh_impact_bullet3.wav"
        },
        "Обычный",
        "homigrad/vgui/item_drop2_uncommon.wav"
    },
    uncommon = {
        Color(120,225,120),
        Color(0,0,0),
        Color(255,255,255),
        "romb",
        {
            "physics/rubber/rubber_tire_impact_hard1.wav",
            "physics/rubber/rubber_tire_impact_hard2.wav",
            "physics/rubber/rubber_tire_impact_hard3.wav"
        },
        {
            "physics/rubber/rubber_tire_impact_bullet1.wav",
            "physics/rubber/rubber_tire_impact_bullet2.wav",
            "physics/rubber/rubber_tire_impact_bullet3.wav"
        },
        "Необычный",
        "homigrad/vgui/item_drop2_uncommon.wav"
    },
    rary = {
        Color(164,67,233),
        Color(0,0,0),
        Color(255,255,255),
        "box_i",
        {
            "physics/wood/wood_plank_impact_soft1.wav",
            "physics/wood/wood_plank_impact_soft2.wav",
            "physics/wood/wood_plank_impact_soft3.wav"
        },
        {
            "physics/wood/wood_box_impact_bullet1.wav",
            "physics/wood/wood_box_impact_bullet2.wav",
            "physics/wood/wood_box_impact_bullet3.wav",
        },
        "Редкий",
        "homigrad/vgui/item_drop3_rare.wav"
    },
    legendary = {
        Color(248,250,112),
        Color(255,0,0),
        Color(255,0,0),
        "pletanka",
        {
            "physics/glass/glass_bottle_impact_hard1.wav",
            "physics/glass/glass_bottle_impact_hard2.wav",
            "physics/glass/glass_bottle_impact_hard3.wav"
        },
        {
            "physics/glass/glass_pottery_break1.wav",
            "physics/glass/glass_pottery_break2.wav",
            "physics/glass/glass_pottery_break3.wav"
        },
        "Легендарный",
        "homigrad/vgui/item_drop4_mythical.wav"
    },
    epic = {
        Color(76,252,255),
        Color(255,255,0),
        Color(255,255,0),
        "romb_d",
        {
            "physics/metal/metal_box_impact_bullet1.wav",
            "physics/metal/metal_box_impact_bullet2.wav",
            "physics/metal/metal_box_impact_bullet3.wav"
        },
        {
            "physics/metal/metal_chainlink_impact_hard1.wav",
            "physics/metal/metal_chainlink_impact_hard2.wav",
            "physics/metal/metal_chainlink_impact_hard3.wav"
        },
        "Эпичский",
        "homigrad/vgui/item_drop6_ancient.wav"
    }
}

DonatItemsRaryDataIndex = {
    common = 5,
    uncommon = 4,
    rary = 3,
    legendary = 2,
    epic = 1
}

DonatItemsRaryDataIndexToName = {
    "epic",
    "legendary",
    "rary",
    "uncommon",
    "common"
}

function inventoryManager:SortItemList(inventory,sortCategory)
    inventory = inventory or {}

    local sort = {}

    for id,item in pairs(inventory) do
        if item.category then
            if sortCategory and item.category != sortCategory then continue end
        else
            if sortCategory and sortCategory != DonatCategoriesDefaultNone then continue end
        end

        local id = DonatItemsRaryDataIndex[item:GetRaryType()] or 0
        local class = item.class or "missing"
        sort[id] = sort[id] or {}
        sort[id][class] = sort[id][class] or {}

        sort[id][class][#sort[id][class] + 1] = item
    end

    local result = {}

    for id,list in SortedPairs(sort) do
        for class,list in SortedPairs(list) do
            table.sort(list,function(a,b) return (a:GetPrintName() or "UNKOWN") > (b:GetPrintName() or "UNKOWN") end)

            for _,item in pairs(list) do
                result[#result + 1] = item
            end
        end
    end

    return result
end