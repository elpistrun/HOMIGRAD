local ang_helmet = Angle(0,-90,-90)
local helmet_slots = {head = true}

armorGame.Reg("helmet_achc_black",{
    printName = "ACHC Black",
    model = "models/eft_props/gear/helmets/helmet_achhc_b.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_achhcblack.png",

	bone = "ValveBiped.Bip01_Head1",
	vec = armorGame.head_vec,
    size = Vector(1,1,1),
    ang = armorGame.head_ang,

    slots = helmet_slots,
    category = "helmet",
    
    ratedJoules = 170,

    cameraVec = Vector(0.5,0,0.5),
    cameraAng = Angle(12,0,0),
    cameraSize = Vector(0.3,1,1)
},armorGame.sound_helmet,armorGame.tier_2,armorGame.speed_1)

armorGame.Reg("helmet_6b47_cover",{
    printName = "6B47",
    model = "models/eft_props/gear/helmets/helmet_6b47_cover.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_6b47chehol.png",

	bone = "ValveBiped.Bip01_Head1",
	vec = armorGame.head_vec,
    size = Vector(1,1,1),
    ang = armorGame.head_ang,

    slots = helmet_slots,
    category = "helmet",

    cameraVec = Vector(0.5,0,0.5),
    cameraAng = Angle(12,0,0),
    cameraSize = Vector(0.3,1,1)
},armorGame.sound_helmet,armorGame.tier_3,armorGame.speed_1)

local ARMOR = armorGame.Reg("helmet_ops_fast_black",{
    printName = "OPS Core Fast Black",
    model = "models/eft_props/gear/helmets/helmet_ops_core_fast_black.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_fastmtblack.png",

	bone = "ValveBiped.Bip01_Head1",
	vec = armorGame.head_vec,
    size = Vector(1,1,1),
    ang = armorGame.head_ang,

    slots = helmet_slots,
    category = "helmet",
    
    cameraVec = Vector(0.5,0,0.5),
    cameraAng = Angle(12,0,0),
    cameraSize = Vector(0.3,1,1),

    MainAttachment = {slots = {
        ["left"] = {
            name = "Left",
            slotPos = Vector(5,0,3),
            slots = {
                [0] = {false},
            }
        },
        ["center"] = {
            name = "Center",
            slotPos = Vector(0,-6,4.5),
            slots = {
                [0] = {false}
            }
        },
        ["right"] = {
            name = "Right",
            slotPos = Vector(-5,0,3),
            slots = {
                [0] = {false}
            }
        },
        ["face"] = {
            name = "Face",
            slotPos = Vector(0,-6,-0.5),
            slots = {
                [0] = {false},
                ["armor_att_ops_core_face"] = {"armor_att_ops_core_face",vec = Vector(0,0,0),ang = Angle()}
            }
        }
    }}
},armorGame.sound_helmet,armorGame.tier_3,armorGame.speed_1)

attachmentGame.ManualCreate(ARMOR.MainAttachment.slots.left.slots,"flashlight",Vector(-1,4.6,3.1),Angle(0,0,-90 + 10))
attachmentGame.ManualCreate(ARMOR.MainAttachment.slots.right.slots,"flashlight",Vector(-1,-4.6,3.1),Angle(0,0,90 + 10))

attachmentGame.ManualCreate(ARMOR.MainAttachment.slots.left.slots,"gopro",Vector(-1,4.6,3.1),Angle(0,0,0),{goProPos = Vector(2,2.5,0),goProAng = Angle(10,-20,0)})
attachmentGame.ManualCreate(ARMOR.MainAttachment.slots.right.slots,"gopro",Vector(-1,-4.6,3.1),Angle(0,0,0),{goProPos = Vector(2,-2.5,0),goProAng = Angle(10,20,0)})
attachmentGame.ManualCreate(ARMOR.MainAttachment.slots.center.slots,"gopro",Vector(6,0,2),Angle(0,0,0),{goProPos = Vector(0,0,-1),goProAng = Angle(10,0,0)})

armorGame.Reg("helmet_galvion_applique",{
    printName = "Galvion Applique",
    model = "models/eft_props/gear/helmets/helmet_galvion_applique.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_caimanapplique.png",

	bone = "ValveBiped.Bip01_Head1",
	vec = armorGame.head_vec,
    size = Vector(1,1,1),
    ang = armorGame.head_ang,

    slots = helmet_slots,
    category = "helmet",
    
    cameraVec = Vector(0.5,0,0.5),
    cameraAng = Angle(12,0,0),
    cameraSize = Vector(0.3,1,1)
},armorGame.sound_helmet,armorGame.tier_3,armorGame.speed_1,armorGame.helmetInv)

armorGame.Reg("helmet_un",{
    printName = "Untarhelm",
    model = "models/eft_props/gear/helmets/helmet_un.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_untarhelm.png",

	bone = "ValveBiped.Bip01_Head1",
	vec = armorGame.head_vec,
    size = Vector(1,1,1),
    ang = armorGame.head_ang,

    slots = helmet_slots,
    category = "helmet",
    
    ratedJoules = 170,

    cameraVec = Vector(0.5,0,0.5),
    cameraAng = Angle(12,0,0),
    cameraSize = Vector(0.3,1,1)
},armorGame.sound_helmet,armorGame.tier_2,armorGame.speed_1)

local mat = Material("mask_overlays/mask_binocular.png")
local mat2 = Material("mask_overlays/mask_anvis.png")

local modifyParameters = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0.05,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

armorGame.Reg("helmet_devtac",{
    printName = "DevTac Ronin",
    model = "models/eft_props/gear/helmets/helmet_devtac.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_devtacronin.png",

	bone = "ValveBiped.Bip01_Head1",
	vec = armorGame.head_vec,
    size = Vector(1,1,1),
    ang = armorGame.head_ang,

    slots = {head = true,mask = true,headset = true},
    category = "helmet",

    drawOverlayFunction = function()
        local w,h = ScrW(),ScrH()

        local wMat,hMat = w * 1,h * 1.1

        wMat = math.max(wMat / (RenderView.fov / 120),w)
        hMat = math.max(hMat / (RenderView.fov / 120),h)

        surface.SetMaterial(mat)
        surface.SetDrawColor(255,255,255,100)
        surface.DrawTexturedRect(w / 2 - wMat / 2,h / 2 - hMat / 2,wMat,hMat)

        surface.SetDrawColor(255,255,255,100)
        surface.SetMaterial(mat2)
        surface.DrawTexturedRect(w / 2 - wMat / 2,h / 2 - hMat / 2,wMat,hMat)

        DrawColorModify(modifyParameters)
    end,
},armorGame.sound_helmet,armorGame.tier_5,armorGame.speed_1)