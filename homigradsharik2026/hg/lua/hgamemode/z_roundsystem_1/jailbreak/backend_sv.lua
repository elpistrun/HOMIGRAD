-- Jailbreak server backend
-- Handles ranks, guilt toggle, door/point net messages, admin commands

-- Create jailbreakManager on server (client creates it in rank_sh.lua)
jailbreakManager = ManagerCreate("jailbreakManager",{"node"})
jailbreakManager.listUser = jailbreakManager.listUser or {}

-- Network strings
util.AddNetworkString("jailbreak_door")
util.AddNetworkString("jailbreak_point")

-- Data persistence
local savePath = "homigrad/jailbreak.json"

local function LoadData()
    local data = file.Read(savePath,"DATA")
    if data then
        local ok,result = pcall(util.JSONToTable,data)
        if ok and result then
            jailbreakManager.listUser = result
        end
    end
end

local function SaveData()
    file.Write(savePath,util.TableToJSON(jailbreakManager.listUser))
end

local function BroadcastRanks()
    net.Start("jailbreak_ranks_data")
    net.WriteString(util.TableToJSON(jailbreakManager.listUser))
    net.Broadcast()
end

util.AddNetworkString("jailbreak_ranks_data")

LoadData()

-- Sync ranks to players on connect
gameevent.Listen("player_connect")
hook.Add("player_connect","JailbreakRanks",function(data)
    timer.Simple(1,function()
        for _,ply in ipairs(player.GetAll()) do
            if ply:SteamID64() == tostring(data.networkid) or ply:UserID() == data.userid then
                local rankID = jailbreakManager.listUser[ply:SteamID64()]
                if rankID then
                    ply:SetNWString("JailBreakRank",tostring(rankID))
                end
                break
            end
        end
    end)
end)

-- Also sync on spawn for reliability
hook.Add("PlayerSpawn","JailbreakRankSync",function(ply)
    local rankID = jailbreakManager.listUser[ply:SteamID64()]
    if rankID then
        ply:SetNWString("JailBreakRank",tostring(rankID))
    else
        ply:SetNWString("JailBreakRank","0")
    end

    -- Send ranks data to client
    timer.Simple(0,function()
        if not IsValid(ply) then return end
        net.Start("jailbreak_ranks_data")
        net.WriteString(util.TableToJSON(jailbreakManager.listUser))
        net.Send(ply)
    end)
end)

-- Receive ranks data request from client
net.Receive("jailbreak_ranks_data",function(_,ply)
    net.Start("jailbreak_ranks_data")
    net.WriteString(util.TableToJSON(jailbreakManager.listUser))
    net.Send(ply)
end)

-- Client requests rank data
jailbreakManager.GetRank = function(self,ply)
    if not IsValid(ply) then return end
    local rankID = ply:GetNWString("JailBreakRank","0")
    if not rankID or rankID == "0" then return end

    local rank = level_jailbreak and level_jailbreak.ranksList[tonumber(rankID)]
    return rank,rankID
end

-- Admin command handlers
local cmd = adminPanel.commands["jailbreak_add"]
if cmd then
    cmd.func = function(ply,steamid64,rankID)
        if not IsValid(ply) or not steamid64 then return end

        rankID = tonumber(rankID) or 0

        if rankID > 0 and not level_jailbreak.ranksList[rankID] then
            ply:ChatPrint("[Jailbreak] Неверный ранг: " .. tostring(rankID))
            return
        end

        if rankID == 0 then
            jailbreakManager.listUser[steamid64] = nil
        else
            jailbreakManager.listUser[steamid64] = rankID
        end

        SaveData()

        -- Update player NWString if online
        for _,p in ipairs(player.GetAll()) do
            if p:SteamID64() == tostring(steamid64) then
                p:SetNWString("JailBreakRank",tostring(rankID))
                break
            end
        end

        BroadcastRanks()
        ply:ChatPrint("[Jailbreak] Ранг обновлён для " .. tostring(steamid64) .. " → " .. tostring(rankID))
    end
end

local cmd = adminPanel.commands["jailbreak_ranks"]
if cmd then
    cmd.func = function(ply)
        if not IsValid(ply) then return end
        BroadcastRanks()
        ply:ChatPrint("[Jailbreak] Список рангов отправлен (" .. table.Count(jailbreakManager.listUser) .. " записей)")
    end
end

local cmd = adminPanel.commands["jailbreak_ban"]
if cmd then
    cmd.func = function(ply,steamid64,reason)
        if not IsValid(ply) or not steamid64 then return end

        jailbreakManager.bans = jailbreakManager.bans or {}
        jailbreakManager.bans[steamid64] = reason or "Не указан"
        SaveData()

        -- Kick if online
        for _,p in ipairs(player.GetAll()) do
            if p:SteamID64() == tostring(steamid64) then
                p:Kick("Забанен в Jailbreak: " .. (reason or "Не указана причина"))
                break
            end
        end

        ply:ChatPrint("[Jailbreak] " .. tostring(steamid64) .. " забанен")
    end
end

local cmd = adminPanel.commands["jailbreak_unban"]
if cmd then
    cmd.func = function(ply,steamid64)
        if not IsValid(ply) or not steamid64 then return end

        jailbreakManager.bans = jailbreakManager.bans or {}
        jailbreakManager.bans[steamid64] = nil
        SaveData()

        ply:ChatPrint("[Jailbreak] " .. tostring(steamid64) .. " разбанен")
    end
end

-- Guilt toggle (anti-RDM)
concommand.Add("hg_jailbreak_noguilt",function(ply)
    if not IsValid(ply) or not ply:Alive() then return end
    if ply:Team() ~= 1 then return end

    local current = GetGlobalBool("JailBreakAntiRDM",false)
    SetGlobalBool("JailBreakAntiRDM",not current)

    for _,p in ipairs(player.GetAll()) do
        p:ChatPrint("[Jailbreak] Guilt " .. (not current and "Включён" or "Выключен"))
    end
end)

-- Door handler (guards open doors with middle click)
net.Receive("jailbreak_door",function(_,ply)
    if not IsValid(ply) or not ply:Alive() or ply:Team() ~= 1 then return end

    local ent = net.ReadEntity()
    if not IsValid(ent) or ent:GetClass() ~= "func_door" then return end
    if ply:EyePos():Distance(ent:GetPos()) > 500 then return end

    ent:Fire("Open","",0)
    ent:Fire("SetSpeed","100",0)
end)

-- Rally point handler (guards set rally point with middle click on ground)
net.Receive("jailbreak_point",function(_,ply)
    if not IsValid(ply) or not ply:Alive() or ply:Team() ~= 1 then return end

    local pos = net.ReadVector()
    if not pos or not isvector(pos) then return end
    if ply:EyePos():Distance(pos) > 1000 then return end

    -- Find nearest named landmark
    local pointName = "Точка на карте"

    -- Broadcast to all players
    net.Start("jailbreak_point")
    net.WriteVector(pos)
    net.WriteString(pointName)
    net.Broadcast()
end)
