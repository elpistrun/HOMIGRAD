adminPanelRole = ManagerCreate("adminPanelRole",{"node","node_network","node_network_user"})

adminPanelRole.list = adminPanelRole.list or {
    root = {content = {success = {}}},
    user = {content = {success = {}}}
}

adminPanelRole.listUser = adminPanelRole.listUser or {}

local PlayerMeta = FindMetaTable("Player")
local stockGetUserGroup = PlayerMeta.GetUserGroup

adminPanelRole.GetStockUserGroup = stockGetUserGroup

function adminPanelRole.HasSuccess(ply,successName)
    if not IsValid(ply) or not ply:IsPlayer() then return false end

    local group = stockGetUserGroup(ply)
    if group == "superadmin" or group == "admin" or group == "owner" then return true end

    return false
end