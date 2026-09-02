local SWEP = oop.Get("wep_ar15")
if not SWEP then return end

SWEP.IdleEmptySequenceIndex = 2

SWEP.AnimationList = {
    ["deploy"] = {
        index = 3,
        indexEmpty = 4,
        delay = RIFLE_DEPLOY_TIME,
        skip = RIFLE_DEPLOY_SKIP,
        startCycle = 0.25,

        deploy = true,--tag
    },
    ["holster"] = {
        index = 8,
        indexEmpty = 9,
        delay = RIFLE_HOLSTER_TIME,
        startCycle = 0.1,

        endless = true,
        holster = true--tag
    },

    ["fire"] = {
        index = 10,
        delay = 0.1,
        noFight = true--tag
    },

    ["fire_last"] = {
        index = 11,
        delay = 0.1,
        noFight = true
    },

    ["fire_empty"] = {
        index = 12,
        indexEmpty = 13,
        delay = 0.1,

        noFight = true
    },

    ["unload_magazine"] = {
        index = 15,
        delay = RIFLE_UNLOAD_TIME,
        skip = RIFLE_UNLOAD_SKIP + 0.2,
        load = 0.6,
        startCycle = 0.45,
        endCycle = 1,

        inversion = true,

        sound = {[0.25] = {{{"weapons/eft/m4a1/mcx_mag_out1.ogg","weapons/eft/m4a1/mcx_mag_out2.ogg","weapons/eft/m4a1/mcx_mag_out3.ogg"},75,0.6}}},

        grabLeftHand = {[0] = false},
        magazineDraw = {[0] = true,[0.8] = false},
    },
    
    ["load_magazine"] = {
        index = 15,
        indexEmpty = 17,
        delay = RIFLE_LOAD_TIME,
        skip = RIFLE_LOAD_SKIP,
        load = 0.6,
        startCycle = 0.5,
        endCycle = 1,

        sound = {[0.75] = {{{"weapons/eft/m4a1/mcx_mag_in1.ogg","weapons/eft/m4a1/mcx_mag_in2.ogg","weapons/eft/m4a1/mcx_mag_in3.ogg"},75,0.4}}},

        grabLeftHand = {[0] = false},
    },

    ["load_magazine_chamber"] = {
        index = 17,
        delay = 1.8,
        startCycle = 0.3,
        skip = 0.8,

        sound = {
            [0.5] = {{{"weapons/eft/m4a1/mcx_mag_in1.ogg","weapons/eft/m4a1/mcx_mag_in2.ogg","weapons/eft/m4a1/mcx_mag_in3.ogg"},75,0.4}},
            [0.8] = {{"weapons/eft/m4a1/mcx_bolt_catchrelease.ogg",75,0.4}}
        },

        grabLeftHand = {[0] = false},
        skip = 0.9
    },

    ["chamber"] = {
        index = 51,
        delay = 1,

        startCycle = 0.3,
        endCycle = 1,

        sound = {
            [0.45] = {{"weapons/eft/m4a1/mcx_bolt_out.ogg",75,0.4}},
            [0.68] = {{"weapons/eft/m4a1/mcx_bolt_in.ogg",75,0.4}},
        },

        grabLeftHand = {[0] = false},
        rejectShell = {[0.6] = true},

        canScope = true
    },

    ["chamber_out"] = {
        index = 51,
        delay = 1,

        startCycle = 0.3,
        endCycle = 1,

        sound = {
            [0.45] = {{"weapons/eft/m4a1/mcx_bolt_out.ogg",75,0.4}},
            [0.68] = {{"weapons/eft/m4a1/mcx_bolt_in.ogg",75,0.4}},
        },

        grabLeftHand = {[0] = false},
        rejectShell = {[0.6] = true},

        canScope = true
    },

    ["inspect1"] = {
        index = 58,
        indexEmpty = 59,
        delay = 3,

        noFight = true,
        dontShake = true
    },
    ["inspect2"] = {
        index = 60,
        indexEmpty = 61,
        delay = 3,

        noFight = true,
        dontShake = true
    },
}

SWEP.AnimationInspectList = {
    "inspect1","inspect2"
}