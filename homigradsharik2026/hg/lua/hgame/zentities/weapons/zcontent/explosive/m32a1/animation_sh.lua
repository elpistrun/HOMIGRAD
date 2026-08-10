local SWEP = oop.Get("wep_m32a1")
if not SWEP then return end

SWEP.AnimationList = {
    ["deploy"] = {
        index = 7,
        delay = PISTOL_DEPLOY_TIME,
        skip = PISTOL_CAN_SKIP,
        startCycle = 0.27,
    },
    ["holster"] = {
        index = 19,
        delay = PISTOL_HOLSTER_TIME
    },

    ["fire"] = {
        index = 25,
        delay = 0.2,

        inversion = true,
        add = -2
    },

    ["fire_empty"] = {
        index = 25,
        delay = 0.2,

        inversion = true,
        add = -2,

        --sound = {[0] = {{"weapons/eft/m32/mgl_drum_rotate1.ogg","weapons/eft/m32/mgl_drum_rotate2.ogg","weapons/eft/m32/mgl_drum_rotate3.ogg","weapons/eft/m32/mgl_drum_rotate4.ogg"},75,0.4}}
    },

    ["rev_inspect"] = {
        index = 45,
        limit = 4,
        delay = 3,
    },

    ["rev_uninsert"] = {
        index = 81,
        delay = 1,

        soundUnInsert = {{"weapons/eft/rsh12/rsh_12_ammo_out.ogg",75,0.4}},

        sound = {[0] = {{"weapons/eft/rsh12/rsh_12_reload_start.ogg",75,0.4}}},
        
        limit = 0,

        grabLeftHand = {[0] = false}
    },

    ["drum_open"] = {
        index = 44,
        delay = 1,
        startCycle = 0.3,
        sound = {[0] = {{"weapons/eft/rsh12/rsh_12_reload_start.ogg",75,0.4}}},
        limit = 0,

        grabLeftHand = {[0] = false}
    },

    ["drum_end"] = {
        index = 44,
        delay = 0.8,
        skip = 0.5,
        
        startCycle = 0.3,
        sound = {[0] = {{"weapons/eft/rsh12/rsh_12_reload_end.ogg",75,0.4}}},
        limit = 0,
        inversion = true,

        grabLeftHand = {[0] = false}
    },

    ["rev_unload"] = {
        index = 87,
        delay = 1.8,
        endCycle = 0.7,
        sound = {
            [0] = {{"weapons/eft/rsh12/rsh_12_reload_end.ogg",75,0.4}},
            [0.45] = {{"weapons/eft/rsh12/rsh_12_purge_shells.ogg",75,0.4}}
        },
        rejectShell = 0.45,

        grabLeftHand = {[0] = false}
    },

    ["rev_insert"] = {
        index = 45,
        delay = 0.8,

        sound = {
            [0.8] = {{"weapons/eft/rsh12/rsh_12_ammo_in.ogg",75,0.4}}
        },

        limit = 0,

        grabLeftHand = {[0] = false}
    }
}

SWEP.AnimationInspectList = {
    "inspect"
}

function SWEP:DoAnimationRecoil(wmAngle)
    local recoil = self.recoil
    local scopeLerp = self.scopeLerp
    local abs = self.recoilRandAbs

    wmAngle[1] = wmAngle[1] - recoil * 15 + 6 * math.ease.InBounce(1.5 * recoil)
    wmAngle[2] = wmAngle[2] + 6 * (math.max(recoil - 0.4,0) / 0.6) - 3 * math.ease.InBounce(1.5 * recoil)
end