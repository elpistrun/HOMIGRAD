attachmentGame.RegCategory("optic",{printName = "Оптики",prio = 4})

WepAtt("optic_nightforce_atacr",{
    printName = "NightForce atacr",
    category = "optic",
    icon = "entities/eft_attachments/scopes/30mmmarch.png",

    model = "models/weapons/arc9/darsu_eft/mods/scope_nightforce_atacr.mdl",
    
    Optic = true,
    
    ScopeSubIndex = 1,
    ScopeBodySubIndex = 2,
    ScopeScale = 13.5,

    ScopeZoom = 24,
    ScopeZoomStart = 24,
    ScopeZoomEnd = 1,

    ScopeHeight = 0,
    StartSightValue = -8,
    EndSightValue = 10,
    RenderSceneForward = 12,

    CameraAnchorPosition = true,
    CameraRecoil_Scope = 0,
    RecoilCameraMulScope = 0,
    RecoilBackMul = 0,

    BackCamera = 10,

    RetricleMaterial = Material("homigrad/scopes/reticles/34_nightforce_atacr.png",""),
    RetricleSize = 1,
    Cam3D2DSize = 0.0065,

    onWheel = function(attConfig,wep,wheel)
        wep.scopeValue = math.Clamp((wep.scopeValue or 0) + wheel / 4,0,1)

        attConfig.ScopeZoom = Lerp(wep.scopeValue,attConfig.ScopeZoomStart,attConfig.ScopeZoomEnd)

        wep:ChangeKey("ScopeSensitivity",Lerp(wep.scopeValue,0.1,0.01))

        sound.EmitScreen("arc9_eft_shared/weapon_light_switcher2.ogg",1,150)
    end
})

WepAtt("optic_tac30",{
    printName = "TAC30",
    category = "optic",
    icon = "entities/eft_attachments/scopes/30mmmarch.png",

    model = "models/weapons/arc9/darsu_eft/mods/scope_fullfield_tac30.mdl",
    
    Optic = true,
    
    ScopeSubIndex = 1,
    ScopeBodySubIndex = 2,
    ScopeScale = 13.5,

    ScopeZoom = 50,
    ScopeZoomStart = 50,
    ScopeZoomEnd = 16,

    ScopeHeight = 0,
    StartSightValue = -8,
    EndSightValue = 10,
    RenderSceneForward = 12,

    CameraAnchorPosition = true,
    CameraRecoil_Scope = 0,
    RecoilCameraMulScope = 0,
    RecoilBackMul = 0,

    BackCamera = 10.9,

    RetricleMaterial = Material("homigrad/scopes/reticles/scope_30mm_burris_fullfield_tac30_1_4x24_marks.png",""),
    RetricleSize = 1,
    Cam3D2DSize = 0.0065,

    onWheel = function(attConfig,wep,wheel)
        wep.scopeValue = math.Clamp((wep.scopeValue or 0) + wheel / 4,0,1)

        attConfig.ScopeZoom = Lerp(wep.scopeValue,attConfig.ScopeZoomStart,attConfig.ScopeZoomEnd)
        
        wep:ChangeKey("ScopeSensitivity",Lerp(wep.scopeValue,0.1,0.01))

        sound.EmitScreen("arc9_eft_shared/weapon_light_switcher2.ogg",1,150)
    end
})

attachmentGame.ManualReg("optic_30mm",{
    ["optic_nightforce_atacr"] = {
        "optic_nightforce_atacr",
        vec = Vector(),
        ang = Angle()
    },
    ["optic_tac30"] = {
        "optic_tac30",
        vec = Vector(1.7,0,0),
        ang = Angle(0,0,0)
    }
})

local att = WepAtt("mount_optic_30mm_burris_pepr",{
    printName = "Burris Pepr 30mm",
    category = "optic",
    model = "models/weapons/arc9/darsu_eft/mods/mount_all_burris_pepr.mdl",
    icon = "entities/eft_attachments/scopes/30mmpepr.png",
    slots = {
        ["1"] = {
            name = "Scope",
            slotPos = Vector(0,-1.5,1.6),
            slots = {
                [0] = {false}
            }
        }
    }
})

attachmentGame.ManualCreate(att.slots["1"].slots,"optic_30mm",Vector(1.5,0,1.7),Angle())

WepAtt("scope_specter",{
    printName = "Specter DR1 1-4x32",
    icon = "entities/eft_attachments/scopes/spectrdr.png",
    category = "optic",

    model = "models/weapons/arc9/darsu_eft/mods/scope_elcan_specter.mdl",

    ScopeHeight = 1.565,

    StartSightValue = -3.6,
    EndSightValue = 2.3,

    Optic = true,

    cameraOptions = {
        [0] = {
            ScopeZoom = 0,
            RetricleSize = 1,
            Cam3D2DSize = 0.0012,

            RetricleMaterial = Material("homigrad/scopes/reticles/elcan_specter_close.png",""),
            ScopeSensitivity = 0.3
        },
        [1] = {
            ScopeZoom = 30,
            RetricleSize = 0.74,
            Cam3D2DSize = 0.0025,

            ScopeSensitivity = 0.15,
            
            CameraRoll = 0,
            CameraAnchorPosition = true,
            CameraRecoil_Scope = 0,
            RecoilCameraMulScope = 0,
            RecoilBackMul = 0,

            BackCamera = 5.2,
            RetricleMaterial = Material("homigrad/scopes/reticles/elcan_specter.png",""),
        }
    },

})