local ang_body = Angle(0,90,90)
local updump_slots = {updump = true}

armorGame.Reg("updump_thunderbolt",{
    printName = "Thunder Bolt",
    model = "models/eft_props/gear/chestrigs/cr_thunderbolt.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_thunderbolt.png",

	bone = "ValveBiped.Bip01_Spine2",
    vec = armorGame.body_vec,
    size = Vector(0.95,1,1),
    ang = armorGame.body_ang,

    slots = updump_slots,
    category = "updump",
    
    iframe = true
},armorGame.sound_generic,armorGame.dump_inventory_2)