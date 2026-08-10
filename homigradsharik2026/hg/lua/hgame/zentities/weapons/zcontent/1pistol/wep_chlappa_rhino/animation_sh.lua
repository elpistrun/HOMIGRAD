local SWEP = oop.Get("wep_chiappa_rhino")
if not SWEP then return end

SWEP.AnimationList = {
    ["deploy"] = {
        index = 8,
        delay = PISTOL_DEPLOY_TIME,
        skip = PISTOL_CAN_SKIP,
        startCycle = 0.27,
    },
    ["holster"] = {
        index = 20,
        delay = PISTOL_HOLSTER_TIME
    },

    ["fire"] = {
        index = 32,
        delay = 0.2,

        inversion = true,
        add = -2
    },

    ["fire_empty"] = {
        index = 50,
        delay = 0.2,

        inversion = true,
        add = -2,
    },

    ["inspect"] = {
        index = 56,
        limit = 4,
        delay = 3,
    },

    ["rev_uninsert"] = {
        index = 75,
        delay = 1,

        soundUnInsert = {{{"weapons/eft/rhino/rhino_round_out1.ogg","weapons/eft/rhino/rhino_round_out2.ogg","weapons/eft/rhino/rhino_round_out3.ogg"},75,0.4}},

        limit = 0,
        
        grabLeftHand = {[0] = false}
    },

    ["drum_open"] = {
        index = 68,
        delay = 1,
        startCycle = 0.3,
        sound = {[0] = {{"weapons/eft/rhino/rhino_drum_out.ogg",75,0.4}}},
        limit = 0,
        inversion = true,

        grabLeftHand = {[0] = false}
    },

    ["drum_end"] = {
        index = 68,
        delay = 0.8,
        skip = 0.5,
        
        startCycle = 0.3,
        sound = {[0] = {{"weapons/eft/rhino/rhino_drum_in.ogg",75,0.4}}},
        limit = 0,

        grabLeftHand = {[0] = false}
    },

    ["rev_unload"] = {
        index = 183,
        delay = 1.6,
        sound = {
            [0] = {{"weapons/eft/rsh12/rsh_12_reload_end.ogg",75,0.4}},
            [0.45] = {{"weapons/eft/rhino/rhino_drum_purge_all.ogg",75,0.4}}
        },
        rejectShell = 0.45,

        grabLeftHand = {[0] = false}
    },

    ["rev_insert"] = {
        index = 177,
        delay = 0.6,

        sound = {
            [0.8] = {{{"weapons/eft/rhino/rhino_round_in1.ogg","weapons/eft/rhino/rhino_round_in2.ogg","weapons/eft/rhino/rhino_round_in3.ogg"},75,0.4}}
        },

        limit = 0,

        grabLeftHand = {[0] = false}
    }
}

SWEP.AnimationInspectList = {
    "inspect"
}

function SWEP:DoAnimationRecoil(wmAngle,wmVector)
    local recoil = self.recoil
    local scopeLerp = self.scopeLerp
    local abs = self.recoilRandAbs

    wmAngle[1] = wmAngle[1] - math.max(recoil - 0.2,0) / 0.8 * 45 + math.ease.InBounce(recoil) * 15 + math.sin(CurTime() * 3) * recoil * 2
    wmAngle[1] = wmAngle[1] - math.max(recoil - 0.5,0) / 0.5 * 15

    wmAngle[2] = wmAngle[2] + recoil * abs + math.max(recoil - 0.5,0) / 0.5 * 3 * abs - math.ease.InBounce(recoil) * 5 * abs + math.cos(CurTime() * 3) * recoil * 2
    wmVector[3] = wmVector[3] + 2 * recoil
end
