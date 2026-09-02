local SWEP = oop.Get("wep_saiga12k")
if not SWEP then return end

SWEP.AnimationList = {
    ["deploy"] = {
        index = 3,
        delay = RIFLE_DEPLOY_TIME,
        skip = RIFLE_CAN_SKIP,
        startCycle = 0.15,
    },
    ["holster"] = {
        index = 8,
        delay = RIFLE_HOLSTER_TIME,
        startCycle = 0.1
    },

    ["fire"] = {
        index = 9,
        delay = 0.1
    },

    ["fire_empty"] = {
        index = 10,
        delay = 0.1
    },
    
    ["load_magazine"] = {
        index = 11,
        delay = RIFLE_LOAD_TIME,
        skip = RIFLE_LOAD_SKIP,
        load = 0.5,

        startCycle = 0.5,
        
        sound = {[0.8] = {{"arc9_eft_shared/weap_magin_plastic.ogg",75,0.4}}},

        grabLeftHand = {[0] = false},
    },

    ["unload_magazine"] = {
        index = 11,
        delay = RIFLE_UNLOAD_TIME,
        skip = RIFLE_UNLOAD_SKIP,
        load = 0.4,

        endCycle = 0.5,

        sound = {[0.2] = {{"arc9_eft_shared/weap_magout_plastic.ogg",75,0.4}}},

        grabLeftHand = {[0] = false}
    },

    ["chamber"] = {
        index = 6,
        delay = 1,

        startCycle = 0.25,
        skip = 0.8,

        sound = {
            [0.45] = {{"weapons/eft/ak/saiga_slider_up.ogg",75,0.6}},
            [0.58] = {{"weapons/eft/ak/saiga_slider_down.ogg",75,0.6}},
        },

        rejectShell = {[0.35] = true},
    }
}

SWEP.AnimationInspectList = {}