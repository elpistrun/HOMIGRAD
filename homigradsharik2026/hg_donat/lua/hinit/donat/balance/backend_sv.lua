-- Local persistent balance backend for the standalone addon build.
local storeDir = "hg_donat"
local storePath = storeDir .. "/balances.json"
local balances = util.JSONToTable(file.Read(storePath,"DATA") or "") or {}

file.CreateDir(storeDir)

util.AddNetworkString("balance_user")
util.AddNetworkString("hg_balance_sync")
util.AddNetworkString("hg_balance_request")

local function Get(steamid64)
    steamid64 = tostring(steamid64 or "")
    balances[steamid64] = balances[steamid64] or {balance = 0,balance_donat = 0}
    balances[steamid64].balance = tonumber(balances[steamid64].balance) or 0
    balances[steamid64].balance_donat = tonumber(balances[steamid64].balance_donat) or 0
    return balances[steamid64]
end

local function Save()
    file.Write(storePath,util.TableToJSON(balances,true) or "{}")
end

local function Send(ply,steamid64)
    if not IsValid(ply) then return end
    steamid64 = tostring(steamid64 or ply:SteamID64())

    net.Start("hg_balance_sync")
        net.WriteTable({[steamid64] = Get(steamid64)})
    net.Send(ply)
end

local function Broadcast(steamid64)
    for _,ply in ipairs(player.GetAll()) do
        if ply:SteamID64() == steamid64 or ply:IsSuperAdmin() then Send(ply,steamid64) end
    end
end

net.Receive("hg_balance_request",function(_,ply)
    Send(ply)
end)

-- Keep the coroutine request channel valid for legacy UI calls.
net.Receive("balance_user",function(_,ply)
    local sessionId = net.ReadInt(7)
    local request = net.ReadTable()
    local success,msg = false,"unsupported balance request"

    if istable(request) and request.cmd == "get" then
        Send(ply)
        success,msg = true,""
    end

    net.Start("balance_user")
        net.WriteInt(sessionId,7)
        net.WriteBool(success)
        net.WriteString(msg)
    net.Send(ply)
end)

hook.Add("PlayerInitialSpawn","HG Balance Sync",function(ply)
    Get(ply:SteamID64())
    Save()
    timer.Simple(2,function() if IsValid(ply) then Send(ply) end end)
end)

local function ChangeBalance(caller,steamid64,amount,field,add)
    steamid64 = tostring(steamid64 or "")
    amount = tonumber(amount)
    if not string.match(steamid64,"^%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d$") or not amount then
        if IsValid(caller) then caller:ChatPrint("[HG Balance] Неверный SteamID64 или сумма.") end
        return
    end

    amount = math.Clamp(amount,-1000000000,1000000000)
    local data = Get(steamid64)
    data[field] = math.max(add and data[field] + amount or amount,0)
    Save()
    Broadcast(steamid64)

    if IsValid(caller) then
        caller:ChatPrint("[HG Balance] " .. steamid64 .. " / " .. field .. " = " .. tostring(data[field]))
    end
end

timer.Simple(0,function()
    if not adminPanel or not adminPanel.commandCreate then return end

    adminPanel.commandCreate("balance_set",function(caller,steamid64,amount)
        ChangeBalance(caller,steamid64,amount,"balance",false)
    end,nil,nil,"rcon")

    adminPanel.commandCreate("balance_add",function(caller,steamid64,amount)
        ChangeBalance(caller,steamid64,amount,"balance",true)
    end,nil,nil,"rcon")

    adminPanel.commandCreate("balance_donat_set",function(caller,steamid64,amount)
        ChangeBalance(caller,steamid64,amount,"balance_donat",false)
    end,nil,nil,"rcon")

    adminPanel.commandCreate("balance_donat_add",function(caller,steamid64,amount)
        ChangeBalance(caller,steamid64,amount,"balance_donat",true)
    end,nil,nil,"rcon")
end)

-- Expose balance operations for the shop handler (deferred until all modules load)
timer.Simple(0,function()
    donatPanel = donatPanel or {}
    donatPanel.GetBalance = Get
    donatPanel.SaveBalance = Save
    donatPanel.BroadcastBalance = Broadcast
end)

