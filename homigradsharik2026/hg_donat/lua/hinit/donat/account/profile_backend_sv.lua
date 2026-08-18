-- Local profile backend used when the external Homigrad account service is
-- unavailable. It persists cosmetic profile settings and broadcasts changes.
util.AddNetworkString("cvars_replicate")
util.AddNetworkString("hg_profile_local_sync")

local dataPath = "homigrad/profile_cosmetics.json"
local profiles = {}

if file.Exists(dataPath,"DATA") then
    profiles = util.JSONToTable(file.Read(dataPath,"DATA") or "") or {}
end

local fields = {
    hg_profile_background = "background",
    hg_profile_showsteambackground = "backgroundSteam",
    hg_profile_background_opacity = "backgroundOpacity",
    hg_profile_background_y = "backgroundY",
    hg_profile_color = "color"
}

local function Save()
    file.CreateDir("homigrad")
    file.Write(dataPath,util.TableToJSON(profiles,true))
end

local function SendProfiles(target,data)
    net.Start("hg_profile_local_sync")
        net.WriteTable(data or profiles)
    if IsValid(target) then net.Send(target) else net.Broadcast() end
end

local function CleanValue(name,value)
    if name == "hg_profile_background" then
        value = string.Trim(string.sub(value or "",1,1024))
        if value ~= "" and not string.match(string.lower(value),"^https?://") then return nil end
        if string.find(value,"[\"'<>\r\n]") then return nil end
        value = string.gsub(value,"cdn%.discordapp%.com","media.discordapp.net")
        return value
    elseif name == "hg_profile_showsteambackground" then
        return value == "1" or value == "true"
    elseif name == "hg_profile_background_opacity" or name == "hg_profile_background_y" then
        return math.Clamp(tonumber(value) or 0,0,1)
    elseif name == "hg_profile_color" then
        if value == "" then return false end
        local color = util.JSONToTable(value or "")
        if not istable(color) then return nil end
        return {
            math.Clamp(tonumber(color[1]) or 255,0,255),
            math.Clamp(tonumber(color[2]) or 255,0,255),
            math.Clamp(tonumber(color[3]) or 255,0,255)
        }
    end
end

net.Receive("cvars_replicate",function(_,ply)
    local name = net.ReadString()
    local field = fields[name]
    if not field then return end

    ply.hgProfileChangeAt = ply.hgProfileChangeAt or 0
    if ply.hgProfileChangeAt > CurTime() then return end
    ply.hgProfileChangeAt = CurTime() + 0.1

    local value = CleanValue(name,net.ReadString())
    if value == nil then return end

    local steamid64 = ply:SteamID64()
    profiles[steamid64] = profiles[steamid64] or {}
    profiles[steamid64][field] = value == false and nil or value

    Profiles = Profiles or {}
    Profiles[steamid64] = table.Merge(Profiles[steamid64] or {},profiles[steamid64])

    Save()
    SendProfiles(nil,{[steamid64] = profiles[steamid64]})
end)

hook.Add("PlayerInitialSpawn","HG Profile Local Sync",function(ply)
    timer.Simple(1,function()
        if IsValid(ply) then SendProfiles(ply) end
    end)
end)
