armorGame.entityClassAttachmentMap["weapon_flashlight"] = "flashlight_kleh2u"

armorGame.RegAttCategory("face",{prio = 2,printName = "Лицевая защита"})

armorGame.RegAtt("armor_att_ops_core_face",{
    printName = "OPS Core Face Shield",
    model = "models/eft_props/gear/helmets/helmet_ops_core_handgun_face_shield.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_koplak1svisor.png",

    category = "face",
    
    bodygroups = {[0] = 0,[1] = 1},

    cameraVec = Vector(0,0,-1),
    cameraAng = Angle(-20,0,0),
    cameraSize = Vector(1,1.7,2),

    toggle = {
        [0] = {
            name = "Закрыто",
            snd = "eft_gear_sounds/glassshield_off.wav"
        },
        [1] = {
            name = "Открыто",
            bodygroups = {
                [0] = 1
            },
            snd = "eft_gear_sounds/glassshield_on.wav",
            iframe = true
        }
    }
},armorGame.sound_goggles,armorGame.tier_2)