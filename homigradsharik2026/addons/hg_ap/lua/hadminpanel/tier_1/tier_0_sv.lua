adminPanelRole = ManagerCreate("adminPanelRole",{"node","node_network","node_network_user"})

adminPanelRole.list = adminPanelRole.list or {
    root = {hierarchy = 1,content = {name = "Root",success = {}}},
    user = {hierarchy = 1000,content = {name = "User",success = {}}}
}

adminPanelRole.listUser = adminPanelRole.listUser or {}

local PlayerMeta = FindMetaTable("Player")
local stockGetUserGroup = PlayerMeta.GetUserGroup

adminPanelRole.GetStockUserGroup = stockGetUserGroup

function adminPanelRole.HasSuccess(ply,successName)
    if not IsValid(ply) or not ply:IsPlayer() then return false end

    local group = stockGetUserGroup(ply)
    if group == "superadmin" or group == "admin" or group == "owner" then return true end

    local profile = Profiles and Profiles[ply:SteamID64()]
    for roleName in pairs(profile and profile.roles or {}) do
        if roleName == "root" then return true end

        local role = adminPanelRole.list[roleName]
        local access = role and role.content and role.content.success and role.content.success[successName]
        if access then return access end
    end

    local user = adminPanelRole.list.user
    local access = user and user.content and user.content.success and user.content.success[successName]
    if access then return access end

    return false
end
