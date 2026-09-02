concommand.Add("hg_csm_chache_clear",function()
    print("\tremoved " .. CSM.ClearAll() .. " global CSM")

    CSM.ClearAllContainer()

    timer.Simple(0.1,function()
        local count = 0
        
        for i,ent in pairs(ents.FindByClass("class C_BaseFlex")) do
            if ent.csmIndex and CSM.globalIndex[ent.csmIndex] == ent then continue end
            
            count = count + 1

            ent:Remove()
        end

        if count > 0 then print("\tremoved " .. count .. " unregister client side models") end
    end)
end)

concommand.Add("hg_csm_chache",function()
    local list = {}

    print("< id || csmContainerTag || csmTag || modelPath >\n")

    local listNumbers,listStrings = {},{}

    for id,mdl in pairs(CSM.globalIndex) do
        if tonumber(id) then
            listNumbers[#listNumbers+1] = {tonumber(id),mdl}
        else
            listStrings[#listStrings+1] = {tostring(id),mdl}
        end
    end

    table.sort(listNumbers,function(a,b) return a[1] > b[1] end)

    for id,info in pairs(listNumbers) do
        local mdl = info[2]

        list[#list + 1] = id .. " || " .. tostring(mdl.csmContainerTag or "global") .. " || " .. tostring(mdl.csmTag) .. " || " .. (IsValid(mdl) and mdl:GetModel() or tostring(mdl))
    end

    for id,mdl in SortedPairs(listStrings) do
        local mdl = info[2]

        list[#list + 1] = id .. " || " .. tostring(mdl.csmContainerTag or "global") .. " || " .. tostring(mdl.csmTag) .. " || " .. (IsValid(mdl) and mdl:GetModel() or tostring(mdl))
    end

    for tag,container in pairs(CSM.containerTagIndex) do
        list[#list + 1] = "__CONTAINER__ " .. tostring(tag)
    end

    for i,msg in pairs(list) do
        print(msg)
    end
end)

concommand.Add("hg_csm_chache_tp",function(ply,cmd,args)
    local mdl = CSM.globalIndex[tostring(args[1])] or CSM.globalIndex[tonumber(args[1])]

    print(tostring(args[1]) .. " || " .. tostring(mdl.csmContainerTag or "global") .. " || " .. tostring(mdl.csmTag) .. " || " .. (IsValid(mdl) and mdl:GetModel() or tostring(mdl)))
    RunConsoleCommand("ulx","setpos",mdl:GetPos()[1],mdl:GetPos()[2],mdl:GetPos()[3])
end)

if Initialize then RunConsoleCommand("hg_csm_chache_clear") end

hook.Add("PostCleanupMap","hg_csm_chache_clear",function()
    RunConsoleCommand("hg_csm_chache_clear")
end)