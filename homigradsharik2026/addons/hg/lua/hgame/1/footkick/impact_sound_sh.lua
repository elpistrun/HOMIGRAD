local Index_Registry = function(name,manual) surfaceWorld.Index_Registry(name,"sound","footkick",manual) end

local manual_cocrete = {
    "physics/body/body_medium_impact_hard3.wav",
    "physics/body/body_medium_impact_hard4.wav",
    "physics/body/body_medium_impact_hard5.wav"
}

local manual_solid_metal = {
    "physics/metal/metal_solid_impact_hard1.wav",
    "physics/metal/metal_solid_impact_hard2.wav",
    "physics/metal/metal_solid_impact_hard3.wav",
    "physics/metal/metal_solid_impact_hard4.wav",
}

local manual_metal_panel = {
    "physics/metal/metal_sheet_impact_hard6.wav",
    "physics/metal/metal_sheet_impact_hard7.wav",
    "physics/metal/metal_sheet_impact_hard8.wav",
}

local manual_metal_grate = {
    "physics/metal/metal_grate_impact_hard1.wav",
    "physics/metal/metal_grate_impact_hard2.wav",
    "physics/metal/metal_grate_impact_hard3.wav"
}

local manual_chainlink = {
    "physics/metal/metal_chainlink_impact_hard1.wav",
    "physics/metal/metal_chainlink_impact_hard2.wav",
    "physics/metal/metal_chainlink_impact_hard3.wav"
}

local manual_computer = {
    "physics/concrete/concrete_impact_hard1.wav",
    "physics/concrete/concrete_impact_hard2.wav",
    "physics/concrete/concrete_impact_hard3.wav"
}

local manual_glass = {
    "physics/glass/glass_sheet_impact_hard1.wav",
    "physics/glass/glass_sheet_impact_hard2.wav",
    "physics/glass/glass_sheet_impact_hard3.wav"
}

local manual_plastic_box = {
    "physics/plastic/plastic_box_impact_hard1.wav",
    "physics/plastic/plastic_box_impact_hard2.wav",
    "physics/plastic/plastic_box_impact_hard3.wav"
}

local manual_wood_solid = {
    "physics/wood/wood_solid_impact_hard1.wav",
    "physics/wood/wood_solid_impact_hard2.wav",
    "physics/wood/wood_solid_impact_hard3.wav"
}

local manual_flesh = {
    "eft/impact/body1.wav",
    "eft/impact/body2.wav",
    "eft/impact/body3.wav",
    "eft/impact/body4.wav",
    "eft/impact/body5.wav",
    "eft/impact/body6.wav",
}

local manual_sand = {
    "physics/body/body_medium_impact_hard3.wav",
    "physics/body/body_medium_impact_hard4.wav",
    "physics/body/body_medium_impact_hard5.wav"
}

local manual_cardboard = {
    "physics/body/body_medium_impact_hard3.wav",
    "physics/body/body_medium_impact_hard4.wav",
    "physics/body/body_medium_impact_hard5.wav"
}

local manual_rubber = {
    "physics/rubber/rubber_tire_impact_hard1.wav",
    "physics/rubber/rubber_tire_impact_hard2.wav",
    "physics/rubber/rubber_tire_impact_hard3.wav"
}
-- Base

Index_Registry("default",{pitch = 100,list = manual_cocrete})
Index_Registry("glass",{pitch = 100,list = manual_glass})
Index_Registry("rubber",{pitch = 100,list = manual_rubber})
Index_Registry("water",{pitch = 100,list = manual_sand})
Index_Registry("waterlemon",{pitch = 100,list = manual_sand})
Index_Registry("slime",{pitch = 100,list = manual_sand})
Index_Registry("chainlink",{pitch = 100,list = manual_chainlink})
Index_Registry("computer",{pitch = 100,list = manual_computer})
Index_Registry("ice",{pitch = 100,list = manual_cocrete})

-- Concrete

Index_Registry("concrete",{pitch = 100,list = manual_cocrete})
Index_Registry("concrete_block",{pitch = 100,list = manual_cocrete})
Index_Registry("tile",{pitch = 100,list = manual_cocrete})
Index_Registry("brick",{pitch = 100,list = manual_cocrete})
Index_Registry("stone",{pitch = 100,list = manual_cocrete})
Index_Registry("rock",{pitch = 100,list = manual_cocrete})
Index_Registry("porcelain",{pitch = 100,list = manual_cocrete})
Index_Registry("boulder",{pitch = 100,list = manual_cocrete})
    
