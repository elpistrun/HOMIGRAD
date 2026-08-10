local SWEP = oop.Get("wep_vector9")
if not SWEP then return end

SWEP.IdleEmptySequenceIndex = 2

SWEP.AnimationList = {
    ["deploy"] = {
        index = 33,
        indexEmpty = 37,
        delay = PISTOLRIFLE_DEPLOY_TIME,
        skip = PISTOLRIFLE_DEPLOY_SKIP,

        startCycle = 0.25,
    },
    ["holster"] = {
        index = 23,
        indexEmpty = 24,

        delay = PISTOLRIFLE_HOLSTER_TIME,
        startCycle = 0.1,
    },

    ["fire"] = {
        index = 19,
        delay = 0.1,
    },

    ["fire_empty"] = {
        index = 21,
        delay = 0.1,
    },

    ["load_magazine"] = {
        index = 40,
        delay = PISTOLRIFLE_LOAD_TIME,
        load = 0.7,
        skip = 0.8,

        startCycle = 0.55,
        endCycle = 1,

        sound = {[0.7] = {{"weapons/eft/vector/vector_mag_in.ogg",75,0.4}}},

        grabLeftHand = {[0] = false}
    },

    ["load_magazine_chamber"] = {
        index = 52,
        delay = PISTOLRIFLE_LOAD_TIME + RIFLE_CHAMBER * 0.55,

        startCycle = 0.3,
        skip = 0.9,

        sound = {
            [0.6] = {{"weapons/eft/vector/vector_mag_in.ogg",75,0.4}},
            [0.8] = {{"weapons/eft/vector/vector_bolt_in.ogg",75,0.4}}
        },

        grabLeftHand = {[0] = false}
    },

    ["unload_magazine"] = {
        index = 40,
        delay = PISTOLRIFLE_UNLOAD_TIME,
        load = 0.5,
        skip = 0.7,

        startCycle = 0.45,

        inversion = true,

        sound = {[0.2] = {{"weapons/eft/vector/vector_mag_out.ogg",75,0.4}}},

        grabLeftHand = {[0] = false},

        skip = 0.9
    },

    ["inspect"] = {
        index = 29,
        indexEmpty = 30,
        delay = 3,

        noFight = true,
        dontShake = true
    },

    ["chamber"] = {
        index = 36,
        delay = RIFLE_CHAMBER,
        skip = 0.7,

        startCycle = 0.15,
        endCycle = 0.8,

        sound = {
            [0.4] = {{"weapons/eft/vector/vector_bolt_out.ogg",75,0.4}},
            [0.55] = {{"weapons/eft/vector/vector_bolt_in.ogg",75,0.4}},
        },

        rejectShell = {
            [0.45] = true
        }
    }
}

SWEP.AnimationInspectList = {
    "inspect"
}

function SWEP:DoAnimationRecoil(wmAngle)
    local recoil = self.recoil
    local scopeLerp = self.scopeLerp
    local abs = self.recoilRandAbs

    wmAngle[1] = wmAngle[1] - recoil / 3
    wmAngle[2] = wmAngle[2] + math.cos(RealTime() * 12) / 3 * recoil + recoil * abs / 10
end