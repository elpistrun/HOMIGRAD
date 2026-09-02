local Index_Registry = function(name,manual) surfaceWorld.Index_Registry(name,"sound","bleed",manual) end

local manual_cocrete = {}
for i = 1,12 do manual_cocrete[i] = "homigrad/player/bleed/drip" .. i .. ".wav" end

local manual_solid_metal = {}
for i = 1,9 do manual_solid_metal[i] = "homigrad/player/bleed/drip_metal" .. i .. ".wav" end

local manual_metal_panel = manual_solid_metal
local manual_metal_grate = manual_solid_metal
local manual_chainlink = manual_solid_metal

local manual_computer = manual_solid_metal
local manual_glass = manual_solid_metal
local manual_plastic_box = manual_cocrete
local manual_wood_solid = manual_cocrete
local manual_flesh = manual_cocrete
local manual_sand = manual_cocrete
local manual_cardboard = manual_cocrete
local manual_rubber = manual_cocrete

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
Index_Registry("floating_metal_barrel",{pitch = 80,list = manual_metal_panel})

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