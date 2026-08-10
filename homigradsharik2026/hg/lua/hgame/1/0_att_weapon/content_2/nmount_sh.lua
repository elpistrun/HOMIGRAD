attachmentGame.ManualReg("nmount",{
    ["kalimator_okp7_nmount"] = {
        "kalimator_okp7_nmount",
        vec = Vector(),
        ang = Angle(0,-90,0)
    }
})

attachmentGame.ManualReg("scope_mount",{
    ["kalimator_okp7"] = {
        "kalimator_okp7",
        vec = Vector(),
        ang = Angle(0,-90,0)
    },
    ["kalimator_walther_mrs"] = {
        "kalimator_walther_mrs",
        vec = Vector(0,-0.6,0),
        ang = Angle(0,-90,0)
    },
    ["mount_optic_30mm_burris_pepr"] = {
        "mount_optic_30mm_burris_pepr",
        vec = Vector(0,-0.3,0),
        ang = Angle(0,-90,0)
    },
    ["scope_specter"] = {
        "scope_specter",
        vec = Vector(0,-0.3,0),
        ang = Angle(0,-90,0)
    },
    ["holosight_vortex_razor"] = {
        "holosight_vortex_razor",
        vec = Vector(0,-0.3,0),
        ang = Angle(0,-90,0)
    },
    ["holosight_eotech"] = {
        "holosight_eotech",
        vec = Vector(0,-0.3,0),
        ang = Angle(0,-90,0)
    },
})

WepAtt("mount_mlok_offset",{
    printName = "MLock",
    icon = "entities/eft_attachments/mount/mlokoffset.png",
    model = "models/weapons/arc9_eft_shared/atts/mounts/mlok.mdl",
    bodygroups = {
        [0] = 3
    }
})