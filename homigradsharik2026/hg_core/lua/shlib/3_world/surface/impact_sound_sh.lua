local Index_Registry = function(name,manual) surfaceWorld.Index_Registry(name,"sound","bullet",manual) end

local manual_cocrete = {
    "physics/concrete/concrete_impact_bullet1.wav",
    "physics/concrete/concrete_impact_bullet2.wav",
    "physics/concrete/concrete_impact_bullet3.wav"
}

local manual_solid_metal = {
    "physics/metal/metal_solid_impact_bullet1.wav",
    "physics/metal/metal_solid_impact_bullet2.wav",
    "physics/metal/metal_solid_impact_bullet3.wav",
    "physics/metal/metal_solid_impact_bullet4.wav",
}

local manual_metal_panel = {
    "physics/metal/metal_sheet_impact_bullet1.wav",
    "physics/metal/metal_sheet_impact_bullet2.wav"
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
    "physics/metal/metal_computer_impact_bullet1.wav",
    "physics/metal/metal_computer_impact_bullet2.wav",
    "physics/metal/metal_computer_impact_bullet3.wav"
}

local manual_glass = {
    "physics/glass/glass_impact_bullet1.wav",
    "physics/glass/glass_impact_bullet2.wav",
    "physics/glass/glass_impact_bullet3.wav"
}

local manual_plastic_box = {
    "physics/plastic/plastic_box_impact_bullet1.wav",
    "physics/plastic/plastic_box_impact_bullet2.wav",
    "physics/plastic/plastic_box_impact_bullet3.wav"
}

local manual_wood_solid = {
    "physics/wood/wood_solid_impact_bullet1.wav",
    "physics/wood/wood_solid_impact_bullet2.wav",
    "physics/wood/wood_solid_impact_bullet3.wav",
    "physics/wood/wood_solid_impact_bullet4.wav",
    "physics/wood/wood_solid_impact_bullet5.wav"
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
    "physics/surfaces/sand_impact_bullet1.wav",
    "physics/surfaces/sand_impact_bullet2.wav",
    "physics/surfaces/sand_impact_bullet3.wav",
    "physics/surfaces/sand_impact_bullet4.wav"
}

local manual_cardboard = {
    "physics/cardboard/cardboard_box_impact_bullet1.wav",
    "physics/cardboard/cardboard_box_impact_bullet2.wav",
    "physics/cardboard/cardboard_box_impact_bullet3.wav"
}

local manual_rubber = {
    "physics/rubber/rubber_tire_impact_hard1.wav",
    "physics/rubber/rubber_tire_impact_hard2.wav",
    "physics/rubber/rubber_tire_impact_hard3.wav"
}
-- Base

Index_Registry("default",{pitch = 100,list = manual_cocrete})
Index_Registry("glass",{pitch = 80,list = manual_glass})
Index_Registry("rubber",{pitch = 100,list = manual_rubber})
Index_Registry("water",{pitch = 100,list = manual_sand})
Index_Registry("waterlemon",{pitch = 100,list = manual_sand})
Index_Registry("slime",{pitch = 100,list = manual_sand})
Index_Registry("chainlink",{pitch = 100,list = manual_chainlink})
Index_Registry("computer",{pitch = 100,list = manual_computer})
Index_Registry("ice",{pitch = 100,list = manual_cocrete})

-- Concrete

Index_Registry("concrete",{pitch = 65,list = manual_cocrete})
Index_Registry("concrete_block",{pitch = 65,list = manual_cocrete})
Index_Registry("tile",{pitch = 75,list = manual_cocrete})
Index_Registry("brick",{pitch = 75,list = manual_cocrete})
Index_Registry("stone",{pitch = 65,list = manual_cocrete})
Index_Registry("rock",{pitch = 65,list = manual_cocrete})
Index_Registry("porcelain",{pitch = 100,list = manual_cocrete})
Index_Registry("boulder",{pitch = 100,list = manual_cocrete})
    
-- Metal

Index_Registry("solidmetal",{pitch = 70,list = manual_solid_metal})
Index_Registry("metal",{pitch = 70,list = manual_solid_metal})
Index_Registry("metal_box",{pitch = 65,list = manual_solid_metal})
Index_Registry("metal_bouncy",{pitch = 65,list = manual_solid_metal})
Index_Registry("metalpanel",{pitch = 65,list = manual_metal_panel})
Index_Registry("metalgrate",{pitch = 95,list = manual_metal_grate})
Index_Registry("metalvent",{pitch = 75,list = manual_metal_panel})
Index_Registry("metalvehicle",{pitch = 80,list = manual_metal_panel})
Index_Registry("canister",{pitch = 80,list = manual_metal_panel})
Index_Registry("metal_barrel",{pitch = 80,list = manual_metal_panel})
Index_Registry("popcan",{pitch = 120,list = manual_metal_panel})

--Sand

Index_Registry("dirt",{pitch = 90,list = manual_sand})
Index_Registry("sand",{pitch = 120,list = manual_sand})
Index_Registry("antlionsand",{pitch = 110,list = manual_sand})
Index_Registry("quicksand",{pitch = 100,list = manual_sand})
Index_Registry("gravel",{pitch = 90,list = manual_sand})
Index_Registry("grass",{pitch = 95,list = manual_sand})
Index_Registry("snow",{pitch = 120,list = manual_sand})
Index_Registry("mud",{pitch = 80,list = manual_sand})

--Wood

Index_Registry("wood",{pitch = 80,list = manual_wood_solid})
Index_Registry("wood_box",{pitch = 80,list = manual_wood_solid})
Index_Registry("wood_crate",{pitch = 80,list = manual_wood_solid})
Index_Registry("wood_plank",{pitch = 80,list = manual_wood_solid})
Index_Registry("wood_solid",{pitch = 80,list = manual_wood_solid})
Index_Registry("wood_furniture",{pitch = 80,list = manual_wood_solid})
Index_Registry("wood_panel",{pitch = 80,list = manual_wood_solid})

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
Index_Registry("plaster",{pitch = 60,list = manual_cardboard})
Index_Registry("carpet",{pitch = 100,list = manual_cardboard})
Index_Registry("ceiling_tile",{pitch = 60,list = manual_sand})
Index_Registry("cardboard",{pitch = 60,list = manual_cardboard})
Index_Registry("paper",{pitch = 60,list = manual_cardboard})

local Fast = surfaceWorld.Fast.sound.bullet

function surfaceWorld.CreateSoundBullet(emitEnt,surfaceName,pitchAdd,volumeAdd)
    local pos

    if CLIENT then
        emitEnt = TypeID(emitEnt) == TYPE_VECTOR and sound.GetVurtialEmit(emitEnt,nil,1.5) or emitEnt

        if not pos and TypeID(emitEnt) == TYPE_ENTITY then
            pos = emitEnt:GetPos()
        end
    else
        pos = emitEnt
        emitEnt = nil
    end

    local info = Fast[surfaceName] 
  
    if info then
        local pitch = (info.pitch or 100) + math.random(-1,1)
        local snd = info.list[math.random(1,#info.list)]

        sound.Emit(emitEnt,snd,80,1 - (volumeAdd or 0),sound.PitchDistance(pos,nil,pitch + (pitchAdd or 0)),pos,nil,nil,CHAN_STATIC)
    else
        print("surfaceWorld.CreateSoundBullet->missing sound: " .. surfaceName)
    end
end