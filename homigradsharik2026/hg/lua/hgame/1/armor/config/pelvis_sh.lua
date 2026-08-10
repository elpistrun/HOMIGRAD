local pelvis_slots = {pelvis = true}

armorGame.Reg("pelvis_redut_t5",{
    printName = "AR Redut T5 Lower",
    model = "models/eft_props/gear/armor/ar_redut_t5_lower.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_redutt5pelvis.png",

	bone = "ValveBiped.Bip01_Pelvis",
	vec = armorGame.pelvis_vec,
    size = Vector(1,1,1),
    ang = armorGame.pelvis_ang,

    slots = pelvis_slots,
    category = "pelvis",
    
    ratedJoules = 250
},armorGame.sound_armor,armorGame.tier_3)

armorGame.Reg("pelvis_6b43",{
    printName = "6B43 Lower",
    model = "models/eft_props/gear/armor/ar_6b43_pelvis.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_6b43pelvis.png",

	bone = "ValveBiped.Bip01_Pelvis",
	vec = armorGame.pelvis_vec,
    size = Vector(1,1,1),
    ang = armorGame.pelvis_ang,

    slots = pelvis_slots,
    category = "pelvis",
},armorGame.sound_armor,armorGame.tier_3)