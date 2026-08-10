local Index_Registry = function(name,manual) surfaceWorld.Index_Registry(name,"sound","shell_heavy",manual) end

local manual_plastic = {
    "weapons/shells/heavy_shell_plastic1.wav",
    "weapons/shells/heavy_shell_plastic2.wav",
    "weapons/shells/heavy_shell_plastic3.wav",
    "weapons/shells/heavy_shell_plastic4.wav",
    "weapons/shells/heavy_shell_plastic5.wav"
}

local manual_soil = {
    "weapons/shells/heavy_shell_soil1.wav",
    "weapons/shells/heavy_shell_soil2.wav",
    "weapons/shells/heavy_shell_soil3.wav"
}

local manual_cocrete = {
    "weapons/shells/heavy_shell_concrete1.wav",
    "weapons/shells/heavy_shell_concrete2.wav",
    "weapons/shells/heavy_shell_concrete3.wav"
}

local manual_wood = {
    "weapons/shells/heavy_shell_wood1.wav",
    "weapons/shells/heavy_shell_wood2.wav",
    "weapons/shells/heavy_shell_wood3.wav"
}

local manual_metal = {
    "weapons/shells/heavy_shell_metal1.wav",
    "weapons/shells/heavy_shell_metal2.wav",
    "weapons/shells/heavy_shell_metal3.wav"
}

-- Base

Index_Registry("default",{pitch = 100,list = manual_cocrete})
Index_Registry("glass",{pitch = 100,list = manual_metal})
Index_Registry("rubber",{pitch = 100,list = manual_plastic})
Index_Registry("water",{pitch = 100,list = manual_cocrete})
Index_Registry("waterlemon",{pitch = 100,list = manual_cocrete})
Index_Registry("slime",{pitch = 100,list = manual_soil})
Index_Registry("chainlink",{pitch = 100,list = manual_cocrete})
Index_Registry("computer",{pitch = 100,list = manual_cocrete})
Index_Registry("ice",{pitch = 100,list = manual_wood})

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

Index_Registry("solidmetal",{pitch = 100,list = manual_metal})
Index_Registry("metal",{pitch = 100,list = manual_metal})
Index_Registry("metal_box",{pitch = 100,list = manual_metal})
Index_Registry("metal_bouncy",{pitch = 100,list = manual_metal})
Index_Registry("metalpanel",{pitch = 100,list = manual_metal})
Index_Registry("metalgrate",{pitch = 100,list = manual_metal})
Index_Registry("metalvent",{pitch = 100,list = manual_metal})
Index_Registry("metalvehicle",{pitch = 100,list = manual_metal})
Index_Registry("canister",{pitch = 100,list = manual_metal})
Index_Registry("metal_barrel",{pitch = 100,list = manual_metal})
Index_Registry("floating_metal_barrel",{pitch = 100,list = manual_metal})

--Sand

Index_Registry("dirt",{pitch = 100,list = manual_soil})
Index_Registry("sand",{pitch = 100,list = manual_soil})
Index_Registry("antlionsand",{pitch = 100,list = manual_soil})
Index_Registry("quicksand",{pitch = 100,list = manual_soil})
Index_Registry("gravel",{pitch = 100,list = manual_soil})
Index_Registry("grass",{pitch = 100,list = manual_soil})
Index_Registry("snow",{pitch = 100,list = manual_soil})
Index_Registry("mud",{pitch = 100,list = manual_soil})

--Wood

Index_Registry("wood",{pitch = 100,list = manual_wood})
Index_Registry("wood_box",{pitch = 100,list = manual_wood})
Index_Registry("wood_crate",{pitch = 100,list = manual_wood})
Index_Registry("wood_plank",{pitch = 100,list = manual_wood})
Index_Registry("wood_solid",{pitch = 100,list = manual_wood})
Index_Registry("wood_furniture",{pitch = 100,list = manual_wood})
Index_Registry("wood_panel",{pitch = 100,list = manual_wood})

-- Flesh

Index_Registry("flesh",{pitch = 100,list = manual_soil})
Index_Registry("bloodyflesh",{pitch = 100,list = manual_soil})
Index_Registry("alienflesh",{pitch = 100,list = manual_soil})
Index_Registry("armorflesh",{pitch = 80,list = manual_soil})

-- Plastic
Index_Registry("plastic",{pitch = 100,list = manual_plastic})
Index_Registry("plastic_barrel",{pitch = 100,list = manual_plastic})
Index_Registry("plastic_box",{pitch = 100,list = manual_plastic})

-- Clotch
Index_Registry("plaster",{pitch = 100,list = manual_plastic})
Index_Registry("carpet",{pitch = 100,list = manual_plastic})
Index_Registry("ceiling_tile",{pitch = 100,list = manual_plastic})
Index_Registry("cardboard",{pitch = 100,list = manual_plastic})
Index_Registry("paper",{pitch = 100,list = manual_plastic})