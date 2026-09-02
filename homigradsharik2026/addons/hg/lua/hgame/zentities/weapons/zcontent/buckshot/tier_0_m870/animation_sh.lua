local SWEP = oop.Get("wep_m870")
if not SWEP then return end

SWEP.AnimationList = {
    ["deploy"] = {
        index = 7,
        delay = RIFLE_DEPLOY_TIME,
        startCycle = 0.15,
        endCycle = 1,
        skip = RIFLE_DEPLOY_SKIP,
    },
    ["holster"] = {
        index = 4,
        delay = 0.5,
        startCycle = 0.1
    },

    ["fire"] = {
        index = 10,
        delay = 0.1
    },

    ["fire_empty"] = {
        index = 10,
        delay = 0.1
    },

    ["pomp_insert"] = {
        index = 26,
        delay = 1.0,
        load = 0.9,

        sound = {[0.8] = {{"weapons/eft/m870/pump_jam_shell_out1.ogg",75,0.4}}},

        grabLeftHand = {[0] = false},
    },

    ["pomp_insert_end"] = {
        index = 28,
        delay = 0.3,
        
        grabLeftHand = {[0] = false},
    },

    ["pomp_unload"] = {
        index = 26,
        delay = 0.5,
        inversion = true,

        sound = {[0.5] = {{"weapons/eft/m870/pump_jam_shell_out1.ogg",75,0.4}}},

        grabLeftHand = {[0] = false},
    },

    ["chamber"] = {
        index = 15,
        delay = 0.7,

        startCycle = 0.1,
        endCycle = 0.7,

        sound = {
            [0.3] = {{"weapons/eft/m870/rem870_pump_in.ogg",75,0.6}},
            [0.35] = {{"weapons/eft/m870/rem870_pump_out.ogg",75,0.6}},
        },

        rejectShell = {[0.35] = true},
        
        GraphVectorWM = {
            {0,Vector()},
            {0.08,Vector(0,0,3)},
            {0.4,Vector(1,0,3)},
            {1,Vector()}
        },

        GraphRotateWM = {
            {0,Angle()},
            {0.08,Angle(-17,0,0)},
            {0.5,Angle(-25,0,10)},
            {1,Angle()}
        },
    },

    ["inspect"] = {
        index = 5,
        delay = 3
    }
}

SWEP.AnimationInspectList = {
    "inspect"
}