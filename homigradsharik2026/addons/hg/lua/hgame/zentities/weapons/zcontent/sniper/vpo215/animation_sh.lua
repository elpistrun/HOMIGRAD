local SWEP = oop.Get("wep_vpo215")
if not SWEP then return end

SWEP.AnimationList = {
    ["deploy"] = {
        index = 4,
        delay = RIFLE_DEPLOY_TIME,
        skip = RIFLE_DEPLOY_SKIP,
        startCycle = 0.15,

        grabLeftHand = {[0] = false}
    },
    ["holster"] = {
        index = 9,
        delay = RIFLE_HOLSTER_TIME,
        startCycle = 0.1,
    },

    ["fire"] = {
        index = 11,
        delay = 0.1,
    },

    ["fire_empty"] = {
        index = 11,
        delay = 0.1,
    },

    ["unload_magazine"] = {
        index = 17,
        delay = 0.9,
        startCycle = 0.5,

        inversion = true,

        sound = {[0.15] = {{"weapons/eft/dvl10/dvl_mag_out.ogg",75,0.4}}},

        grabLeftHand = {[0] = false},
    },
    
    ["load_magazine"] = {
        index = 17,
        delay = 0.9,

        startCycle = 0.5,
        endCycle = 1,

        sound = {[0.8] = {{"weapons/eft/dvl10/dvl_mag_in.ogg",75,0.4}}},

        grabLeftHand = {[0] = false},
        magazineDraw = {[0] = false,[0.2] = true}
    },

    ["chamber"] = {
        index = 15,
        delay = 1.12,
        load = 0.75,
        skip = 0.75,

        sound = {
            [0.3] = {{"weapons/eft/dvl10/dvl_bolt_1.ogg",75,0.4}},
            [0.4] = {{"weapons/eft/dvl10/dvl_bolt_2.ogg",75,0.4}},
            [0.5] = {{"weapons/eft/dvl10/dvl_bolt_3.ogg",75,0.4}},
            [0.6] = {{"weapons/eft/dvl10/dvl_bolt_4.ogg",75,0.4}},
        },

        grabLeftHand = {[0] = false},
        rejectShell = {[0.4] = true},
    },

    ["inspect"] = {
        index = 25,
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

    wmAngle[1] = wmAngle[1] - recoil * Lerp(self.scopeLerp,self.recoilAngUp,self.recoilAngUp_Scope)

    wmAngle[2] = wmAngle[2] + math.cos(CurTime() * 4) * recoil * abs + (not RenderCamera and math.ease.InBounce(recoil) * abs or 0)
end