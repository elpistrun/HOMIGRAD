local ang_body = Angle(0,90,90)
local dump_slots = {chest = true,updump = true}

armorGame.Reg("dump_plate_carrier",{
    printName = "CR TT Plate Carrier",
    model = "models/eft_props/gear/armor/cr/cr_tt_plate_carrier.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_ttsk.png",

	bone = "ValveBiped.Bip01_Spine2",
    vec = armorGame.body_vec,
    ang = armorGame.body_ang,

    slots = dump_slots,
    category = "dump",
    
    ratedJoules = 250,

    soundPickup = "eft_gear_sounds/gear_helmet_pickup.wav",
    soundUse = "eft_gear_sounds/gear_helmet_use.wav",
    soundDrop = "eft_gear_sounds/gear_helmet_drop.wav",
},armorGame.sound_armor,armorGame.dump_inventory_1,armorGame.tier_3)