local armor_slots = {chest = true}

armorGame.Reg("vest_redut_t5",{
    printName = "AR Redut T5",
    model = "models/eft_props/gear/armor/ar_redut_t5.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_redutt5vest.png",

    bone = "ValveBiped.Bip01_Spine2",
    vec = armorGame.body_vec,
    size = Vector(1,1,1),
    ang = armorGame.body_ang,

    slots = armor_slots,
    category = "armor",
},armorGame.sound_armor,armorGame.tier_3,armorGame.speed_1)

armorGame.Reg("vest_paca",{
    printName = "PACA",
    model = "models/eft_props/gear/armor/ar_paca.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_paca.png",

    bone = "ValveBiped.Bip01_Spine2",
    vec = armorGame.body_vec,
    size = Vector(1,1,1),
    ang = armorGame.body_ang,

    slots = armor_slots,
    category = "armor",
},armorGame.sound_armor,armorGame.tier_2,armorGame.speed_1)

armorGame.Reg("vest_6b43",{
    printName = "AR 6B43 Body",
    model = "models/eft_props/gear/armor/ar_6b43_body.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_6b43vest.png",

    bone = "ValveBiped.Bip01_Spine2",
    vec = armorGame.body_vec,
    size = Vector(1,1,1),
    ang = armorGame.body_ang + Angle(0,-5,0),

    slots = armor_slots,
    category = "armor",

    ratedJoules = 220,
},armorGame.sound_armor,armorGame.tier_3,armorGame.speed_2)

armorGame.Reg("vest_untar",{
    printName = "Untar",
    model = "models/eft_props/gear/armor/ar_untar.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_untar.png",

    bone = "ValveBiped.Bip01_Spine2",
    vec = armorGame.body_vec,
    size = Vector(1,1,1),
    ang = armorGame.body_ang + Angle(0,-5,0),

    slots = armor_slots,
    category = "armor",
},armorGame.sound_armor,armorGame.tier_2,armorGame.speed_1)

armorGame.Reg("vest_thor_crv",{
    printName = "Thor crv",
    model = "models/eft_props/gear/armor/ar_thor_crv.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_thorcrv.png",

    bone = "ValveBiped.Bip01_Spine2",
    vec = armorGame.body_vec,
    size = Vector(1,1,1),
    ang = armorGame.body_ang + Angle(0,-5,0),

    slots = armor_slots,
    category = "armor",
},armorGame.sound_armor,armorGame.tier_3,armorGame.speed_2)

armorGame.Reg("vest_slick_b",{
    printName = "Slick B",
    model = "models/eft_props/gear/armor/ar_slick_b.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_slickblack.png",

    bone = "ValveBiped.Bip01_Spine2",
    vec = armorGame.body_vec,
    size = Vector(1,1,1),
    ang = armorGame.body_ang + Angle(0,-5,0),

    slots = armor_slots,
    category = "armor",
},armorGame.sound_armor,armorGame.tier_3,armorGame.speed_2)

armorGame.Reg("vest_korundvm",{
    printName = "Korundvm",
    model = "models/eft_props/gear/armor/ar_korundvm.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_korundvm.png",

    bone = "ValveBiped.Bip01_Spine2",
    vec = armorGame.body_vec,
    size = Vector(1,1,1),
    ang = armorGame.body_ang + Angle(0,-5,0),

    slots = {chest = true,pelvis = true,neck = true},
    category = "armor",

},armorGame.sound_armor,armorGame.tier_4,armorGame.speed_3)

armorGame.Reg("vest_hexgrid",{
    printName = "Hexgrid",
    model = "models/eft_props/gear/armor/ar_custom_hexgrid.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_hexgrid.png",

    bone = "ValveBiped.Bip01_Spine2",
    vec = armorGame.body_vec,
    size = Vector(1,1,1),
    ang = armorGame.body_ang + Angle(0,-5,0),

    slots = armor_slots,
    category = "armor",
},armorGame.sound_armor,armorGame.tier_5,armorGame.speed_3)