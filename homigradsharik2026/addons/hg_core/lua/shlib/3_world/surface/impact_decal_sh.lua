local Index_Registry = function(name,manual) surfaceWorld.Index_Registry(name,"decal","bullet",manual) end
local Get = function(name) local mat = Material(name) return mat end

local manual_concrete = {
    Get("decals/concrete/shot1"),
    Get("decals/concrete/shot2"),
    Get("decals/concrete/shot3"),
    Get("decals/concrete/shot4"),
    Get("decals/concrete/shot5")
}

local manual_metal = {
    Get("decals/metal/shot1"),
    Get("decals/metal/shot2"),
    Get("decals/metal/shot3"),
    Get("decals/metal/shot4"),
    Get("decals/metal/shot5")
}

local manual_sand = {
    Get("decals/sand/shot1")
}

local manual_wood = {
    Get("decals/wood/shot1"),
    Get("decals/wood/shot2"),
    Get("decals/wood/shot3"),
    Get("decals/wood/shot4"),
    Get("decals/wood/shot5")
}

local manual_flesh = {
    Get("decals/flesh/blood1"),
    Get("decals/flesh/blood2"),
    Get("decals/flesh/blood3"),
    Get("decals/flesh/blood4"),
    Get("decals/flesh/blood5")
}

local manual_glass = {
    Get("decals/glass/shot1"),
    Get("decals/glass/shot2"),
    Get("decals/glass/shot3"),
    Get("decals/glass/shot4"),
    Get("decals/glass/shot5")
}

-- Base

Index_Registry("default",manual_concrete)
Index_Registry("glass",manual_glass)
Index_Registry("rubber",manual_sand)
Index_Registry("slime",manual_sand)
Index_Registry("chainlink",manual_sand)
Index_Registry("computer",manual_metal)
Index_Registry("ice",manual_concrete)

-- Concrete

Index_Registry("concrete",manual_concrete)
Index_Registry("concrete_block",manual_concrete)
Index_Registry("tile",manual_concrete)
Index_Registry("brick",manual_concrete)
Index_Registry("stone",manual_concrete)
Index_Registry("rock",manual_concrete)
Index_Registry("porcelain",manual_concrete)
Index_Registry("boulder",manual_concrete)

-- Metal

Index_Registry("solidmetal",manual_metal)
Index_Registry("metal",manual_metal)
Index_Registry("metal_box",manual_metal)
Index_Registry("metal_bouncy",manual_metal)
Index_Registry("metalpanel",manual_metal)
Index_Registry("metalgrate",manual_metal)
Index_Registry("metalvent",manual_metal)
Index_Registry("metalvehicle",manual_metal)
Index_Registry("metal_barrel",manual_metal)
Index_Registry("canister",manual_metal)
Index_Registry("slipperymetal",manual_metal)

-- Sand

Index_Registry("dirt",manual_sand)
Index_Registry("sand",manual_sand)
Index_Registry("antlionsand",manual_sand)
Index_Registry("quicksand",manual_sand)
Index_Registry("gravel",manual_sand)
Index_Registry("grass",manual_sand)
Index_Registry("snow",manual_sand)
Index_Registry("mud",manual_sand)

-- Wood

Index_Registry("wood",manual_wood)
Index_Registry("wood_box",manual_wood)
Index_Registry("wood_crate",manual_wood)
Index_Registry("wood_plank",manual_wood)
Index_Registry("wood_solid",manual_wood)
Index_Registry("wood_furniture",manual_wood)
Index_Registry("wood_panel",manual_wood)

-- Flesh

Index_Registry("flesh",manual_flesh)
Index_Registry("bloodyflesh",manual_flesh)
Index_Registry("alienflesh",manual_flesh)
Index_Registry("armorflesh",manual_flesh)

-- Plastic

Index_Registry("plastic",manual_concrete)
Index_Registry("plastic_barrel",manual_concrete)
Index_Registry("plastic_box",manual_concrete)

-- Clotch

Index_Registry("plaster",manual_sand)
Index_Registry("carpet",manual_concrete)
Index_Registry("ceiling_tile",manual_concrete)
Index_Registry("cardboard",manual_concrete)
Index_Registry("paper",manual_concrete)

--

local random = math.random

local Fast = surfaceWorld.Fast.decal.bullet

function surfaceWorld.CreateDecalBullet(pos,normal,ent,surfaceName,w,h)
    local info = Fast[surfaceName]
    if not info then info = Fast["default"] end

    if info then
        if #info == 0 then return end

        util.DecalEx(info[random(1,#info)],ent,pos,normal,Color(255,255,255),w or 1,h or 1)
    else
        print("surfaceWorld->decal missing: " .. surfaceName)
    end
end