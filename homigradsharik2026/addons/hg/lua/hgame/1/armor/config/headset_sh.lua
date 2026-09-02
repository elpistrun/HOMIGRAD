local ang_helmet = Angle(0,-90,-90)
local headset_slots = {headset = true}

armorGame.Reg("headset_m32",{
    printName = "M32",
    model = "models/eft_props/gear/headsets/headset_m32.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_m32.png",

	bone = "ValveBiped.Bip01_Head1",
	vec = armorGame.head_vec,
    size = Vector(1,1,1),
    ang = armorGame.head_ang,

    slots = headset_slots,
    category = "headset",

    cameraVec = Vector(-0.8,0,-0.6),
    cameraAng = Angle(14,0,0),
    cameraSize = Vector(1,1,1),

    iframe = true
},armorGame.sound_goggles,armorGame.headset_1)