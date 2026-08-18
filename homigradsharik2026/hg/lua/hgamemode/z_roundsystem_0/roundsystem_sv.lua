-- Server-side round system for the hg gamemode.
if CLIENT then return end

util.AddNetworkString("roundActiveName")
util.AddNetworkString("levelNextName")
util.AddNetworkString("roundActive")
util.AddNetworkString("roundData")
util.AddNetworkString("roundDataEnd")
util.AddNetworkString("roundEmit")
util.AddNetworkString("loadscreen")
util.AddNetworkString("loadscreen_end")
util.AddNetworkString("tickNet")
util.AddNetworkString("setupclass")
util.AddNetworkString("want change team")
util.AddNetworkString("select_class")
util.AddNetworkString("afk")

-- ---------------------------------------------------------------------------
-- Server stubs for dependencies missing from this addon set.
-- ---------------------------------------------------------------------------

if not OUTFITPLAYER_HAIR then OUTFITPLAYER_HAIR = "hair" end

outfitPlayer = outfitPlayer or {}
if not outfitPlayer.config_model then
    outfitPlayer.config_model = {
        "models/player/group01/male_01.mdl",
        "models/player/group01/male_02.mdl",
        "models/player/group01/male_03.mdl",
        "models/player/group01/male_04.mdl",
        "models/player/group01/male_05.mdl",
        "models/player/group01/male_06.mdl",
        "models/player/group01/male_07.mdl",
        "models/player/group01/male_08.mdl",
        "models/player/group01/male_09.mdl",
        "models/player/group01/female_01.mdl",
        "models/player/group01/female_02.mdl",
        "models/player/group01/female_03.mdl",
        "models/player/group01/female_04.mdl",
        "models/player/group01/female_05.mdl",
        "models/player/group01/female_06.mdl",
    }
end

local PlayerMeta = FindMetaTable("Player")

if not PlayerMeta.SetOutfit then
    function PlayerMeta:SetOutfit(data) end
end

-- CLASS:PlayerDeath() calls self:SetPlayerClass() (no args) to drop the class.
if not PlayerMeta.SetPlayerClass then
    function PlayerMeta:SetPlayerClass(class)
        local classList = player.classList
        local old = classList[self.PlayerClassName or ""]

        if class then
            if old and old ~= classList[class] and old.Off then old.Off(self) end

            self.PlayerClassName = class
            self:PlayerClassEvent("On")
        else
            if old and old.Off then old.Off(self) end

            self.PlayerClassName = nil
        end
    end
end

-- CLASS:On() calls armorGame.GiveEntity(self, armorName, data). The armor
-- config needs data.armorName to resolve, and the player needs .Armors to exist.
if armorGame and not armorGame.GiveEntity then
    function armorGame.GiveEntity(Armor, armorName, data)
        if not Armor.Armors then armorGame.Create(Armor) end

        local existsData = data or {}
        existsData.armorName = armorName
        existsData.integrity = existsData.integrity or 1

        return armorGame.Give(Armor.Armors, armorName, existsData, "server")
    end
end

-- pvsAuto.Insert is referenced by nw_sh.lua (InitPVS for server entities) but
-- never defined in this addon set. Full PVS streaming is out of scope; a no-op
-- keeps ply:SetupNWTable("Armor") from crashing on spawn.
if pvsAuto and not pvsAuto.Insert then
    function pvsAuto.Insert(self) end
end

-- ---------------------------------------------------------------------------
-- Round state.
-- ---------------------------------------------------------------------------

roundActive = false
roundData = {}
roundDataEnd = {}
roundTime = 0
roundTimeStart = 0

local Level
local roundTransition = 0
local roundParticipantCount = 0
local policePhase = false

local function ResolveLevel(name)
    name = name or "homicide"
    return Levels[name] or Levels["level_" .. name]
end

local function IsTraitor(ply)
    return ply.roleTServer == true
end

