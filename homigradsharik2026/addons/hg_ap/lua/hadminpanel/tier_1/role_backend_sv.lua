local DATA_DIR = "hg_ap"
local DATA_FILE = DATA_DIR .. "/roles.json"

file.CreateDir(DATA_DIR)
Profiles = Profiles or {}

local stored = util.JSONToTable(file.Read(DATA_FILE,"DATA") or "") or {}
adminPanelRole.list = stored.roles or adminPanelRole.list or {}
adminPanelRole.listUser = stored.users or adminPanelRole.listUser or {}

adminPanelRole.list.root = adminPanelRole.list.root or {hierarchy = 1,content = {}}
adminPanelRole.list.user = adminPanelRole.list.user or {hierarchy = 1000,content = {}}

local function NormalizeRole(role,name,defaultHierarchy)
    role.hierarchy = tonumber(role.hierarchy) or defaultHierarchy or 500
    role.content = role.content or {}
    role.content.name = role.content.name or name
    role.content.success = role.content.success or {}
    role.content.color = role.content.color or {r = 255,g = 255,b = 255,a = 255}
end

NormalizeRole(adminPanelRole.list.root,"Root",1)
NormalizeRole(adminPanelRole.list.user,"User",1000)
for name,role in pairs(adminPanelRole.list) do NormalizeRole(role,name,500) end

local function RebuildUsers()
    adminPanelRole.listUser = {}

    for steamid64,profile in pairs(Profiles) do
        for roleName in pairs(profile.roles or {}) do
            adminPanelRole.listUser[roleName] = adminPanelRole.listUser[roleName] or {}
            adminPanelRole.listUser[roleName][steamid64] = {id = steamid64}
        end
    end
end

for steamid64,roles in pairs(stored.assignments or {}) do
    Profiles[steamid64] = Profiles[steamid64] or {}
    Profiles[steamid64].roles = roles
end

local function Save()
    local assignments = {}
    for steamid64,profile in pairs(Profiles) do
        if profile.roles and next(profile.roles) then assignments[steamid64] = profile.roles end
    end

    file.Write(DATA_FILE,util.TableToJSON({
        roles = adminPanelRole.list,
        users = adminPanelRole.listUser,
        assignments = assignments
    },true) or "{}")
end

util.AddNetworkString("hg_ap_roles_sync")

local function Sync(target)
    local assignments = {}
    for steamid64,profile in pairs(Profiles) do
        assignments[steamid64] = profile.roles or {}
    end

    net.Start("hg_ap_roles_sync")
    net.WriteTable(adminPanelRole.list)
    net.WriteTable(adminPanelRole.listUser)
    net.WriteTable(assignments)
    if IsValid(target) then net.Send(target) else net.Broadcast() end

    adminPanelRole:Event_Call("Update")
    adminPanelRole:Event_Call("Update List")
end

local function Commit(message,caller)
    Save()
    Sync()
    if IsValid(caller) and message then caller:ChatPrint("[HG admin] " .. message) end
end

local function ValidName(name)
    name = string.Trim(tostring(name or ""))
    if name == "" or #name > 64 or string.find(name,"[\r\n%z]") then return end
    return name
end

local function Role(name)
    return adminPanelRole.list[tostring(name or "")]
end

