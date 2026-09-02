local SWEP = oop.Get("wep_mp9")
if not SWEP then return end

SWEP.IdleEmptySequenceIndex = 2

SWEP.AnimationList = {
    ["deploy"] = {
        index = 34,
        indexEmpty = 38,
        delay = PISTOLRIFLE_DEPLOY_TIME,

        startCycle = 0.25
    },
    ["holster"] = {
        index = 24,
        indexEmpty = 25,
        delay = PISTOLRIFLE_HOLSTER_TIME,
        startCycle = 0.1,
    },

    ["fire"] = {
        index = 21,
        delay = 0.1,
    },

    ["fire_last"] = {
        index = 23,
        delay = 0.1
    },

    ["fire_empty"] = {
        index = 22,
        delay = 0.1,
    },

    ["load_magazine"] = {
        index = 39,
        delay = PISTOLRIFLE_LOAD_TIME,
        load = 0.7,

        startCycle = 0.4,
        endCycle = 1,

        sound = {[0.7] = {{"weapons/eft/mp5/mp5_weap_mag_in.ogg",75,0.4}}},

        grabLeftHand = {[0] = false}
    },

    ["load_magazine_chamber"] = {
        index = 47,
        delay = PISTOLRIFLE_LOAD_TIME,

        startCycle = 0.28,
        endCycle = 0.82,

        sound = {
            [0.45] = {{"weapons/eft/mp5/mp5_weap_mag_in.ogg",75,0.4}},
            [0.8] = {{"weapons/eft/mp5/mp5_weap_bolt_in_slap.ogg",75,0.4}}
        },

        grabLeftHand = {[0] = false}
    },

    ["unload_magazine"] = {
        index = 39,
        delay = PISTOLRIFLE_UNLOAD_TIME,
        --load = 0.4,
        
        startCycle = 0.5,

        inversion = true,

        sound = {[0.2] = {{"weapons/eft/mp5/mp5_weap_mag_out.ogg",75,0.4}}},

        grabLeftHand = {[0] = false},

        skip = 0.5
    },

    ["inspect"] = {
        index = 30,
        indexEmpty = 31,
        delay = 3,

        noFight = true,
        dontShake = true
    },

    ["chamber"] = {
        index = 36,
        delay = RIFLE_CHAMBER,
        skip = 0.7,

        startCycle = 0.3,

        sound = {
            [0.4] = {{"weapons/eft/mp9/mp7_bolt_na_tebya.ogg",75,0.4}},
            [0.55] = {{"weapons/eft/mp9/mp7_bolt_ot_tebya.ogg",75,0.4}},
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