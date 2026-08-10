local SWEP = oop.Get("wep_glock_17")
if not SWEP then return end

SWEP.IdleEmptySequenceIndex = 2
SWEP.IdleSequenceIndex = 0

SWEP.AnimationList = {
    ["deploy"] = {
        index = 3,
        indexEmpty = 4,
        delay = PISTOL_DEPLOY_TIME,
        skip = PISTOL_CAN_SKIP,
        startCycle = 0.2
    },
    ["holster"] = {
        index = 10,
        indexEmpty = 11,
        delay = PISTOL_HOLSTER_TIME,
    },

    ["fire"] = {
        index = 12,
        delay = 0.1,
    },

    ["fire_last"] = {
        index = 14,
        delay = 0.1
    },

    ["fire_empty"] = {
        index = 13,
        indexEmpty = 15,
        
        delay = 0.2,
    },

    ["unload_magazine"] = {
        index = 16,
        delay = 1,

        endCycle = 0.4,

        sound = {[0.1] = {{"weapons/eft/generic_pistol/mpx_weap_magout_plastic.ogg",75,0.4}}},

        grabLeftHand = {[0] = false},
    },
    
    ["unload_magazine_empty"] = {
        index = 25,
        delay = 0.8,

        endCycle = 0.25,

        sound = {[0.1] = {{"weapons/eft/generic_pistol/mpx_weap_magout_plastic.ogg",75,0.4}}},

        grabLeftHand = {[0] = false},
    },

    ["load_magazine"] = {
        index = 16,
        delay = 1.5,

        startCycle = 0.5,
        skip = 0.68,

        sound = {[0.7] = {{"weapons/eft/generic_pistol/mpx_weap_magin_plastic.ogg",75,0.4}}},

        grabLeftHand = {[0] = false}
    },

    ["load_magazine_chamber"] = {
        index = 24,
        delay = 1.8,

        startCycle = 0.2,
        endCycle = 1,
        skip = 0.68,

        sound = {
            [0.55] = {{"weapons/eft/generic_pistol/mpx_weap_magin_plastic.ogg",75,0.4}},
            [0.75] = {{"weapons/eft/generic_pistol/pm_slider_out.ogg",75,0.4}},
        },

        grabLeftHand = {[0] = false}
    },

    ["chamber"] = {
        index = 8,
        delay = 1,

        startCycle = 0.25,
        skip = 0.85,

        sound = {
            [0.45] = {{"weapons/eft/generic_pistol/grach_slider_in.ogg",75,0.4}},
            [0.58] = {{"weapons/eft/generic_pistol/pm_slider_out.ogg",75,0.4}},
        },

        grabLeftHand = {[0] = false},
        rejectShell = {[0.7] = true}
    },

    ["chamber_out"] = {
        index = 24,
        delay = 1,

        startCycle = 0.8,

        sound = {
            [0.71] = {{"weapons/eft/generic_pistol/grach_slider_in.ogg",75,0.4}},
            [0.79] = {{"weapons/eft/generic_pistol/pm_slider_out.ogg",75,0.4}},
        },

        grabLeftHand = {[0] = false},
        rejectShell = {[0.7] = true}
    },

    ["inspect"] = {
        index = 41,
        delay = 3,
    }
}

SWEP.AnimationInspectList = {
    "inspect"
}