-- tickNet wire format: UInt16 byteCount + compressed JSON array of packages
-- {{name, data}, ...}. Decoded by net_tick_cl.lua.
local function SendTick(packages)
    local data = util.Compress(util.TableToJSON(packages))

    net.Start("tickNet")
        net.WriteUInt(#data, 16)
        net.WriteData(data, #data)
    net.Broadcast()
end

-- Assign a class server-side and broadcast it so all clients update
-- PlayerClassName / the scoreboard (mirrors the client's setupclass receiver).
local function SetPlayerClassServer(ply, class)
    if not IsValid(ply) then return end

    local old = ply.PlayerClassName
    if old == class then return end

    local oldClass = player.classList[old or ""]
    if oldClass and oldClass.Off then oldClass.Off(ply) end

    ply.PlayerClassName = class
    if class then ply:PlayerClassEvent("On") end

    net.Start("setupclass")
        net.WriteEntity(ply)
        net.WriteString(class or "")
        net.WriteString(old or "")
    net.Broadcast()
end

local function GetAliveCounts()
    local traitors, innocents = 0, 0

    for k, ply in pairs(player.GetAll()) do
        if not ply.init or ply:Team() == 1002 or not ply:Alive() then continue end

        if IsTraitor(ply) then
            traitors = traitors + 1
        else
            innocents = innocents + 1
        end
    end

    return traitors, innocents
end

local function IsHomicideLevel()
    return roundActiveName == "homicide" or roundActiveName == "level_homicide"
end

local function GetPlayableTeams(level)
    local result = {}
    for teamId,key in SortedPairs(level.teamEncoder or {}) do
        if level[key] then result[#result + 1] = teamId end
    end
    if #result == 0 then result[1] = 1 end
    return result
end

local function GiveRandom(ply,list)
    if not istable(list) or #list == 0 then return end
    local class = list[math.random(1,#list)]
    if isstring(class) then ply:Give(class) end
end

local function ApplyLevelLoadout(ply)
    if not IsValid(ply) or not Level then return end
    local key = Level.teamEncoder and Level.teamEncoder[ply:Team()]
    local data = key and Level[key]
    if not data then return end

    if istable(data.models) and #data.models > 0 then
        local model = data.models[math.random(1,#data.models)]
        if istable(model) then model = model[1] end
        if isstring(model) and util.IsValidModel(model) then ply:SetModel(model) end
    end

    for _,class in ipairs(data.weapons or {}) do
        if isstring(class) then ply:Give(class) end
    end

    local selectedClass
    if istable(data.classes) and #data.classes > 0 then
        selectedClass = data.classes[math.random(1,#data.classes)]
        if istable(selectedClass) then ply:SetNWString("ClassName",tostring(selectedClass[1] or "")) end
    end

    GiveRandom(ply,selectedClass and selectedClass.main_weapon or data.main_weapon)
    GiveRandom(ply,selectedClass and selectedClass.secondary_weapon or data.secondary_weapon)

    if armorGame and armorGame.GiveEntity then
        for _,armor in ipairs(selectedClass and selectedClass.armors or data.armors or {}) do
            if istable(armor) then armor = armor[1] end
            if isstring(armor) then armorGame.GiveEntity(ply,armor,{}) end
        end
    end
end

-- Send current round state to a single player (used on join / initProtocol).
local function RoundDataSend(ply)
    if not IsValid(ply) then return end

    net.Start("roundActiveName")
        net.WriteString(roundActiveName or "homicide")
    net.Send(ply)

    net.Start("levelNextName")
        net.WriteString(roundActiveNameNext or roundActiveName or "homicide")
    net.Send(ply)

    net.Start("roundActive")
        net.WriteBool(roundActive)
    net.Send(ply)

    if roundActive then
        net.Start("roundData")
            net.WriteTable(roundData or {})
            net.WriteFloat(roundTimeStart)
            net.WriteFloat(roundTime)
        net.Send(ply)
    end

    if roundDataEnd and roundDataEnd.winnerVGUI then
        net.Start("roundDataEnd")
            net.WriteTable(roundDataEnd)
        net.Send(ply)
    end
end

local StartRound
local BeginPolicePhase

local function PutPlayerInRoundWaiting(ply)
    if not IsValid(ply) or ply:Team() == 1002 then return end

    ply.hgRoundWaitingApplied = true
    if ply:Alive() then ply:KillSilent() end
    ply:Spectate(OBS_MODE_ROAMING)
end

local function SpawnByRoundSystem(ply)
    if not IsValid(ply) then return end

    ply.hgRoundWaitingApplied = nil
    ply:UnSpectate()
    ply:Spawn()

    -- Team modes use the mapper's named red/blue points. Keep the engine's
    -- regular player spawn as a fallback for maps without HG point data.
    if not IsHomicideLevel() and Level and Level.teamEncoder and pointManager and pointManager.GetList then
        local pointName = Level.teamEncoder[ply:Team()]
        local points = pointName and pointManager:GetList(pointName)
        if istable(points) and #points > 0 then
            local point = points[math.random(1,#points)]
            if point and isvector(point.pos) then
                ply:SetPos(point.pos + Vector(0,0,4))
                if isangle(point.ang) then ply:SetEyeAngles(point.ang) end
            end
        end
    end
end

local function EndRound(winner)
    if not roundActive then return end

    roundActive = false
    policePhase = false

    timer.Remove("RoundSystemTime")

    for k, ply in pairs(player.GetAll()) do
        if ply.init then ply:PlayerClassEvent("EndRound", winner) end
    end

    roundTransition = roundTransition + 1
    local transition = roundTransition

    local color,name
    if IsHomicideLevel() then
        color = winner == 1 and (Level.ColorRed or Color(255,0,0)) or (Level.ColorBlue or Color(0,80,255))
        name = winner == 1 and "homicide_win_t" or "homicide_win_ct"
    else
        local key = Level.teamEncoder and Level.teamEncoder[winner]
        local teamData = key and Level[key]
        color = teamData and teamData[2] or Color(100,180,255)
        name = teamData and teamData[1] or "round_end"
    end

    roundDataEnd = {
        winnerVGUI = {
            color = color,
            name = name,
            sound = "homigrad/vgui/panorama/case_awarded_4_legendary_01.wav",
        },
    }

    net.Start("roundActive")
        net.WriteBool(false)
    net.Broadcast()

    net.Start("roundDataEnd")
        net.WriteTable(roundDataEnd)
    net.Broadcast()

    net.Start("roundEmit")
    net.Broadcast()

    if Level.End then Level:End(roundDataEnd) end

    if GetGlobalBool("LevelRandom",false) then
        local candidates = {}
        for levelName,level in pairs(Levels) do
            if string.StartWith(levelName,"level_") and levelName != "level_base" and not level.NoSelectRandom then
                local allowed = true
                if level.CanRandomNext then
                    local ok,result = pcall(level.CanRandomNext,level)
                    allowed = ok and result != false and result != nil
                end
                if allowed then candidates[#candidates + 1] = string.sub(levelName,7) end
            end
        end
        if #candidates > 0 then roundActiveNameNext = candidates[math.random(1,#candidates)] end
    end

    timer.Simple(Level.DelayStartRound or 5, function()
        if transition != roundTransition or roundActive then return end
        StartRound()
    end)
end

StartRound = function()
    if roundActive then return end
    if GetGlobalBool("StopGame",false) then
        SetGlobalString("Game Error","stop_game")
        timer.Create("HG Round Retry",2,1,StartRound)
        return
    elseif GetGlobalString("Game Error","") == "stop_game" then
        SetGlobalString("Game Error","")
    end

    local availablePlayers = 0
    for _,ply in ipairs(player.GetAll()) do
        if ply.init and ply:Team() ~= 1002 then
            availablePlayers = availablePlayers + 1
        end
    end

    -- Homicide needs two opposing roles. Starting with one player previously
    -- produced a traitor-only round and exposed the underlying class names.
    if availablePlayers < 2 then
        SetGlobalString("Game Error","need_2_players")

        for _,ply in ipairs(player.GetAll()) do
            -- Apply waiting death once. If an administrator explicitly uses
            -- the respawn command afterwards, the retry timer leaves it alone.
            if ply.init and not ply.hgRoundWaitingApplied then PutPlayerInRoundWaiting(ply) end
        end

        timer.Create("HG Round Retry",2,1,StartRound)
        return
    end

    if GetGlobalString("Game Error","") == "need_2_players" then
        SetGlobalString("Game Error","")
    end

    local requestedName = roundActiveNameNext or roundActiveName or "homicide"
    local requestedLevel = ResolveLevel(requestedName)
    if not requestedLevel then
        ErrorNoHalt("[HG rounds] level is not registered: " .. tostring(requestedName) .. "\n")
        timer.Create("HG Round Retry",2,1,StartRound)
        return
    end

    Level = requestedLevel
    levelActive = Level
    roundActiveName = requestedName
    roundActiveNameNext = requestedName

    roundActive = true
    policePhase = false

    roundTime = Level.RoundTime or 360
    roundTimeStart = CurTime()

    for k, ply in pairs(player.GetAll()) do
        if ply.init and ply:Team() ~= 1002 then ply:SetTeam(1) end
    end

    local players = {}
    for k, ply in pairs(player.GetAll()) do
        if ply.init and ply:Team() ~= 1002 then players[#players + 1] = ply end
    end

    table.Shuffle(players)
    roundParticipantCount = #players

    local traitors, innocents = {}, {}
    if IsHomicideLevel() then
        local traitorCount = math.max(1,math.floor(#players / 5))
        for i,ply in ipairs(players) do
            ply:SetTeam(1)
            if i <= traitorCount then
                traitors[#traitors + 1] = ply ply.roleTServer = true ply.roleCTServer = nil
            else
                innocents[#innocents + 1] = ply ply.roleTServer = nil ply.roleCTServer = true
            end
            if ply.PlayerClassName then SetPlayerClassServer(ply,nil) end
        end
        roundData = {traitors=traitors,inoccent=innocents,roundType=math.random(1,4),policePhase=false}
    else
        local teams = GetPlayableTeams(Level)
        roundData = {teams = {}}
        for i,ply in ipairs(players) do
            local teamId
            if Level.GetMaxBlue and teams[1] then
                -- Jailbreak-like modes expose their own cap for team 1.
                local ok,maxFirst = pcall(Level.GetMaxBlue,Level)
                maxFirst = ok and math.max(tonumber(maxFirst) or 1,1) or 1
                teamId = i <= maxFirst and teams[1] or (teams[2] or teams[1])
            else
                teamId = teams[(i - 1) % #teams + 1]
            end
            ply:SetTeam(teamId)
            ply.roleTServer = nil ply.roleCTServer = nil
            if ply.PlayerClassName then SetPlayerClassServer(ply,nil) end
            roundData.teams[teamId] = roundData.teams[teamId] or {}
            roundData.teams[teamId][#roundData.teams[teamId] + 1] = ply
        end
    end

    if Level.Start then Level:Start() end

    -- Spawn only when the new round is ready. The old implementation spawned
    -- everyone during EndRound, behind the winner screen, with stale classes.
    for _,ply in ipairs(players) do
        SpawnByRoundSystem(ply)
    end

    net.Start("roundActiveName")
        net.WriteString(roundActiveName)
    net.Broadcast()

    net.Start("levelNextName")
        net.WriteString(roundActiveNameNext or roundActiveName)
    net.Broadcast()

    net.Start("roundActive")
        net.WriteBool(true)
    net.Broadcast()

    net.Start("loadscreen")
        net.WriteString(string.StartWith(roundActiveName,"level_") and roundActiveName or ("level_" .. roundActiveName))
        net.WriteString("")
    net.Broadcast()

    net.Start("roundData")
        net.WriteTable(roundData)
        net.WriteFloat(roundTimeStart)
        net.WriteFloat(roundTime)
    net.Broadcast()

    timer.Simple(Level.LoadScreenTime or 5, function()
        net.Start("loadscreen_end")
        net.Broadcast()

        net.Start("roundEmit")
        net.Broadcast()
    end)

    if IsHomicideLevel() then
        timer.Create("RoundSystemTime",roundTime,1,BeginPolicePhase)
    else
        timer.Create("RoundSystemTime",roundTime,1,function()
            local aliveByTeam = {}
            for _,ply in ipairs(player.GetAll()) do
                if ply.init and ply:Alive() and ply:Team() < 1000 then aliveByTeam[ply:Team()] = (aliveByTeam[ply:Team()] or 0) + 1 end
            end
            local winner = next(aliveByTeam) or 1
            EndRound(winner)
        end)
    end
end

BeginPolicePhase = function()
    if not roundActive or policePhase then return end

    policePhase = true
    roundTime = 120
    roundTimeStart = CurTime()
    roundData.policePhase = true

    -- Dead innocents return as the arriving police force. Living innocents
    -- remain civilians and continue helping against the traitor.
    for _,ply in ipairs(roundData.inoccent or {}) do
        if IsValid(ply) and ply:Team() ~= 1002 and not ply:Alive() then
            SpawnByRoundSystem(ply)
            SetPlayerClassServer(ply,"police")
        end
    end

    net.Start("roundData")
        net.WriteTable(roundData)
        net.WriteFloat(roundTimeStart)
        net.WriteFloat(roundTime)
    net.Broadcast()

    timer.Create("RoundSystemTime",roundTime,1,function()
        local traitors = GetAliveCounts()
        EndRound(traitors > 0 and 1 or 2)
    end)
end

local function CheckEnd()
    if not roundActive then return end

    -- Keep development/single-player rounds usable and do not instantly end a
    -- round before a real opposing pair exists.
    if roundParticipantCount < 2 then return end

    if IsHomicideLevel() then
        local traitors,innocents = GetAliveCounts()
        if traitors == 0 then EndRound(2) elseif policePhase and innocents == 0 then EndRound(1) end
        return
    end

    local aliveTeams = {}
    local lastPlayer
    for _,ply in ipairs(player.GetAll()) do
        if ply.init and ply:Alive() and ply:Team() < 1000 then aliveTeams[ply:Team()] = true lastPlayer = ply end
    end

    if Level.EndType == "player" then
        local alive = 0
        for _,ply in ipairs(player.GetAll()) do if ply.init and ply:Alive() and ply:Team() < 1000 then alive = alive + 1 lastPlayer = ply end end
        if alive <= 1 then EndRound(IsValid(lastPlayer) and lastPlayer:Team() or 1) end
    elseif table.Count(aliveTeams) <= 1 then
        EndRound(next(aliveTeams) or 1)
    end
end

-- ---------------------------------------------------------------------------
-- Hooks.
-- ---------------------------------------------------------------------------

hook.Add("PlayerInitialSpawn", "RoundSystem", function(ply)
    ply.init = true

    event.Call("Player Create", ply)
    event.Call("Player Spawn", ply)

    -- Mid-round joins never restart the round. Homicide gets an innocent/
    -- police reinforcement; team modes place the player on the smallest team.
    if roundActive and ply:Team() ~= 1002 then
        roundParticipantCount = roundParticipantCount + 1
        if IsHomicideLevel() then
            ply:SetTeam(1)
            ply.roleTServer = nil ply.roleCTServer = true
            roundData.inoccent = roundData.inoccent or {}
            roundData.inoccent[#roundData.inoccent + 1] = ply
            if policePhase then SetPlayerClassServer(ply,"police") end
        else
            local teams = GetPlayableTeams(Level)
            local counts,bestTeam = {},teams[1]
            for _,other in ipairs(player.GetAll()) do counts[other:Team()] = (counts[other:Team()] or 0) + 1 end
            for _,teamId in ipairs(teams) do if (counts[teamId] or 0) < (counts[bestTeam] or 0) then bestTeam = teamId end end
            ply:SetTeam(bestTeam)
        end
    end

    RoundDataSend(ply)

    timer.Simple(0,function()
        if not IsValid(ply) or roundActive then return end
        if GetGlobalString("Game Error","") == "need_2_players" and not ply.hgRoundWaitingApplied then
            PutPlayerInRoundWaiting(ply)
        end
    end)
end)

hook.Add("PlayerSpawn", "RoundSystem", function(ply)
    if not ply.init then return end

    event.Call("Player Spawn", ply)

    if roundActive and ply:GetPlayerClass() then
        ply:PlayerClassEvent("On")
    end

    if roundActive and not IsHomicideLevel() then ApplyLevelLoadout(ply) end

    SendTick({ { "player_spawn", { ply:EntIndex() } } })
end)

hook.Add("PlayerDeath", "RoundSystem", function(ply, inf, info)
    if not ply.init then return end

    ply:PlayerClassEvent("PlayerDeath")

    event.Call("Player Death", ply, info)

    CheckEnd()
end)

hook.Add("PlayerDisconnected","RoundSystem CheckEnd",function()
    timer.Simple(0,CheckEnd)
end)

-- ---------------------------------------------------------------------------
-- Net receivers.
-- ---------------------------------------------------------------------------

net.Receive("initProtocol", function(len, ply)
    if not IsValid(ply) then return end

    RoundDataSend(ply)

    net.Start("initProtocol")
        net.Send(ply)
end)

net.Receive("want change team", function(len, ply)
    if not IsValid(ply) then return end

    local team = tonumber(net.ReadString()) or 1

    -- Never accept arbitrary team ids from the client. Spectator is always
    -- valid; playable teams come from the currently loaded level.
    if team ~= 1002 then
        local validTeam = false
        for _,teamId in ipairs(GetPlayableTeams(Level or {})) do
            if team == teamId then validTeam = true break end
        end
        if not validTeam then return end
    end

    ply:SetTeam(team)

    if team == 1002 then
        local cls = player.classList[ply.PlayerClassName or ""]
        if cls and cls.Off then cls.Off(ply) end
        ply.PlayerClassName = nil
    else
        if IsHomicideLevel() and policePhase and not ply:GetPlayerClass() then
            SetPlayerClassServer(ply,"police")
        end

        -- Team selection is not a respawn command. During an active round a
        -- dead player remains a spectator until the next system-controlled
        -- spawn (or the Homicide police reinforcement phase).
        if not roundActive and not ply:Alive() and GetGlobalString("Game Error","") == "" then
            SpawnByRoundSystem(ply)
        end
    end

    local teamName = tostring(team)
    if levelActive and levelActive.teamEncoder then
        local key = levelActive.teamEncoder[team]
        if key and levelActive[key] then teamName = tostring(levelActive[key][1] or key) end
    end

    net.Start("want change team")
        net.WriteString(teamName)
    net.Send(ply)
end)

net.Receive("select_class", function(len, ply)
    if not IsValid(ply) then return end

    ply.teamSettings = net.ReadTable()
end)

net.Receive("afk", function(len, ply)
    -- handled by spectator system; nothing to do here
end)

timer.Simple(0,function()
    if not adminPanel or not adminPanel.commandCreate then return end

    adminPanel.commandCreate("levelend",function()
        if roundActive then EndRound(2) end
    end,nil,nil,"levels")

    adminPanel.commandCreate("levelstart",function()
        if not roundActive then StartRound() end
    end,nil,nil,"levels")

    adminPanel.commandCreate("roundactive",function()
        if roundActive then EndRound(2) else StartRound() end
    end,nil,nil,"levels")

    adminPanel.commandCreate("levelnext",function(caller,name)
        name = tostring(name or "")
        local level = ResolveLevel(name)
        if not level then caller:ChatPrint("[HG rounds] Неизвестный режим: " .. name) return end
        roundActiveNameNext = string.StartWith(name,"level_") and string.sub(name,7) or name
        net.Start("levelNextName") net.WriteString(roundActiveNameNext) net.Broadcast()
    end,nil,nil,"levels")

    adminPanel.commandCreate("levels",function(caller)
        local names = {}
        for name in SortedPairs(Levels) do if string.StartWith(name,"level_") then names[#names + 1] = string.sub(name,7) end end
        caller:ChatPrint("[HG rounds] " .. table.concat(names,", "))
    end,nil,nil,"levels")

    adminPanel.commandCreate("levelrandom",function(_,value)
        SetGlobalBool("LevelRandom",value == true or value == "1" or value == 1)
    end,nil,nil,"levels")

    adminPanel.commandCreate("stopgame",function(_,value)
        local stop = value == true or value == "1" or value == 1
        SetGlobalBool("StopGame",stop)
        if stop and roundActive then EndRound(2) elseif not stop and not roundActive then StartRound() end
    end,nil,nil,"levels")

    adminPanel.commandCreate("aistop",function(_,value)
        RunConsoleCommand("ai_disabled",(value == true or value == "1" or value == 1) and "1" or "0")
    end,nil,nil,"levels")
end)

-- ---------------------------------------------------------------------------
-- Initialize.
-- ---------------------------------------------------------------------------

event.Add("Initialize", "RoundSystem", function()
    if not level_tdm then _G.level_tdm = {} end
    if not level_tdm.GiveSwep then
        function level_tdm.GiveSwep(ply, weapons)
            if not weapons or #weapons == 0 then return end

            ply:Give(weapons[math.random(1, #weapons)])
        end
    end

    -- CLASS:On() ends with CLASS.CloseMenu(), which only exists client-side.
    for name, class in pairs(player.classList) do
        if type(class) == "table" and not class.CloseMenu then
            class.CloseMenu = function() end
        end
    end

    Level = ResolveLevel(roundActiveName)
    levelActive = Level

    if not Level then
        ErrorNoHalt("[HG rounds] initial level is not registered: " .. tostring(roundActiveName) .. "\n")
        return
    end

    if Level and not Level.LoadScreenTime then
        Level.LoadScreenTime = roundActiveName == "homicide" and 6 or 5
    end

    roundActive = false
    roundData = {}
    roundDataEnd = {}

    timer.Simple(2, StartRound)
end)
