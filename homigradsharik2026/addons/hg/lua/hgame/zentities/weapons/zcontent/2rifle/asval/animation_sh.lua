local SWEP = oop.Get("wep_asval")
if not SWEP then return end

SWEP.AnimationList = {
    ["deploy"] = {
        index = 2,
        delay = RIFLE_DEPLOY_TIME,
        skip = RIFLE_DEPLOY_SKIP,
        startCycle = 0.2,
        endCycle = 1,
        skip = 0.7,
    },
    ["holster"] = {
        index = 7,
        delay = RIFLE_HOLSTER_TIME,
        startCycle = 0.1,
    },

    ["fire"] = {
        index = 8,
        delay = 0.1,
    },

    ["fire_empty"] = {
        index = 9,
        delay = 0.1,
    },

    ["unload_magazine"] = {
        index = 10,
        delay = RIFLE_UNLOAD_TIME,
        skip = RIFLE_UNLOAD_SKIP + 0.2,
        load = 0.5,

        startCycle = 0.35,
        endCycle = 0.88,

        inversion = true,

        sound = {[0.3] = {{{"weapons/eft/m4a1/mcx_mag_out1.ogg","weapons/eft/m4a1/mcx_mag_out2.ogg","weapons/eft/m4a1/mcx_mag_out3.ogg"},75,0.6}}},

        grabLeftHand = {[0] = false},
        magazineDraw = {[0] = true}
    },
    
    ["load_magazine"] = {
        index = 10,
        delay = RIFLE_LOAD_TIME - 0.2,
        skip = RIFLE_LOAD_SKIP,
        load = 0.6,

        startCycle = 0.39,
        endCycle = 1,

        sound = {[0.75] = {{{"weapons/eft/m4a1/mcx_mag_in1.ogg","weapons/eft/m4a1/mcx_mag_in2.ogg","weapons/eft/m4a1/mcx_mag_in3.ogg"},75,0.4}}},

        grabLeftHand = {[0] = false},
        magazineDraw = {[0] = false,[0.25] = true},
    },

    ["chamber"] = {
        index = 17,
        delay = 1,

        startCycle = 0.6,
        endCycle = 1,

        sound = {
            [0.73] = {{"weapons/eft/m4a1/mcx_bolt_out.ogg",75,0.4}},
            [0.78] = {{"weapons/eft/m4a1/mcx_bolt_in.ogg",75,0.4}},
        },

        grabLeftHand = {[0] = false},
        rejectShell = {[0.8] = true},
    },

    ["inspect1"] = {
        index = 25,
        delay = 3,
    },
    ["inspect2"] = {
        index = 26,
        delay = 3
    },

    ["checkmagazine"] = {
        index = 27,
        delay = 4
    }
}

SWEP.AnimationInspectList = {
    "inspect1","inspect2"
}