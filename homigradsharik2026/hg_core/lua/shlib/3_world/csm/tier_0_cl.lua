CSM = CSM or {}

CSM.globalIndex = CSM.globalIndex or {}
local globalIndex = CSM.globalIndex

function CSM.Delay() return 1 / 10 end

if not CSM.freeIndexID then
    local list = {}

    for i = 1,8096 do list[i] = true end

    CSM.freeIndexID = list
end

local freeIndexID = CSM.freeIndexID

function CSM.CreateClientSideModel(mdlpath,renderGroup)
    if not mdlpath then return end
    
    local mdl = ClientsideModel(mdlpath,renderGroup)
    if not IsValid(mdl) then return end

    --

    local freeID

    for id in pairs(freeIndexID) do
        freeID = id
        freeIndexID[id] = nil

        break
    end

    mdl.csmIndex = freeID
    mdl.csmParentTag = -freeID

    mdl:CallOnRemove("CSM_BackFreeIndex",CSM.Delete)

    --

    globalIndex[freeID] = mdl
    
    return mdl
end

local function RenderOverride() end
local vecFar = Vector(32000,32000,32000)

function CSM.Delete(mdl)
    if not mdl then return end
    
    if not mdl.csmIndex or globalIndex[mdl.csmIndex] ~= mdl then
        if IsValid(mdl) and mdl:EntIndex() < 0 then
            mdl.RenderOverride = RenderOverride
            mdl:SetNoDraw(true)
            mdl:SetRenderOrigin(vecFar)
            mdl:Remove()
            mdl:CallHooksOnRemove()

            return true
        end

        return false
    end

    globalIndex[mdl.csmIndex] = nil
    freeIndexID[mdl.csmIndex] = true

    if IsValid(mdl) then
        mdl.RenderOverride = RenderOverride
        mdl:SetNoDraw(true)
        mdl:SetRenderOrigin(vecFar)
        mdl:Remove()
        mdl:CallHooksOnRemove()

        return true
    end

    return false--wtf
end

function CSM.ClearAll()
    local count = 0

    for id,mdl in pairs(globalIndex) do
        if IsValid(mdl) then
            mdl:RemoveCallOnRemove("CSM_BackFreeIndex")
            mdl:Remove()
        end

        count = count + 1

        globalIndex[id] = nil
    end

    for i = 1,8096 do freeIndexID[i] = true end

    return count
end

--

CSM.tagIndex = CSM.tagIndex or {}
local tagIndex = CSM.tagIndex

CSM.renderList = CSM.renderList or {}
local renderList = CSM.renderList

local function CSM_RemoveFromTagIndex(mdl)
    if not mdl.csmTag or tagIndex[mdl.csmTag] ~= mdl then return end

    tagIndex[mdl.csmTag] = nil
end

function CSM.GetByID(mdlpath,tag,isWorldModel)
    local mdl = tagIndex[tag]

    if not IsValid(mdl) then
        mdl = CSM.CreateClientSideModel(mdlpath)
        if not IsValid(mdl) then return end
        
        tagIndex[tag] = mdl
        mdl.csmTag = tag
        mdl:CallOnRemove("CSM_RemoveFromTagIndex",CSM_RemoveFromTagIndex)

        mdl.renderTime = RealTime() + CSM.Delay()

        renderList[#renderList + 1] = mdl

        if isWorldModel then
            mdl.RenderOverride = function() end
        end

        mdl.isWorldModel = isWorldModel

        return mdl,true
    end

    mdl.renderTime = RealTime() + CSM.Delay()

    return mdl
end

event.Add("PreRender","!CSM_RenderList",function()
    local time = RealTime()

    local i = 0

    ::start::

    i = i + 1

    local mdl = renderList[i]
    if not mdl then return end

    if not IsValid(mdl) or not mdl.renderTime then
        table.remove(renderList,i)
        i = i - 1

        goto start
    end

    if mdl.renderTime > time then goto start end

    mdl:Remove()

    table.remove(renderList,i)
    i = i - 1

    goto start
end,-100)

event.Add("EntityCreate","csmParentTag",function(ent)
    ent.csmParentTag = ent:EntIndex()
end,-10)

if Initialize then RunConsoleCommand("hg_csm_chache_clear") end