local SWEP = oop.Get("wep_mp5")
if not SWEP then return end

SWEP.AnimationList = {
    ["deploy"] = {
        index = 18,
        delay = PISTOLRIFLE_DEPLOY_TIME,
        skip = PISTOLRIFLE_DEPLOY_SKIP,

        startCycle = 0.25,
    },
    ["holster"] = {
        index = 11,
        delay = PISTOLRIFLE_HOLSTER_TIME,
        startCycle = 0.1,
    },

    ["fire"] = {
        index = 9,
        delay = 0.1,

        noFight = true--tag
    },

    ["fire_empty"] = {
        index = 10,
        delay = 0.1,

        noFight = true
    },

    ["load_magazine"] = {
        index = 20,
        delay = PISTOLRIFLE_LOAD_TIME,
        skip = 0.8,

        startCycle = 0.4,
        endCycle = 1,

        sound = {[0.7] = {{"weapons/eft/mp5/mp5_weap_mag_in.ogg",75,0.4}}},

        grabLeftHand = {[0] = false}
    },

    ["unload_magazine"] = {
        index = 20,
        delay = PISTOLRIFLE_UNLOAD_TIME,
        skip = 0.76,
        load = 0.5,

        startCycle = 0.4,

        inversion = true,

        sound = {[0.2] = {{"weapons/eft/mp5/mp5_weap_mag_out.ogg",75,0.4}}},

        grabLeftHand = {[0] = false},

        skip = 0.9
    },

    ["chamber"] = {
        index = 19,
        delay = RIFLE_CHAMBER,
        
        startCycle = 0.25,

        sound = {
            [0.35] = {{"weapons/eft/mp5/mp5_weap_bolt_out.ogg",75,0.4}},
            [0.5] = {{"weapons/eft/mp5/mp5_weap_bolt_in.ogg",75,0.4}},
        },

        grabLeftHand = {[0] = false},
        rejectShell = {[0.4] = true},
    },

    ["inspect"] = {
        index = 16,
        delay = 3
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