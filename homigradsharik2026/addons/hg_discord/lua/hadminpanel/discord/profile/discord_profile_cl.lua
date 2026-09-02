local PLAYER = FindMetaTable("Player")

function PLAYER:GetDiscordProfile()
    local steamid = self:SteamID()

    return Profiles[steamid] and Profiles[steamid].discord
end

cvars.CreateReplicateOption("hg_dontshowmydiscord","0")