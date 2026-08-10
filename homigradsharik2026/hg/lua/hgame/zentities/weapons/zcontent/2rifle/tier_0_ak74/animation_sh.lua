local SWEP = oop.Get("wep_ak74")
if not SWEP then return end

SWEP.AnimationList = {
    ["deploy"] = {
        index = 5,
        delay = RIFLE_DEPLOY_TIME,
        skip = RIFLE_DEPLOY_SKIP,
        startCycle = 0.25,
    },
    ["holster"] = {
        index = 5,
        delay = RIFLE_HOLSTER_TIME,
        startCycle = 0.1,

        inversion = true,
    },

    ["fire"] = {
        index = 10,
        delay = 0.1,
    },

    ["fire_empty"] = {
        index = 11,
        delay = 0.1,
    },

    ["unload_magazine"] = {
        index = 20,
        delay = RIFLE_UNLOAD_TIME,
        skip = RIFLE_UNLOAD_SKIP,
        load = 0.4,

        startCycle = 0.1,
        endCycle = 0.6,

        inversion = true,

        sound = {[0.5] = {{"weapons/eft/ak/ak74_magout_plastic.ogg",75,0.4}}},

        grabLeftHand = {[0] = false,[0.9] = true},
        magazineDraw = {[0] = true,[0.7] = false},
    },
    
    ["load_magazine"] = {
        index = 18,
        delay = RIFLE_LOAD_TIME,
        skip = RIFLE_LOAD_SKIP,
        load = 0.6,
        startCycle = 0.5,

        sound = {[0.7] = {{"weapons/eft/ak/ak74_magin_plastic.ogg",75,0.4}}},

        grabLeftHand = {[0] = false,[0.9] = true},
        magazineDraw = {[0] = false,[0.1] = true}
    },

    ["chamber"] = {
        index = 20,
        delay = RIFLE_CHAMBER,

        startCycle = 0.65,
        endCycle = 1,

        sound = {
            [0.8] = {{"weapons/eft/ak/ak74_slider_up.ogg",75,0.4}},
            [0.9] = {{"weapons/eft/ak/ak74_slider_down.ogg",75,0.4}},
        },

        grabRightHand = {[0] = false},
        rejectShell = {[0.8] = true},
    },

    ["inspect"] = {
        index = 50,
        delay = 3,
    }
}

SWEP.AnimationInspectList = {
    "inspect"
}

function SWEP:DoAnimationRecoil(wmAngle)
    local recoil = self.recoil
    local scopeLerp = self.scopeLerp
    local abs = self.recoilRandAbs

    wmAngle[2] = wmAngle[2] - math.cos(CurTime() * 4) / 100
end