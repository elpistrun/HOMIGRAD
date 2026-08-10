local ENTITY = FindMetaTable("Entity")

event.Add("EntityCreate","Decals",function(ent)
    if IsValid(ent) and ent:EntIndex() >= 0 then
        ent:ProxyPVSVar("Decals",function(_,_,value)
            ent.m_decals_json = value
            local tbl = util.JSONToTable(value)

            for i = 1,#tbl do
                local decal = tbl[i]
                decal[1] = Material(decal[1])
            end

            ent:RemoveAllDecals()

            ent:SetupDecals(tbl)
        end)
    end
end)

concommand.Add("hg_dev_get_decals",function(ply)
    local ent = ply:GetEyeTrace().Entity

    print(ent,#ent.m_decals)

    local compress = util.Compress(ent.m_decals_json)
    print(math.floor(string.len(compress) / 1024 * 100) / 100 .. ".kiloBytes")

    ent:SetupDecals(ent.m_decals)
end)