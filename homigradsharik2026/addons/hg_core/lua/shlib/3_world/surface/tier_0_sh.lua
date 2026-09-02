-- Far Cry 5 type beat shit aura

surfaceWorld = surfaceWorld or {}

surfaceWorld.Index = surfaceWorld.Index or {}
local Index = surfaceWorld.Index

surfaceWorld.Fast = surfaceWorld.Fast or {}
local Fast = surfaceWorld.Fast

function surfaceWorld.Index_Registry(name,event,type,manual)
    local surface = Index[name]

    if not surface then
        surface = {}

        Index[name] = surface
    end

    if event then
        Index[name][event] = Index[name][event] or {}
        Index[name][event][type] = manual

        Fast[event] = Fast[event] or {}
        Fast[event][type] = Fast[event][type] or {}
        Fast[event][type][name] = manual
    end

    if not Initialize then
        timer.Create("surfaceWorld.ConstructSurfaceSpliters()",0,1,function()
            surfaceWorld.ConstructSurfaceSpliters()
        end)
    end

    return surface
end

function surfaceWorld.Index_Registry_Event(name,event,manual)
    if not Index[name] then error("surfaceWorld->" .. tostring(name) .. " is not exists") end

    Index[name][event] = manual

    Fast[event] = Fast[event] or {}
    Fast[event][name] = manual

    return manual
end

surfaceWorld.TypeIndex = surfaceWorld.TypeIndex or {}
local TypeIndex = surfaceWorld.TypeIndex

function surfaceWorld.TypeIndex_Registry(categoryName,list)
    for i,name in pairs(list) do
        surfaceWorld.Index_Registry(name)

        TypeIndex[name] = categoryName
    end
end

local defaultSurface = {name = "concrete"} 

function surfaceWorld.GetSurfaceName(SurfaceProps)
    local surfaceData = util.GetSurfaceData(SurfaceProps)
    if not surfaceData then surfaceData = defaultSurface end

    return surfaceData.name
end

surfaceWorld.SurfaceNameSplitter = {
    ["gm_ps_soccerball"] = "rubber"
}

function surfaceWorld.ConstructSurfaceSpliters()
    for name,base in pairs(surfaceWorld.SurfaceNameSplitter) do
        for event,list in pairs(surfaceWorld.Fast) do
            for type,list in pairs(list) do
                local baseSurface = list[base]

                surfaceWorld.Index_Registry(name,event,type,util.tableCopy(baseSurface))
            end
        end
    end
end

if Initialize then surfaceWorld.ConstructSurfaceSpliters() end

function surfaceWorld.GetSurfaceNameByTrace(result)
    if IsValid(result.Entity) and util.EntityIsGlass(result.Entity) then return "glass" end
    
    return surfaceWorld.GetSurfaceName(result.SurfaceProps)
end