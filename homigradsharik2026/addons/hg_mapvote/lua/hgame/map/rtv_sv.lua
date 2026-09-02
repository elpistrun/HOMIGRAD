-- hg_mapvote/lua/hgame/map/rtv_sv.lua
-- Server-side RTV (Rock The Vote) engine for map changes.
--
-- The client UI (ui_1mapvote_cl.lua / init_cl.lua) already speaks a fixed
-- net protocol. This file implements the missing server half:
--   - maintain the vote state (RTVVote / RTVVoteNumber / RTVLeaders)
--   - respond to "rtv vote" and "rtv add map"
--   - broadcast "rtv status" / "rtv notify" / "rtv maps list"
--   - admin commands rtv_start / rtv_end / nortv
--   - player !rtv trigger
--   - forced RTV after a configured number of rounds
--   - changelevel to the winning map on resolution

if not SERVER then return end

util.AddNetworkString("rtv vote")
util.AddNetworkString("rtv add map")
util.AddNetworkString("rtv notify")
util.AddNetworkString("rtv status")
util.AddNetworkString("rtv maps list")

-- Configuration --------------------------------------------------------------
local RTV_RoundsForced = 15      -- force an RTV vote after this many rounds
local RTV_VoteTime     = 30      -- seconds a vote stays open before resolving
local RTV_Cooldown     = 120     -- minimum seconds between player-triggered RTVs
local RTV_MapsDir      = "maps/*.bsp"

-- State ----------------------------------------------------------------------
RTVStatus     = nil              -- nil | "vote" | "random"
RTVVote       = {}               -- [map] = { [steamid64] = {avatar=,avatarFrame=} }
RTVVoteNumber = {}
RTVVoteMax    = 0
RTVLeaders    = {}

local rtvRounds      = 0         -- completed rounds since last forced vote
local rtvNoVote      = false     -- nortv toggle
local rtvLastStart   = 0         -- CurTime of the last player-triggered start
local rtvMaps        = {}        -- cached votable map names (array)

-- Forward declaration: the RTVResolve timer (created in RTVCreateVote below)
-- references RTVEndVote before its definition, so it must be a lexically
-- visible upvalue rather than a global.
local RTVEndVote

