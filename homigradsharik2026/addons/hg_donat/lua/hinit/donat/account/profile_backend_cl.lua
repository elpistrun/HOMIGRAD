net.Receive("hg_profile_local_sync",function()
    Profiles = Profiles or {}

    for steamid64,data in pairs(net.ReadTable() or {}) do
        Profiles[steamid64] = table.Merge(Profiles[steamid64] or {},data)

        if outfitManager then
            outfitManager.listData = outfitManager.listData or {}
            outfitManager.listData[steamid64] = table.Merge(outfitManager.listData[steamid64] or {},data)
        end

        if profileManager then profileManager:Event_Call("Update",steamid64,Profiles[steamid64]) end
    end
end)

