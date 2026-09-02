net.Receive("hg_ap_roles_sync",function()
    adminPanelRole.list = net.ReadTable()
    adminPanelRole.listUser = net.ReadTable()
    local assignments = net.ReadTable()

    Profiles = Profiles or {}
    for steamid64,roles in pairs(assignments) do
        Profiles[steamid64] = Profiles[steamid64] or {}
        Profiles[steamid64].roles = roles
    end

    adminPanelRole:Event_Call("Update")
    adminPanelRole:Event_Call("Update List")
end)
