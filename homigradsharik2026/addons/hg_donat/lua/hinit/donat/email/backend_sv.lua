-- Local email backend. Stores emails per player in DATA and handles
-- client requests (read, claim, delete, send, edit) through the
-- email_user coroutine channel.
local STORE_DIR = "hg_donat"
local STORE_FILE = STORE_DIR .. "/emails.json"

file.CreateDir(STORE_DIR)

local emails = util.JSONToTable(file.Read(STORE_FILE,"DATA") or "") or {}

local function Save()
    file.Write(STORE_FILE,util.TableToJSON(emails,true) or "{}")
end

local function GetEmails(steamid64)
    steamid64 = tostring(steamid64 or "")
    emails[steamid64] = emails[steamid64] or {}
    return emails[steamid64]
end

local function NextId(emailList)
    local highest = 0
    for id in pairs(emailList) do highest = math.max(highest,tonumber(id) or 0) end
    return tostring(highest + 1)
end

local function NormalizeEmail(raw,steamid64,id)
    if not istable(raw) then return end
    local content = istable(raw.content) and raw.content or {}
    return {
        id = tostring(id),
        steamid64 = steamid64,
        is_read = raw.is_read == true,
        timestamp = tonumber(raw.timestamp) or os.time(),
        content = {
            name = tostring(content.name or ""),
            desc = tostring(content.desc or ""),
            html = tostring(content.html or "")
        }
    }
end

-- Send full email data to a player
local function SendFull(ply)
    if not IsValid(ply) then return end

    local data = {[ply:SteamID64()] = GetEmails(ply:SteamID64())}
    if ply:IsSuperAdmin() or (ply.HasSuccess and ply:HasSuccess("donat_moderate")) then
        data = emails
    end

    net.Start("email_server")
        net.WriteString("full")
        net.WriteString(util.TableToJSON(data) or "{}")
    net.Send(ply)
end

-- Send single email update to relevant players
local function BroadcastEmail(steamid64,email)
    for _,ply in ipairs(player.GetAll()) do
        if ply:SteamID64() == steamid64 or ply:IsSuperAdmin() or (ply.HasSuccess and ply:HasSuccess("donat_moderate")) then
            net.Start("email_server")
                net.WriteString("update")
                net.WriteString(util.TableToJSON(email) or "{}")
            net.Send(ply)
        end
    end
end

-- Send delete notification to relevant players
local function BroadcastDelete(steamid64,emailId)
    for _,ply in ipairs(player.GetAll()) do
        if ply:SteamID64() == steamid64 or ply:IsSuperAdmin() or (ply.HasSuccess and ply:HasSuccess("donat_moderate")) then
            net.Start("email_server")
                net.WriteString("delete")
                net.WriteString(steamid64)
                net.WriteString(tostring(emailId))
            net.Send(ply)
        end
    end
end

-- Create the manager on the server so node_network and node_network_user Init fires
emailManager = emailManager or ManagerCreate("email",{"node","node_network","node_network_user"})

-- Handle client requests via email_user channel
function emailManager:InputServer(ply)
    local cmd = net.ReadString()
    local steamid64 = ply:SteamID64()

    if cmd == "read" then
        local emailId = tostring(net.ReadInt(32))
        local list = GetEmails(steamid64)
        local email = list[emailId]
        if not email then return false,"email not found" end

        email.is_read = true
        Save()
        BroadcastEmail(steamid64,email)

        return true,""

    elseif cmd == "claim" then
        local emailId = tostring(net.ReadInt(32))
        local list = GetEmails(steamid64)
        local email = list[emailId]
        if not email then return false,"email not found" end

        email.is_read = true
        email.claimed = true
        Save()
        BroadcastEmail(steamid64,email)

        return true,""

    elseif cmd == "delete" then
        local targetSteam = net.ReadString()
        local emailId = tostring(net.ReadInt(32))

        if not ply:IsSuperAdmin() and not (ply.HasSuccess and ply:HasSuccess("donat_moderate")) then
            if targetSteam ~= steamid64 then return false,"permission denied" end
        end

        local list = GetEmails(targetSteam)
        if not list[emailId] then return false,"email not found" end

        list[emailId] = nil
        Save()
        BroadcastDelete(targetSteam,emailId)

        return true,""

    elseif cmd == "send" then
        if not ply:IsSuperAdmin() and not (ply.HasSuccess and ply:HasSuccess("donat_moderate")) then
            return false,"permission denied"
        end

        local data = net.ReadTable()
        if not istable(data) or not istable(data.steamid64List) or not istable(data.email) then
            return false,"invalid data"
        end

        local emailContent = data.email.content or data.email
        for _,targetSteam in ipairs(data.steamid64List) do
            targetSteam = tostring(targetSteam)
            local list = GetEmails(targetSteam)
            local id = NextId(list)
            local email = NormalizeEmail({
                content = emailContent,
                timestamp = os.time()
            },targetSteam,id)

            list[id] = email
            BroadcastEmail(targetSteam,email)
        end

        Save()
        return true,""

    elseif cmd == "edit" then
        if not ply:IsSuperAdmin() and not (ply.HasSuccess and ply:HasSuccess("donat_moderate")) then
            return false,"permission denied"
        end

        local targetSteam = net.ReadString()
        local emailId = tostring(net.ReadInt(32))
        local content = net.ReadTable()

        local list = GetEmails(targetSteam)
        local email = list[emailId]
        if not email then return false,"email not found" end

        if istable(content) then
            email.content.name = tostring(content.name or email.content.name)
            email.content.desc = tostring(content.desc or email.content.desc)
            email.content.html = tostring(content.html or email.content.html)
        end

        Save()
        BroadcastEmail(targetSteam,email)

        return true,""
    end

    return false,"unknown command"
end

-- Send emails on player spawn
hook.Add("PlayerInitialSpawn","HG Email Sync",function(ply)
    timer.Simple(3,function()
        if IsValid(ply) then SendFull(ply) end
    end)
end)

-- Expose email API for other systems
timer.Simple(0,function()
    emailManager.SendEmail = function(self,toSteamid64,emailData)
        toSteamid64 = tostring(toSteamid64)
        local list = GetEmails(toSteamid64)
        local id = NextId(list)
        local email = NormalizeEmail(emailData,toSteamid64,id)
        list[id] = email
        Save()
        BroadcastEmail(toSteamid64,email)
        return email
    end
end)
