adminPanelRole = ManagerCreate("adminPanelRole",{"node","node_network","node_network_user"})

adminPanelRole.list = adminPanelRole.list or {
    root = {content = {success = {}}},
    user = {content = {success = {}}}
}

adminPanelRole.listUser = adminPanelRole.listUser or {}

net.ReceiveMediaToken("admin_panel_roles",function(body)
    adminPanelRole.list = JSONToTable(body)
    
    for name in pairs(adminPanelRole.list) do
        adminPanelRole.listUser[name] = adminPanelRole.listUser[name] or {}
    end

    adminPanelRole:Event_Call("Update")
end)

net.ReceiveMediaToken("admin_panel_list",function(body)
    adminPanelRole.listUser = JSONToTable(body)

    adminPanelRole:Event_Call("Update List")
end)

local empty = {}

function adminPanelRole.HasSuccess(ply,successName)
    if not IsValid(ply) or not ply.SteamID64 then return false end

    local profile = Profiles[ply:SteamID64()]
    
    for name in pairs(profile and profile.roles or empty) do
        if name == "root" then return true end

        local role = adminPanelRole.list[name]
        if not role then continue end
        
        local success = role.content.success[successName]
        if success then return success end
    end

    local success = adminPanelRole.list["user"].content.success[successName]
    if success then return success end

    return false
end

function adminPanelRole.HasDominate(caller,target,isEquial)
    local callerRole = adminPanelRole.GetFirstRole(caller.roles)
    local targetRole = adminPanelRole.GetFirstRole(target.roles)

    if adminPanelRole.listHierarchyIndex[callerRole] >= adminPanelRole.listHierarchyIndex[targetRole] then return true end
    if isEquial and adminPanelRole.listHierarchyIndex[callerRole] == adminPanelRole.listHierarchyIndex[targetRole] then return true end

    return false
end