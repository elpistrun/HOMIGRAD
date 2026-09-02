local neck_slots = {neck = true}

armorGame.Reg("neck_redut_t5",{
    printName = "Redut T5 Neck",
    model = "models/eft_props/gear/armor/ar_redut_t5_neck.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_redutt5_neck.png",

	bone = "ValveBiped.Bip01_Neck1",
	vec = Vector(-16.5,-15,0),
    size = Vector(1,1.1,1.6),
    ang = Angle(0,-56,-90),

    slots = neck_slots,
    category = "neck",
    
    ratedJoules = 250,

    cameraVec = Vector(0.5,0,0.5),
    cameraAng = Angle(12,0,0),
    cameraSize = Vector(0.3,1,1)
},armorGame.sound_helmet,armorGame.tier_2)

armorGame.Reg("neck_6b43",{
    printName = "6B43 Neck",
    model = "models/eft_props/gear/armor/ar_6b43_neck.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_6b43neck.png",

	bone = "ValveBiped.Bip01_Neck1",
	vec = Vector(-16,-17.5,0),
    size = Vector(0.8,1.1,1.6),
    ang = Angle(0,-50,-90),

    slots = neck_slots,
    category = "neck",
    
    ratedJoules = 250,

    cameraVec = Vector(0.5,0,0.5),
    cameraAng = Angle(12,0,0),
    cameraSize = Vector(0.3,1,1)
},armorGame.sound_helmet,armorGame.tier_2)