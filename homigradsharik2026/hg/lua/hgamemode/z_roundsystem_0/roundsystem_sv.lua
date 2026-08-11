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

local function IsTraitor(ply)
    return ply.PlayerClassName == "contr"
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
    ply:PlayerClassEvent("On")

    net.Start("setupclass")
        net.WriteEntity(ply)
        net.WriteString(class)
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

local function EndRound(winner)
    if not roundActive then return end

    roundActive = false

    timer.Remove("RoundSystemTime")

    for k, ply in pairs(player.GetAll()) do
        if ply.init then ply:PlayerClassEvent("EndRound", winner) end
    end

    local color = winner == 1 and Level.ColorRed or Level.ColorBlue
    local name = winner == 1 and "homicide_win_t" or "homicide_win_ct"

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

    for k, ply in pairs(player.GetAll()) do
        if ply.init and ply:Team() ~= 1002 then ply:Spawn() end
    end

    timer.Simple(Level.DelayStartRound or 5, StartRound)
end

local function StartRound()
    if roundActive then return end

    roundActive = true

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

    local traitorCount = #players > 0 and math.max(1, math.floor(#players / 5)) or 0

    local traitors, innocents = {}, {}

    for i, ply in pairs(players) do
        if i <= traitorCount then
            traitors[#traitors + 1] = ply
            SetPlayerClassServer(ply, "contr")
        else
            innocents[#innocents + 1] = ply
            SetPlayerClassServer(ply, "police")
        end
    end

    roundData = {
        traitors = traitors,
        inoccent = innocents, -- kept typo: client Sync() reads data.inoccent
        roundType = math.random(1, 4),
    }

    if Level.Start then Level:Start() end

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
        net.WriteString("level_" .. roundActiveName)
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

    timer.Create("RoundSystemTime", roundTime, 1, function()
        local traitors, innocents = GetAliveCounts()

        EndRound(innocents > 0 and 2 or 1)
    end)
end

local function CheckEnd()
    if not roundActive then return end

    local traitors, innocents = GetAliveCounts()

    if traitors == 0 then
        EndRound(2)
    elseif innocents == 0 then
        EndRound(1)
    end
end

-- ---------------------------------------------------------------------------
-- Hooks.
-- ---------------------------------------------------------------------------

hook.Add("PlayerInitialSpawn", "RoundSystem", function(ply)
    ply.init = true

    event.Call("Player Create", ply)
    event.Call("Player Spawn", ply)

    -- Mid-round joiners join as innocents.
    if roundActive and ply:Team() ~= 1002 then
        ply:SetTeam(1)
        if not ply:GetPlayerClass() then SetPlayerClassServer(ply, "police") end
    end

    RoundDataSend(ply)
end)

hook.Add("PlayerSpawn", "RoundSystem", function(ply)
    if not ply.init then return end

    event.Call("Player Spawn", ply)

    if roundActive and ply:GetPlayerClass() then
        ply:PlayerClassEvent("On")
    end

    SendTick({ { "player_spawn", { ply:EntIndex() } } })
end)

hook.Add("PlayerDeath", "RoundSystem", function(ply, inf, info)
    if not ply.init then return end

    ply:PlayerClassEvent("PlayerDeath")

    event.Call("Player Death", ply, info)

    CheckEnd()
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

    ply:SetTeam(team)

    if team == 1002 then
        local cls = player.classList[ply.PlayerClassName or ""]
        if cls and cls.Off then cls.Off(ply) end
        ply.PlayerClassName = nil
    else
        if not ply:GetPlayerClass() then SetPlayerClassServer(ply, "police") end

        if not ply:Alive() then ply:Spawn() end
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

    Level = Levels["level_homicide"] or Levels[roundActiveName]
    levelActive = Level

    if Level and not Level.LoadScreenTime then
        Level.LoadScreenTime = roundActiveName == "homicide" and 6 or 5
    end

    roundActive = false
    roundData = {}
    roundDataEnd = {}

    timer.Simple(2, StartRound)
end)