local function RTVResolveMaps()
    rtvMaps = {}

    local cur = game.GetMap()
    local files = file.Find(RTV_MapsDir, "GAME")

    if files then
        for _, f in ipairs(files) do
            local name = string.sub(f, 1, -5) -- strip ".bsp"
            if name != "" and name != cur then rtvMaps[#rtvMaps + 1] = name end
        end
    end

    table.sort(rtvMaps)
    return rtvMaps
end

local function RTVIsValidMap(map)
    for _, m in ipairs(rtvMaps) do if m == map then return true end end
    return false
end

-- Networking helpers ---------------------------------------------------------
local function RTVNotify(ply, text, color)
    if not IsValid(ply) then return end
    net.Start("rtv notify")
        net.WriteString(text)
        net.WriteColor(color or Color(255,255,255))
    net.Send(ply)
end

local function RTVNotifyAll(text, color)
    net.Start("rtv notify")
        net.WriteString(text)
        net.WriteColor(color or Color(255,255,255))
    net.Broadcast()
end

local function RTVSendMapsList(ply)
    if #rtvMaps == 0 then RTVResolveMaps() end

    net.Start("rtv maps list")
        net.WriteTable(rtvMaps)
    if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

-- Returns the vote with the most votes (the leading map). Used only to decide
-- the resolution; the client recomputes "leaders" for display from RTVVote.
local function RTVGetWinner()
    local best, winner = -1, nil

    for vote, list in pairs(RTVVote) do
        local n = table.Count(list)
        if n > best then best, winner = n, vote end
    end

    return winner
end

local function RTVBroadcastStatus()
    if RTVStatus == "vote" then
        RTVLeaders = { RTVGetWinner() }

        RTVVoteNumber = {}
        local max = 0
        for vote, list in pairs(RTVVote) do
            local n = table.Count(list)
            RTVVoteNumber[vote] = n
            max = max + n
        end
        RTVVoteMax = max

        net.Start("rtv status")
            net.WriteString("vote")
            net.WriteTable(RTVVote)
        net.Broadcast()
    elseif RTVStatus == "random" then
        net.Start("rtv status")
            net.WriteString("random")
            net.WriteTable({})
            net.WriteString("")
            net.WriteString("0")
            net.WriteString("0")
        net.Broadcast()
    else
        net.Start("rtv status")
            net.WriteString("")
        net.Broadcast()
    end
end

-- Vote lifecycle -------------------------------------------------------------
local function RTVCreateVote(force)
    if rtvNoVote and force ~= true then return false end

    RTVResolveMaps()
    if #rtvMaps == 0 then
        RTVNotifyAll("rtv_cant_no_maps", Color(255,80,80))
        return false
    end

    RTVStatus = "vote"
    RTVVote = {}

    -- Seed the vote list with every installed map so the client "Vote" page
    -- shows all candidates right away (each with 0 votes). "extend"/"random"
    -- are special keys and only appear once someone votes for them.
    for _, map in ipairs(rtvMaps) do RTVVote[map] = {} end

    RTVVoteNumber = {}
    RTVVoteMax = 0
    RTVLeaders = {}

    SetGlobalString("RTVTitle", "rtv_title")
    SetGlobalFloat("RTVStart", CurTime())
    SetGlobalFloat("RTVTime", RTV_VoteTime)

    RTVSendMapsList()
    RTVBroadcastStatus()

    timer.Remove("RTVResolve")
    timer.Create("RTVResolve", RTV_VoteTime, 1, function()
        if RTVStatus == "vote" then RTVEndVote() end
    end)

    return true
end

local function RTVPickRandomMap()
    if #rtvMaps == 0 then return nil end
    return rtvMaps[math.random(1, #rtvMaps)]
end

RTVEndVote = function()
    timer.Remove("RTVResolve")

    local status = RTVStatus
    RTVStatus = nil

    if status == "vote" then
        local winner = RTVGetWinner()

        if not winner or winner == "extend" then
            -- Extend (or nobody voted): stay on the current map.
            RTVNotifyAll("rtv_extend", Color(120,255,120))
        else
            if winner == "random" then
                winner = RTVPickRandomMap()
            end

            winner = winner or RTVPickRandomMap()

            if winner then
                RTVNotifyAll("rtv_changemap", Color(255,255,255))
                rtvRounds = 0
                timer.Simple(3, function() RunConsoleCommand("changelevel", winner) end)
            end
        end

        rtvRounds = 0
    elseif status == "random" then
        local winner = RTVPickRandomMap()
        if winner then
            rtvRounds = 0
            timer.Simple(3, function() RunConsoleCommand("changelevel", winner) end)
        end
    end

    RTVVote = {}
    RTVVoteNumber = {}
    RTVVoteMax = 0
    RTVLeaders = {}

    -- Tell every client to close the vote frame (blur disappears together
    -- with the frame), for every outcome: extend, changelevel, rtv_end, etc.
    net.Start("rtv status")
        net.WriteString("")
    net.Broadcast()
end

local function RTVClose()
    timer.Remove("RTVResolve")
    RTVStatus = nil

    net.Start("rtv status")
        net.WriteString("")
    net.Broadcast()
end

-- Player votes ---------------------------------------------------------------
net.Receive("rtv vote", function(len, ply)
    if not IsValid(ply) then return end
    if RTVStatus ~= "vote" then return end

    local vote = net.ReadString()

    local steamid64 = ply:SteamID64()
    local old
    for oldMap, list in pairs(RTVVote) do
        if list[steamid64] then old = oldMap break end
    end

    if vote == "extend" then
        vote = "extend"
    elseif vote == "random" then
        vote = "random"
    elseif not RTVIsValidMap(vote) then
        RTVNotify(ply, "rtv_cant_invalid", Color(255,120,80))
        return
    end

    if old and old == vote then
        -- Unvote. Real maps keep their seeded entry so the icon stays visible
        -- with 0%; only the special extend/random entries vanish when empty.
        RTVVote[old][steamid64] = nil
        if next(RTVVote[old]) == nil and (old == "extend" or old == "random") then RTVVote[old] = nil end

        RTVNotify(ply, "rtv_unvote_done", Color(255,255,255))
    else
        if old then
            RTVVote[old][steamid64] = nil
            if next(RTVVote[old]) == nil and (old == "extend" or old == "random") then RTVVote[old] = nil end
        end

        RTVVote[vote] = RTVVote[vote] or {}
        RTVVote[vote][steamid64] = {
            avatar = ply:GetNWString("Avatar"),
            avatarFrame = ply:GetNWString("AvatarFrame"),
        }

        RTVNotify(ply, "rtv_vote_done", Color(255,255,255))
    end

    RTVBroadcastStatus()
end)

net.Receive("rtv add map", function(len, ply)
    if not IsValid(ply) or RTVStatus ~= "vote" then return end

    local map = net.ReadString()
    if map == "" then return end

    -- Picking a map in the "Add map" tab casts a real vote for it: the entry
    -- is written into RTVVote and the counts/icons are re-broadcast at once.
    RTVResolveMaps()
    if not RTVIsValidMap(map) then
        RTVNotify(ply, "rtv_cant_invalid", Color(255,120,80))
        return
    end

    local steamid64 = ply:SteamID64()

    for oldMap, list in pairs(RTVVote) do
        if list[steamid64] then
            list[steamid64] = nil
            if next(list) == nil and (oldMap == "extend" or oldMap == "random") then RTVVote[oldMap] = nil end
            break
        end
    end

    RTVVote[map] = RTVVote[map] or {}
    RTVVote[map][steamid64] = {
        avatar = ply:GetNWString("Avatar"),
        avatarFrame = ply:GetNWString("AvatarFrame"),
    }

    RTVNotify(ply, "rtv_vote_done", Color(255,255,255))
    RTVBroadcastStatus()
end)

-- Forced vote counter --------------------------------------------------------
hook.Add("HG RoundEnd", "RTV", function()
    if rtvNoVote then return end

    rtvRounds = rtvRounds + 1

    if rtvRounds >= RTV_RoundsForced then
        rtvRounds = 0
        RTVNotifyAll("rtv_force_vote", Color(255,200,80))
        RTVCreateVote(true)
    end
end)

-- Admin commands -------------------------------------------------------------
timer.Simple(0, function()
    if not adminPanel or not adminPanel.commandCreate then return end

    -- rtv_start / rtv_end / nortv were already registered in init_sh.lua so the
    -- admin menu knows them on the client; here we attach the server handlers.
    adminPanel.commandCreate("rtv_start", function(caller)
        if RTVStatus then
            if IsValid(caller) then caller:ChatPrint("[RTV] Голосование уже идёт") end
            return
        end
        if RTVCreateVote(true) and IsValid(caller) then
            caller:ChatPrint("[RTV] Голосование запущено")
        end
    end, nil, nil, "rcon")

    adminPanel.commandCreate("rtv_end", function(caller)
        if RTVStatus ~= "vote" then
            if IsValid(caller) then caller:ChatPrint("[RTV] Голосование не активно") end
            return
        end
        RTVEndVote()
        if IsValid(caller) then caller:ChatPrint("[RTV] Голосование завершено") end
    end, nil, nil, "rcon")

    adminPanel.commandCreate("nortv", function(_, value)
        rtvNoVote = value == true or value == "1" or value == 1
        if rtvNoVote then
            RTVClose()
            net.Start("rtv notify")
                net.WriteString("rtv_cant_disable")
                net.WriteColor(Color(255,120,80))
            net.Broadcast()
        end
    end, nil, nil, "rcon")
end)

-- Player !rtv -----------------------------------------------------------------
hook.Add("PlayerSay", "RTV", function(ply, text, team)
    if not IsValid(ply) or not isstring(text) then return end
    if string.sub(text,1,1) ~= "!" then return end

    local parts = string.Explode(" ", string.sub(text, 2))
    local cmd = string.lower(parts[1] or "")

    if cmd == "rtv" then
        if rtvNoVote then
            RTVNotify(ply, "rtv_cant_disable", Color(255,120,80))
            return ""
        end

        if RTVStatus == "vote" then
            RTVSendMapsList()
            RTVBroadcastStatus()
            return ""
        end

        if CurTime() - rtvLastStart < RTV_Cooldown then
            RTVNotify(ply, "rtv_cant_timeout", Color(255,120,80))
            return ""
        end

        rtvLastStart = CurTime()

        if RTVCreateVote() then
            RTVNotifyAll("rtv_start_vote", Color(255,255,255))
        end

        return ""
    end

    return nil
end)

-- Late-joiner sync -----------------------------------------------------------
hook.Add("PlayerInitialSpawn", "RTV Sync", function(ply)
    timer.Simple(1, function()
        if not IsValid(ply) then return end

        RTVSendMapsList(ply)

        if RTVStatus == "vote" then
            net.Start("rtv status")
                net.WriteString("vote")
                net.WriteTable(RTVVote)
            net.Send(ply)
        end
    end)
end)

if Initialize then RTVResolveMaps() end
