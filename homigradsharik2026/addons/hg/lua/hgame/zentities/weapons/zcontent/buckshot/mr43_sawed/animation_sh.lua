local SWEP = oop.Get("wep_mr43_sawed")
if not SWEP then return end

SWEP.AnimationList = {
    ["deploy"] = {
        index = 1,
        skip = RIFLE_DEPLOY_SKIP,
        delay = RIFLE_DEPLOY_TIME,
        startCycle = 0.15,
        endCycle = 1,
    },
    ["holster"] = {
        index = 3,
        delay = RIFLE_HOLSTER_TIME,
        startCycle = 0.1
    },

    ["fire"] = {
        index = 5,
        delay = 0.1
    },

    ["fire_empty"] = {
        index = 5,
        delay = 0.1
    },

    ["mr43_reload1"] = {
        index = 6,
        delay = 2.5,

        grabLeftHand = {[0] = false},

        rejectShell1 = 0.25,

        sound = {
            [0.12] = {{"weapons/eft/mr43/mr43_barrels_open.ogg",75,0.4}},
            [0.25] = {{"weapons/eft/mr43/mr43_ammo_unload_single1.ogg",75,0.4}},
            [0.5] = {{"weapons/eft/mr43/mr43_ammo_load_single1.ogg",75,0.4}},
            [0.82] = {{"weapons/eft/mr43/mr43_barrels_close.ogg",75,0.4}}
        }
    },

    ["mr43_reload2"] = {
        index = 7,
        delay = 3,

        grabLeftHand = {[0] = false},

        rejectShell1 = 0.25,
        rejectShell2 = 0.25,

        sound = {
            [0.12] = {{"weapons/eft/mr43/mr43_barrels_open.ogg",75,0.4}},
            [0.25] = {{"weapons/eft/mr43/mr43_ammo_unload_double.ogg",75,0.4}},
            [0.5] = {{"weapons/eft/mr43/mr43_ammo_load_double.ogg",75,0.4}},
            [0.82] = {{"weapons/eft/mr43/mr43_barrels_close.ogg",75,0.4}}
        }
    },

    ["inspect"] = {
        index = 10,
        delay = 3
    }
}

SWEP.AnimationInspectList = {
    "inspect"
}