local function RegisterCommands()
    adminPanel.commandCreate("role_create",function(caller,name)
        name = ValidName(name)
        if not name or Role(name) then return end
        adminPanelRole.list[name] = {hierarchy = 500,content = {name = name,success = {},color = {r=255,g=255,b=255,a=255}}}
        adminPanelRole.listUser[name] = {}
        Commit("Роль создана: " .. name,caller)
    end,"async",nil,"roles")

    adminPanel.commandCreate("role_remove",function(caller,name)
        name = tostring(name or "")
        if name == "root" or name == "user" or not Role(name) then return end
        adminPanelRole.list[name] = nil
        adminPanelRole.listUser[name] = nil
        for _,profile in pairs(Profiles) do if profile.roles then profile.roles[name] = nil end end
        Commit("Роль удалена: " .. name,caller)
    end,"async",nil,"roles")

    adminPanel.commandCreate("role_rename",function(caller,oldName,newName)
        oldName,newName = tostring(oldName or ""),ValidName(newName)
        if oldName == "root" or oldName == "user" or not newName or Role(newName) then return end
        local role = Role(oldName) if not role then return end
        adminPanelRole.list[newName] = role adminPanelRole.list[oldName] = nil
        adminPanelRole.listUser[newName] = adminPanelRole.listUser[oldName] or {}
        adminPanelRole.listUser[oldName] = nil
        for _,profile in pairs(Profiles) do
            if profile.roles and profile.roles[oldName] then profile.roles[oldName] = nil profile.roles[newName] = true end
        end
        Commit("Роль переименована: " .. oldName .. " -> " .. newName,caller)
    end,"async",nil,"roles")

    adminPanel.commandCreate("role_user_add",function(caller,steamid64,roleName)
        steamid64,roleName = tostring(steamid64 or ""),tostring(roleName or "")
        if not string.match(steamid64,"^%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d$") or not Role(roleName) then return end
        local profile = Profiles[steamid64] or {} Profiles[steamid64] = profile
        profile.roles = profile.roles or {} profile.roles[roleName] = true
        adminPanelRole.listUser[roleName] = adminPanelRole.listUser[roleName] or {}
        adminPanelRole.listUser[roleName][steamid64] = {id = steamid64}
        Commit("Роль " .. roleName .. " выдана " .. steamid64,caller)
    end,"async",nil,"roles")

    adminPanel.commandCreate("role_user_remove",function(caller,steamid64,roleName)
        steamid64,roleName = tostring(steamid64 or ""),tostring(roleName or "")
        local profile = Profiles[steamid64]
        if profile and profile.roles then profile.roles[roleName] = nil end
        if adminPanelRole.listUser[roleName] then adminPanelRole.listUser[roleName][steamid64] = nil end
        Commit("Роль " .. roleName .. " снята с " .. steamid64,caller)
    end,"async",nil,"roles")

    adminPanel.commandCreate("role_success_set",function(caller,roleName,successName,access)
        local role = Role(roleName) if not role then return end
        successName = tostring(successName or "") if successName == "" or #successName > 96 then return end
        local enabled = access == true or access == 1 or access == "1" or access == "true"
        role.content.success[successName] = enabled and (role.content.success[successName] or true) or nil
        Commit(nil,caller)
    end,"async",nil,"roles")

    adminPanel.commandCreate("role_success_set_parametr",function(caller,roleName,successName,parametr,value)
        local role = Role(roleName) if not role then return end
        local access = role.content.success[tostring(successName or "")]
        if access == true then access = {} role.content.success[successName] = access end
        if not istable(access) then return end
        local key = tonumber(parametr) or tostring(parametr or "")
        if value == nil or value == "" then access[key] = nil else access[key] = value end
        Commit(nil,caller)
    end,"async",nil,"roles")

    adminPanel.commandCreate("role_set_inherit",function(caller,roleName,hierarchy)
        local role = Role(roleName) if not role then return end
        role.hierarchy = math.Clamp(math.floor(tonumber(hierarchy) or 500),1,10000)
        Commit(nil,caller)
    end,"async",nil,"roles")

    adminPanel.commandCreate("role_setcolor",function(caller,roleName,r,g,b)
        local role = Role(roleName) if not role then return end
        role.content.color = {r=math.Clamp(tonumber(r) or 255,0,255),g=math.Clamp(tonumber(g) or 255,0,255),b=math.Clamp(tonumber(b) or 255,0,255),a=255}
        Commit(nil,caller)
    end,"async",nil,"roles")

    adminPanel.commandCreate("role_settitle",function(caller,roleName,title)
        local role = Role(roleName) if not role then return end
        role.content.name = string.sub(tostring(title or roleName),1,128)
        Commit(nil,caller)
    end,"async",nil,"roles")

    adminPanel.commandCreate("role_getsuccess",function(caller,roleName)
        local role = Role(roleName)
        caller:ChatPrint(role and util.TableToJSON(role.content.success) or "Роль не найдена")
    end,nil,nil,"roles")

    adminPanel.commandCreate("role_getlist",function(caller)
        Sync(caller)
        caller:ChatPrint("[HG admin] Ролей: " .. table.Count(adminPanelRole.list))
    end,nil,nil,"roles")

    adminPanel.commandCreate("admin_chat",function(caller,text)
        text = string.sub(tostring(text or ""),1,512)
        for _,ply in ipairs(player.GetAll()) do
            if ply:HasSuccess("admin_chat_visible") or ply:IsAdmin() then
                ply:ChatPrint("[ADMIN] " .. caller:Nick() .. ": " .. text)
            end
        end
    end,"async",nil,"admin_operator")
end

timer.Simple(0,function()
    RebuildUsers()
    adminPanelRole:Event_Call("Update")
    RegisterCommands()
    Save()
end)

hook.Add("PlayerInitialSpawn","HG AP Role Sync",function(ply)
    timer.Simple(1,function() Sync(ply) end)
end)
