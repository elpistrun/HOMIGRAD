--Прописываю тут потому-что не хочу отдавать файлом и лишний раз серв нагружать

adminPanel.successRegistry("role_list",nil,"rights")
adminPanel.successRegistry("lua_superadmin",nil,"rights")
adminPanel.successRegistry("lua_admin",nil,"rights")

local success = adminPanel.successRegistry("discord_role_name",nil,"rights")
success.parametrs = {
    {name = "role_name",type = "string"}
}

adminPanel.commandRegistry("role_create",{{type = "string",required = true}}):SetType("async"):SetCategory("roles")
adminPanel.commandRegistry("role_remove",{{type = "string",required = true}}):SetType("async"):SetCategory("roles")
adminPanel.commandRegistry("role_rename",{{type = "string",required = true},{type = "string",required = true}}):SetType("async"):SetCategory("roles")

adminPanel.commandRegistry("role_user_add",{{type = "steamid64",required = true},{type = "string",required = true}}):SetType("async"):SetCategory("roles")
adminPanel.commandRegistry("role_user_remove",{{type = "steamid64",required = true},{type = "string",required = true}}):SetType("async"):SetCategory("roles")

adminPanel.commandRegistry("role_success_set",{
{type = "string",name = "role",required = true},
{type = "string",name = "success",required = true},
{type = "bool",name = "access",required = true}
}):SetType("async"):SetCategory("roles")

adminPanel.commandRegistry("role_success_set_parametr",{
{type = "string",name = "role",required = true},
{type = "string",name = "success",required = true},
{type = "string",name = "parametr",required = true},
{type = "string",name = "value"}
}):SetType("async"):SetCategory("roles")

adminPanel.commandRegistry("role_set_inherit",{{type = "string",required = true},{type = "number",required = true}}):SetType("async"):SetCategory("roles")

adminPanel.commandRegistry("role_getsuccess",{{type = "string",required = true}}):SetCategory("roles")
adminPanel.commandRegistry("role_getlist"):SetCategory("roles")

adminPanel.commandRegistry("role_setcolor",{
    {type = "string",required = true},{type = "number",required = true},{type = "number",required = true},{type = "number",required = true}
}):SetType("async"):SetCategory("roles")

adminPanel.commandRegistry("role_settitle",{{type = "string",required = true},{type = "string"}}):SetType("async"):SetCategory("roles")

adminPanel.successRegistry("dontShowUserGroup",nil,"rights")
adminPanel.successRegistry("visibleHidenUserGroup",nil,"rights")

adminPanel.successRegistry("admin_chat_visible",nil,"rights")
adminPanel.commandRegistry("admin_chat",{{type = "line",required = true}},nil,"async","admin_operator").dontShowGUI = true

adminPanelRole:Event_Add("Update","Hierarchy",function()
    adminPanelRole.listHierarchy = {}
    
    for name,info in pairs(adminPanelRole.list) do
        adminPanelRole.listHierarchy[info.hierarchy] = name
    end

    adminPanelRole.listHierarchyIndex = {}
    
    for id,name in pairs(adminPanelRole.listHierarchy) do
        adminPanelRole.listHierarchyIndex[name] = id
    end
end,-100)

function adminPanelRole.GetFirstRole(roles)
    local roleFirst

    for name in pairs(roles or {}) do--lol
        if not adminPanelRole.listHierarchyIndex[name] then continue end
        
        if not roleFirst or adminPanelRole.listHierarchyIndex[roleFirst] > adminPanelRole.listHierarchyIndex[name] then roleFirst = name end
    end

    return roleFirst
end

function adminPanelRole.GetFirstRoleDisplay(roles)
    local roleFirst
    for name in pairs(roles or {}) do//lol
        if not adminPanelRole.listHierarchyIndex[name] or adminPanelRole.list[name].content.success.dontShowUserGroup then continue end
        
        if not roleFirst or adminPanelRole.listHierarchyIndex[roleFirst] > adminPanelRole.listHierarchyIndex[name] then roleFirst = name end
    end
    return roleFirst
end

function adminPanelRole.GetSuccessNeedRole(success)
    for id,nameRole in SortedPairs(adminPanelRole.listHierarchy,true) do
        if adminPanelRole.list[nameRole].content.success[success] then return nameRole end
    end
end

function adminPanelRole.GetName(name)
    return adminPanelRole.list[name] and adminPanelRole.list[name].content.name or name
end

--

local PLAYER = FindMetaTable("Player")

PLAYER.GetUserGroup = function(self)
    local profile = Profiles[self:SteamID64()]
    if not profile then return end

    return profile.roleFirst
end

PLAYER.GetUserGroupDisplay = function(self)
    local profile = Profiles[self:SteamID64()]
    if not profile then return end

    return profile.roleFirstDisplay
end

local color_gray = Color(125,125,125)

PLAYER.GetUserColor = function(self)
    local name = self:GetUserGroup()
    local color = Profiles[self:SteamID64()] and Profiles[self:SteamID64()].color
    if not color then return end

    -- Normalize whatever storage format the backend used (Color, {r,g,b}[],
    -- or 0..1 Vector) into a real Color so draw.SimpleText never sees a
    -- table without .r/.g/.b.
    if color.x ~= nil then
        local mul = color.x > 1 and color.y > 1 and color.z > 1 and 1 or 255
        return Color(color.x * mul,color.y * mul,color.z * mul)
    elseif color.r ~= nil then
        return Color(color.r,color.g,color.b)
    elseif color[1] ~= nil then
        return Color(color[1],color[2],color[3])
    end
end

PLAYER.GetUserName = function(self)
    local name = self:GetUserGroupDisplay()
    --if self:GetNWBool("DontShowMyPerm") and not LocalPlayer():HasSuccess("visibleHidenUserGroup") then return end

    return name and adminPanelRole.list[name] and adminPanelRole.list[name].content.name or name
end

PLAYER.HasSuccess = function(self,successName)
    return adminPanelRole.HasSuccess(self,successName)
end

PLAYER.IsSuperAdmin = function(self)
    return adminPanelRole.HasSuccess(self,"lua_superadmin")
end

PLAYER.IsAdmin = function(self)
    return adminPanelRole.HasSuccess(self,"lua_admin")
end

if SERVER then return end

cvars.CreateReplicateOption("hg_dontshowmyperms","0")