-- Metal

Index_Registry("solidmetal",{pitch = 80,list = manual_solid_metal})
Index_Registry("metal",{pitch = 80,list = manual_solid_metal})
Index_Registry("metal_box",{pitch = 80,list = manual_solid_metal})
Index_Registry("metal_bouncy",{pitch = 80,list = manual_solid_metal})
Index_Registry("metalpanel",{pitch = 80,list = manual_metal_panel})
Index_Registry("metalgrate",{pitch = 80,list = manual_metal_grate})
Index_Registry("metalvent",{pitch = 80,list = manual_metal_panel})
Index_Registry("metalvehicle",{pitch = 80,list = manual_metal_panel})
Index_Registry("canister",{pitch = 80,list = manual_metal_panel})
Index_Registry("metal_barrel",{pitch = 80,list = manual_metal_panel})
Index_Registry("floating_metal_barrel",{pitch = 80,list = manual_metal_panel})


--Sand

Index_Registry("dirt",{pitch = 100,list = manual_sand})
Index_Registry("sand",{pitch = 100,list = manual_sand})
Index_Registry("antlionsand",{pitch = 100,list = manual_sand})
Index_Registry("quicksand",{pitch = 100,list = manual_sand})
Index_Registry("gravel",{pitch = 100,list = manual_sand})
Index_Registry("grass",{pitch = 100,list = manual_sand})
Index_Registry("snow",{pitch = 100,list = manual_sand})
Index_Registry("mud",{pitch = 100,list = manual_sand})

--Wood

Index_Registry("wood",{pitch = 90,list = manual_wood_solid})
Index_Registry("wood_box",{pitch = 90,list = manual_wood_solid})
Index_Registry("wood_crate",{pitch = 90,list = manual_wood_solid})
Index_Registry("wood_plank",{pitch = 90,list = manual_wood_solid})
Index_Registry("wood_solid",{pitch = 90,list = manual_wood_solid})
Index_Registry("wood_furniture",{pitch = 90,list = manual_wood_solid})
Index_Registry("wood_panel",{pitch = 90,list = manual_wood_solid})

-- Flesh

Index_Registry("flesh",{pitch = 100,list = manual_flesh})
Index_Registry("bloodyflesh",{pitch = 80,list = manual_flesh})
Index_Registry("alienflesh",{pitch = 90,list = manual_flesh})
Index_Registry("armorflesh",{pitch = 80,list = manual_flesh})

-- Plastic
Index_Registry("plastic",{pitch = 100,list = manual_plastic_box})
Index_Registry("plastic_barrel",{pitch = 100,list = manual_plastic_box})
Index_Registry("plastic_box",{pitch = 100,list = manual_plastic_box})

-- Clotch
Index_Registry("plaster",{pitch = 100,list = manual_cardboard})
Index_Registry("carpet",{pitch = 100,list = manual_cardboard})
Index_Registry("ceiling_tile",{pitch = 100,list = manual_sand})
Index_Registry("cardboard",{pitch = 100,list = manual_cardboard})
Index_Registry("paper",{pitch = 100,list = manual_cardboard})

local Fast = surfaceWorld.Fast.sound.bullet

function surfaceWorld.CreateSoundBullet(emitEnt,surfaceName)
    if surfaceName == "no_decal" then return end
    
    local pos

    if CLIENT then
        emitEnt = TypeID(emitEnt) == TYPE_VECTOR and sound.GetVurtialEmit(emitEnt,nil,1.5) or emitEnt
    else
        pos = emitEnt
        emitEnt = nil
    end

    local info = Fast[surfaceName] 
  
    if info then
        local pitch = (info.pitch or 100) + math.random(-1,1)
        local snd = info.list[math.random(1,#info.list)]

        sound.Emit(emitEnt,snd,75,1,pitch,pos,nil,nil,CHAN_STATIC)
    else
        print("surfaceWorld.CreateSoundBullet->missing sound: " .. surfaceName)
    end
end