util.AddNetworkString("event_create")
util.AddNetworkString("hg_event_list")
util.AddNetworkString("hg_event_remove")

local path = "homigrad/events.json"
local events = util.JSONToTable(file.Read(path,"DATA") or "") or {}

local function Save()
    file.CreateDir("homigrad")
    file.Write(path,util.TableToJSON(events,true) or "{}")
end

local function CanManage(ply)
    return ply:IsSuperAdmin() or (ply.HasSuccess and ply:HasSuccess("eventplaning_access") == true)
end

local function Servers()
    return {{
        id = "local",
        name = GetHostName(),
        json = {origName = GetHostName(),name = GetHostName(),ip = game.GetIPAddress()}
    }}
end

local function Sync(target)
    net.Start("hg_event_list") net.WriteTable(events)
    if IsValid(target) then net.Send(target) else net.Broadcast() end
end

net.Receive("event_create",function(_,ply)
    if not CanManage(ply) then return end
    local request = net.ReadTable()
    if not istable(request) then return end

    if request.cmd == "open" then
        net.Start("event_create")
            net.WriteBool(true)
            net.WriteTable(Servers())
        net.Send(ply)
        return
    end

    local title = string.Trim(string.sub(tostring(request.title or ""),1,96))
    local desc = string.sub(tostring(request.desc or ""),1,2048)
    local period = request.period
    if title == "" or not istable(period) then return end
    local startTime = math.floor(tonumber(period[1]) or 0)
    local endTime = math.floor(tonumber(period[2]) or 0)
    if startTime < os.time() - 300 or endTime <= startTime or endTime - startTime > 86400 then return end

    local id = tostring(os.time()) .. "_" .. tostring(math.random(1000,9999))
    events[id] = {
        id = id,
        title = title,
        desc = desc,
        period = {startTime,endTime},
        friends = istable(request.friends) and request.friends or {},
        ping = request.ping == true,
        moderate = true,
        backgroundUrl = "",
        owner = {steamid64 = ply:SteamID64(),name = ply:Nick()},
        server = {id = "local",name = GetHostName(),ip = game.GetIPAddress()}
    }
    Save()
    Sync()
end)

net.Receive("hg_event_remove",function(_,ply)
    local id = string.sub(net.ReadString(),1,64)
    local data = events[id]
    if not data then return end
    if not CanManage(ply) and (not data.owner or data.owner.steamid64 ~= ply:SteamID64()) then return end
    events[id] = nil
    Save()
    Sync()
end)

hook.Add("PlayerInitialSpawn","HG Event List Sync",function(ply)
    timer.Simple(2,function() if IsValid(ply) then Sync(ply) end end)
end)

