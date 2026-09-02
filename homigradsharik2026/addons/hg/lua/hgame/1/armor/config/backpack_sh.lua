local ang_body = Angle(0,90,90)
local backpack_slots = {backpack = true}

armorGame.Reg("backpack_forward",{
    printName = "Duffle Bag",
    model = "models/eft_props/gear/backpacks/bp_forward.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_dufflebag.png",

	bone = "ValveBiped.Bip01_Spine2",
	vec = armorGame.backpack_vec,
    size = Vector(1,1,1),
    ang = armorGame.backpack_ang + Angle(0,-8,-10),

    slots = backpack_slots,
    category = "backpack",
    
    bodygroups = {[0] = 2},

    iframe = true
},armorGame.sound_backpack,armorGame.backpack_inventory_1)

armorGame.Reg("backpack_medback",{
    printName = "Med Bag",
    model = "models/eft_props/gear/backpacks/bp_med_bag.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_sanitarbag.png",

	bone = "ValveBiped.Bip01_Spine2",
	vec = armorGame.backpack_vec + Vector(0,-1,0.2),
    size = Vector(1,1,1),
    ang = armorGame.backpack_ang + Angle(0,0,0),

    slots = backpack_slots,
    category = "backpack",
    
    bodygroups = {[0] = 1},

    iframe = true
},armorGame.sound_backpack,armorGame.backpack_inventory_1)

armorGame.Reg("backpack_gr99_t30_b",{
    printName = "GR99 T30",
    model = "models/eft_props/gear/backpacks/bp_gr99_t30_b.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_gruppa99t30b.png",

	bone = "ValveBiped.Bip01_Spine2",
	vec = armorGame.backpack_vec - Vector(0,2,0),
    size = Vector(1,1,1),
    ang = armorGame.backpack_ang,

    slots = backpack_slots,
    category = "backpack",
    
    bodygroups = {[0] = 1},

    iframe = true
},armorGame.sound_backpack,armorGame.backpack_inventory_2)

armorGame.Reg("backpack_dragon_egg_mk2",{
    printName = "Dragon EGG MK2",
    model = "models/eft_props/gear/backpacks/bp_dragon_egg_mk2.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_dragonegg.png",

	bone = "ValveBiped.Bip01_Spine2",
	vec = armorGame.backpack_vec - Vector(1,2,0),
    size = Vector(1,1,1),
    ang = armorGame.backpack_ang,

    slots = backpack_slots,
    category = "backpack",
    
    bodygroups = {[0] = 1},

    iframe = true
},armorGame.sound_backpack,armorGame.backpack_inventory_2)

armorGame.Reg("backpack_anatactical_beta",{
    printName = "Anatactical Beta",
    model = "models/eft_props/gear/backpacks/bp_anatactical_beta.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_beta2bp.png",

	bone = "ValveBiped.Bip01_Spine2",
	vec = armorGame.backpack_vec - Vector(0,1,0),
    size = Vector(1,1,1),
    ang = armorGame.backpack_ang,

    slots = backpack_slots,
    category = "backpack",
    
    bodygroups = {[0] = 2},

    iframe = true
},armorGame.sound_backpack,armorGame.backpack_inventory_2)

armorGame.Reg("backpack_berkut",{
    printName = "Berkut",
    model = "models/eft_props/gear/backpacks/bp_wartech.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_berkutbp.png",

	bone = "ValveBiped.Bip01_Spine2",
	vec = armorGame.backpack_vec - Vector(1,1.5,0),
    size = Vector(1,1,1),
    ang = armorGame.backpack_ang,

    slots = backpack_slots,
    category = "backpack",
    
    bodygroups = {[0] = 2},

    iframe = true
},armorGame.sound_backpack,armorGame.backpack_inventory_2)