local ang_helmet = Angle(0,-90,-90)
local mask_slots = {mask = true}

local mat = Material("mask_overlays/mask_gasmask.png")

armorGame.Reg("mask_balistic",{
    printName = "Balistic Mask",
    model = "models/eft_props/gear/facecover/facecover_ballistic_mask.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_ballisticmask.png",

	bone = "ValveBiped.Bip01_Head1",
	vec = armorGame.head_vec,
    size = Vector(1,1,1),
    ang = armorGame.head_ang,

    slots = mask_slots,
    category = "mask",
    
    ratedJoules = 250,

    drawOverlayFunction = function()
        local w,h = ScrW(),ScrH()

        local wMat,hMat = w * 1,h * 1.1

        wMat = math.max(wMat / (RenderView.fov / 120),w)
        hMat = math.max(hMat / (RenderView.fov / 120),h)

        surface.SetMaterial(mat)
        surface.SetDrawColor(255,255,255,250)
        surface.DrawTexturedRect(w / 2 - wMat / 2,h / 2 - hMat / 2,wMat,hMat)
    end,

    toggle = {
        [0] = {
            name = "Закрыто"
        },
        [1] = {
            name = "Открыто",
            drawOverlayFunction = false,
            iframe = true,
            ang = armorGame.head_ang + Angle(0,90,0),

            subStamina = 0.2
        }
    },

    isHelmetEffect = true,

    desc = "Даёт нагрузку на востановление стамины в закрытом положении"
},armorGame.sound_goggles,armorGame.tier_3)

armorGame.Reg("headset_tagila_mask",{
    printName = "Tagila Mask",
    model = "models/eft_props/gear/facecover/facecover_boss_welding_ubey.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_weldingkill.png",

	bone = "ValveBiped.Bip01_Head1",
	vec = armorGame.head_vec,
    size = Vector(0.9,0.9,0.9),
    ang = armorGame.head_ang,

    slots = mask_slots,
    category = "mask"
},armorGame.sound_helmet,armorGame.tier_5)