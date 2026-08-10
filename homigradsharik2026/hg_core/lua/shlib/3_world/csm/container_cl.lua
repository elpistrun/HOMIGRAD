CSM.containerTagIndex = CSM.containerTagIndex or {}
local containerTagIndex = CSM.containerTagIndex

function CSM.ClearAllContainer()
    for tag,container in pairs(containerTagIndex) do
        container.Delete()
    end
end

function CSM.GetContainer(cTag,parentEntity)
    local container = containerTagIndex[cTag]
    if container then return container end

    local tagIndex = {}
    local childrens = {}

    container = {
        tagIndex = tagIndex,
        childrens = childrens
    }

    containerTagIndex[cTag] = container

    local RemoveFromCSMContainer = function(mdl)
        if not mdl.csmID or tagIndex[mdl.csmID] ~= mdl then return end

        container.Remove(mdl)
    end

    function container.GetByID(mdlpath,tag,isWorldModel)
        local mdl = tagIndex[tag]

        if not IsValid(mdl) then
            mdl = CSM.CreateClientSideModel(mdlpath)
            if not IsValid(mdl) then return end
            
            mdl.csmContainerTag = cTag
            mdl.csmTag = tag

            mdl:CallOnRemove("RemoveFromCSMContainer",RemoveFromCSMContainer)

            if isWorldModel then
                mdl.isWorldModel = true
                mdl.RenderOverride = function() end
            end

            tagIndex[tag] = mdl
            childrens[#childrens+1] = mdl
            mdl.csmContainerID = #childrens

            return mdl,true
        end

        return mdl
    end

    if TypeID(parentEntity) == TYPE_ENTITY then
        parentEntity:CallOnRemove("RemoveCSMByParent_" .. tostring(cTag),function() container.Delete() end)
    end

    function container.Clear()
        for id,mdl in pairs(tagIndex) do
            tagIndex[id] = nil
            mdl:RemoveCallOnRemove("RemoveFromCSMContainer")
            CSM.Delete(mdl)
        end

        for i = 1,#childrens do childrens[i] = nil end
    end

    function container.Remove(mdl)
        if not IsValid(mdl) or not mdl.csmTag or tagIndex[mdl.csmTag] ~= mdl then return end

        mdl:RemoveCallOnRemove("RemoveFromCSMContainer")

        tagIndex[mdl.csmTag] = nil
        table.remove(childrens,mdl.csmContainerID)
        for i = mdl.csmContainerID,#childrens do childrens[i].csmContainerID = i end

        CSM.Delete(mdl)
    end

    function container.Delete()
        container.Clear()
        containerTagIndex[cTag] = nil
    end

    return container
end

if Initialize then RunConsoleCommand("hg_csm_chache_clear") end