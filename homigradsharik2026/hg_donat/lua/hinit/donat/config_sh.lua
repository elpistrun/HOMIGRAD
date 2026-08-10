-- Free Drop

adminPanel.successRegistry("donat_moderate",nil,"rights")

local bodygroup1 = {class = "bodygroup",type = 1}
local bodygroup2 = {class = "bodygroup",type = 2}
local bodygroup3 = {class = "bodygroup",type = 3}
local bodygroup4 = {class = "bodygroup",type = 4}

local money25 = {class = "money",money = 100}
local money50 = {class = "money",money = 150}
local money100 = {class = "money",money = 200}

FreeDropTimeDelay = 60 * 60 * 18

FreeDropConfig = {
    {money25},
    {money25,bodygroup1},
    {money25,bodygroup1},
    {money25,bodygroup1},
    {money25,bodygroup1},
    {money25,bodygroup1,bodygroup1},
    {money25,bodygroup1,bodygroup1},//700 money, 800 xp

    {money25,bodygroup2},
    {money25},
    {money25,bodygroup2},
    {money25},
    {money25,bodygroup2},
    {money25},
    {money25,bodygroup2},//700 money, 2000 xp

    {money50},
    {money50,bodygroup3},
    {money50},
    {money50,bodygroup3},
    {money50},
    {money50,bodygroup3},
    {money50},//1050 money

    {money100,bodygroup3},//2000 xp

    {money100,bodygroup4},
    {money100,bodygroup4},
    {money100,bodygroup4},
    {money100,bodygroup4},
    {money100,bodygroup4},
    {money100,bodygroup4}//1400 money, 6000 xp
}//3850 money, 8800 xp

local money25 = {class = "money",money = 125}
local money50 = {class = "money",money = 200}
local money100 = {class = "money",money = 300}

FreeDropConfigAddedTitle = "Дополнительные награды"

FreeDropConfigAdded = {
    {money25,bodygroup1},
    {money25,bodygroup1},
    {money25,bodygroup1},
    {money25,bodygroup1,bodygroup1},
    {money25,bodygroup1,bodygroup1},
    {money25,bodygroup1,bodygroup1},
    {money25,bodygroup1,bodygroup1},//875 money, 1100 xp

    {money50,bodygroup2},
    {money50,bodygroup2},
    {money50,bodygroup2},
    {money50,bodygroup2},
    {money50,bodygroup2},
    {money50,bodygroup2},
    {money50,bodygroup2},//1400 money, 3500xp

    {money50,bodygroup3},
    {money50,bodygroup3},
    {money50,bodygroup3},
    {money50,bodygroup3},
    {money50,bodygroup3},
    {money50,bodygroup3},
    {money50,bodygroup3},//1400 money, 3500 xp

    {money100,bodygroup4},
    {money100,bodygroup4},
    {money100,bodygroup4},
    {money100,bodygroup4},
    {money100,bodygroup4},
    {money100,bodygroup4},
    {money100,bodygroup4}//2100 money, 7000xp
}// 4375 money, 15100 xp

// Missions

local bodygroup1 = {
    class = "bodygroup",
    typeItem = 1
}

local bodygroup2 = {
    class = "bodygroup",
    typeItem = 2
}

local bodygroup3 = {
    class = "bodygroup",
    typeItem = 3
}

MissionLimits = {
    day = 4,
    week = 4,
    month = 4
}

MissionCategories = {
    ["mission_category_1"] = {
        name = "Day",
        raryType = "uncommon",
        items = {
            {class = "money",money = 100}
        },
        class = "day"
    },
    ["mission_category_2"] = {
        name = "Week",
        raryType = "rary",
        items = {
            {class = "money",money = 1000}
        },
        class = "week"
    },
    ["mission_category_3"] = {
        name = "Month",
        raryType = "legendary",
        items = {
            bodygroup4,bodygroup4,{class = "money",money = 4000}// 4000xp
        },
        class = "month"
    },
    ["mission_category_4"] = {
        name = "Special",
        raryType = "epic"
    }
} //20400 xp

MissionDayItems = {bodygroup1,bodygroup1,bodygroup1,{class = "money",money = 100}}//8400 xp
MissionWeekItems = {bodygroup2,bodygroup2,bodygroup2,bodygroup2,{class = "money",money = 1000}}///8000 xp

//9130 money, 29200xp
//13505 money, 35500xp