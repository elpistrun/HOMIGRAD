DonatCraftList = DonatCraftList or {}

DonatCraftList["bodygroup1_to_5"] = {
    category = "Аксесуары",
    name = "Bodygroup 1 to 5",
    input = {
        {class = "bodygroup",type = "1",count = 10}
    },
    output = {
        {class = "bodygroup",type = "2",count = 2}
    }
}

DonatCraftList["bodygroup2_to_10"] = {
    category = "Аксесуары",
    name = "Bodygroup 5 to 10",
    input = {
        {class = "bodygroup",type = "2",count = 4}
    },
    output = {
        {class = "bodygroup",type = "3",count = 2},
    }
}

DonatCraftList["bodygroup3_to_100"] = {
    category = "Аксесуары",
    name = "Bodygroup 10 to 100",
    input = {
        {class = "bodygroup",type = "3",count = 10},
    },
    output = {
        {class = "bodygroup",type = "4"},
    }
}

DonatCraftList["bodygroup4_to_money"] = {
    category = "Аксесуары",
    name = "Bodygroup 100 to 300 money",
    input = {
        {class = "bodygroup",type = "4",count = 1},
    },
    output = {
        {class = "money",money = 300},
    }
}

DonatCraftList["mlg_to_mlg_danger"] = {
    category = "Аксесуары",
    name = "10 MLG to MLG DANGER",
    input = {
        {class = "case",type = "mlg"},
        {class = "case",type = "mlg"},
        {class = "case",type = "mlg"},
        {class = "case",type = "mlg"},
        {class = "case",type = "mlg"},
        {class = "case",type = "mlg"},
        {class = "case",type = "mlg"},
        {class = "case",type = "mlg"},
        {class = "case",type = "mlg"},
        {class = "case",type = "mlg"},
    },
    output = {
        {class = "case",type = "mlg_danger"},
    }
}

DonatCraftList["key_fun_to_anime"] = {
    category = "Ключи",
    name = "Key Fun Models > Key Anime Models",
    input = {
        {class = "case_key",type = "mlg"},
        {class = "case_key",type = "mlg"},
        {class = "case_key",type = "mlg"},

        {class = "bodygroup",type = "3",count = 1},
        {class = "bodygroup",type = "4",count = 20},

        {class = "receiver"},
        {class = "receiver"},
        {class = "receiver"},
    },
    output = {
        {class = "case_key",type = "anime"},
    }
}

DonatCraftList["key_fun_to_anime2"] = {
    category = "Ключи",
    name = "Key MLG > Key Anime Models 2",
    input = {
        {class = "case_key",type = "mlg"},
        {class = "case_key",type = "mlg"},
        {class = "case_key",type = "mlg"},

        {class = "bodygroup",type = "3",count = 1},
        {class = "bodygroup",type = "4",count = 20},

        {class = "receiver"},
        {class = "receiver"},
        {class = "receiver"},
    },
    output = {
        {class = "case_key",type = "anime2"},
    }
}

/*DonatCraftList["combat_pass"] = {
    category = "Ключи",
    name = "ZOMBIE SURVIVAL PASS",
    input = {
        {class = "item",item = "sent_she_sleep"},
        {class = "item",item = "sent_she_fire"},
        {class = "item",item = "sent_she_sleep"},
        {class = "item",item = "sent_she_fire"},

        {class = "bodygroup",type = "4",count = 1},
    },
    output = {
        {class = "combat_pass"},
        {class = "combat_pass"},
    }
}*/

/*
DonatCraftList["halflife_pass"] = {
    category = "Ключи",
    name = "HALFLIFE 2 COOP PASS",
    input = {
        {class = "item",item = "sent_she_tick"},
        {class = "item",item = "sent_she_fire"},
        {class = "item",item = "sent_she_sleep"},
        
        {class = "bodygroup",type = "4",count = 1},
        {class = "bodygroup",type = "3",count = 5}
    },
    output = {
        {class = "halflife_pass"},
        {class = "halflife_pass"},
    }
}
*/