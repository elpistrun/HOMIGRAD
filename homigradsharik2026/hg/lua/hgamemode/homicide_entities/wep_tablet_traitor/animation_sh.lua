local SWEP = oop.Get("wep_tablet_traitor")
if not SWEP then return end

SWEP.AnimationList = {
    ["deploy"] = {
        index = 0,
        delay = 0.8,

        deploy = true
    },

    ["holster"] = {
        index = 0,
        delay = 0.5,

        holster = true,
        endless = true,
        inversion = true
    },

    ["idle"] = {
        index = 1,
        delay = 10,

        loop = true,

        fire = true
    }
}