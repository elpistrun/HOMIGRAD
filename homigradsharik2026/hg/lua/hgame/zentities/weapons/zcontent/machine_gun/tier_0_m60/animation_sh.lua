local SWEP = oop.Get("wep_m60")
if not SWEP then return end

SWEP.AnimationList = {
    ["deploy"] = {
        index = 1,
        delay = 1.3,
        skip = 0.7,
    },
    ["holster"] = {
        index = 3,
        delay = 1,
    },

    ["fire1"] = {
        index = 4,
        delay = 0.2,
        startCycle = 0.5,
    },

    ["fire2"] = {
        index = 4,
        delay = 0.2,
        startCycle = 0.5,
    },

    ["fire_empty"] = {
        index = 5,
        delay = 0.1,
    },

    ["unload_magazine"] = {
        index = 6,
        delay = 4,

        endCycle = 0.4,

        sound = {
            [0] = {{"weapons/eft/m60/m60_gunflip_1.ogg",75,0.4}},

            [0.1] = {{"weapons/eft/m60/pk_dust_open.ogg",75,0.6}},
            [0.11] = {{"weapons/eft/m60/m60_dust_open.ogg",75,0.6}},

            [0.25] = {{"weapons/eft/m60/m60_mag_out.ogg",75,0.4}},
            
            [0.3] = {{"weapons/eft/pkm/pk_gun_flip_4.ogg",75,0.4}},
            [0.4] = {{"weapons/eft/pkm/pk_gun_flip_3.ogg",75,0.4}},
            
            [0.6] = {{"weapons/eft/pkm/pk_gun_flip_3.ogg",75,0.4}},

            [0.75] = {{"weapons/eft/pkm/pk_mag_in.ogg",75,0.4}},
     
            [0.85] = {{"weapons/eft/pkm/pk_sight_mount_out.ogg",75,0.4}},
        },

        grabLeftHand = {[0] = false},
    },

    ["load_magazine"] = {
        index = 6,
        delay = 4,

        startCycle = 0.33,

        sound = {
            [0] = {{"weapons/eft/pkm/pk_mag_flip_1.ogg",75,0.4}},
            [0.1] = {{"weapons/eft/pkm/pk_mag_flip_2.ogg",75,0.4}},
            
            [0.15] = {{"weapons/eft/pkm/pk_dust_open.ogg",75,0.4}},

            [0.25] = {{"weapons/eft/pkm/pk_mag_out.ogg",75,0.4}},
            
            [0.3] = {{"weapons/eft/pkm/pk_gun_flip_4.ogg",75,0.4}},
            [0.4] = {{"weapons/eft/pkm/pk_gun_flip_3.ogg",75,0.4}},
            
            [0.6] = {{"weapons/eft/pkm/pk_gun_flip_3.ogg",75,0.4}},

            [0.75] = {{"weapons/eft/pkm/pk_mag_in.ogg",75,0.4}},
     
            [0.85] = {{"weapons/eft/pkm/pk_sight_mount_out.ogg",75,0.4}},
        },

        magazineDraw = {[0] = false,[0.1] = true},
        drawAmmo = {[0] = true},

        grabLeftHand = {[0] = false},
    },
    
    ["chamber"] = {
        index = 2,
        delay = 1.8,

        startCycle = 0.25,

        sound = {
            [0.5] = {{"weapons/eft/pkm/pk_charge_in.ogg",75,0.4}},
            [0.6] = {{"weapons/eft/m60/pk_fire_dry_armed.ogg",75,0.4}},
        },

        grabLeftHand = {[0] = false},

        skip = 0.69,
    },

    ["inspect"] = {
        index = 9,
        delay = 4,

        noFight = true,
        dontShake = true
    }
}

SWEP.AnimationInspectList = {
    "inspect"
}

function SWEP:AttackAnimation()
    self.attackAnimMode = not self.attackAnimMode

    self:PlayAnimation(self.attackAnimMode and "fire1" or "fire2")
end