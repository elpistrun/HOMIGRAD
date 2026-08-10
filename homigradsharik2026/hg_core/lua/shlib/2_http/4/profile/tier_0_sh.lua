Profiles = Profiles or {}

if CLIENT then
    profileManager = ManagerCreate("profileManager")
    
    net.ReceiveMediaToken("profile_sync",function(body)
        for steamid64,info in pairs(JSONToTable(body,true)) do
            Profiles[steamid64] = info

            profileManager:Event_Call("Update",steamid64,info)
        end
    end)
end

local PLAYER = FindMetaTable("Player")

function PLAYER:GetAvatar()
    local profile = Profiles[self:SteamID64()]

    return profile and profile.avatar
end

function PLAYER:GetAvatarFrame()
    local profile = Profiles[self:SteamID64()]

    return profile and profile.avatarFrame
end

function PLAYER:GetBackground()
    local profile = Profiles[self:SteamID64()]

    return profile and profile.background
end

function PLAYER:GetBackgroundOpacity()
    local profile = Profiles[self:SteamID64()]

    return profile and profile.backgroundOpacity or 1
end

function PLAYER:GetBackgroundY()
    local profile = Profiles[self:SteamID64()]

    return profile and profile.backgroundY or 0.5
end