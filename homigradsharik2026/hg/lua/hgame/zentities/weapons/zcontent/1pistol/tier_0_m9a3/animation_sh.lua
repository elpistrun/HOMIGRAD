local SWEP = oop.Get("wep_m9a3")
if not SWEP then return end

SWEP.IdleEmptySequenceIndex = 1

SWEP.AnimationList = {
    ["deploy"] = {
        index = 2,
        indexEmpty = 3,
        delay = PISTOL_DEPLOY_TIME,
        skip = PISTOL_CAN_SKIP,
        startCycle = 0.2,
    },
    ["holster"] = {
        index = 9,
        indexEmpty = 10,
        delay = PISTOL_HOLSTER_TIME,
    },

    ["fire"] = {
        index = 11,
        delay = 0.1,
    },

    ["fire_last"] = {
        index = 13,
        delay = 0.1,
    },

    ["fire_empty"] = {
        index = 12,
        indexEmpty = 14,
        delay = 0.4,
    },

    ["unload_magazine"] = {
        index = 15,
        indexEmpty = 19,
        delay = 1.5,
        startCycle = 0.3,
        skip = 0.65,

        inversion = true,

        sound = {[0.25] = {{"weapons/eft/generic_pistol/mpx_weap_magout_plastic.ogg",75,0.4}}},

        grabLeftHand = {[0] = false},
        magazineDraw = {[0] = true,[0.7] = false},
    },
    
    ["load_magazine"] = {
        index = 15,
        indexEmpty = 19,
        delay = 1.5,
        startCycle = 0.5,
        skip = 0.75,

        sound = {[0.7] = {{"weapons/eft/generic_pistol/mpx_weap_magin_plastic.ogg",75,0.4}}},

        grabLeftHand = {[0] = false}
    },

    ["load_magazine_chamber"] = {
        index = 19,
        delay = 1.8,

        startCycle = 0.2,
        endCycle = 1,

        sound = {
            [0.55] = {{"weapons/eft/generic_pistol/mpx_weap_magin_plastic.ogg",75,0.4}},
            [0.85] = {{"weapons/eft/generic_pistol/pm_slider_out.ogg",75,0.4}},
        },

        grabLeftHand = {[0] = false}
    },

    ["chamber"] = {
        index = 29,
        delay = 1,

        startCycle = 0.6,

        sound = {
            [0.71] = {{"weapons/eft/generic_pistol/grach_slider_in.ogg",75,0.4}},
            [0.79] = {{"weapons/eft/generic_pistol/pm_slider_out.ogg",75,0.4}},
        },

        grabLeftHand = {[0] = false},
        rejectShell = {[0.7] = true}
    },

    ["chamber_out"] = {
        index = 19,
        delay = 0.8,

        startCycle = 0.65,

        sound = {
            [0.71] = {{"weapons/eft/generic_pistol/grach_slider_in.ogg",75,0.4}},
            [0.79] = {{"weapons/eft/generic_pistol/pm_slider_out.ogg",75,0.4}},
        },

        grabLeftHand = {[0] = false},
        rejectShell = {[0.7] = true}
    },

    ["inspect"] = {
        index = 30,
        indexEmpty = 31,
        delay = 3,
    }
}

SWEP.AnimationInspectList = {
    "inspect"
}