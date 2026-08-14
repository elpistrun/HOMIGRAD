util.AddNetworkString("customchat.say")
util.AddNetworkString("customchat.set_emojis")
util.AddNetworkString("customchat.set_theme")
util.AddNetworkString("customchat.set_tags")

local nextMessage = {}

net.Receive("customchat.say",function(_,ply)
    local channel = net.ReadUInt(4)
    local text = CustomChat.CleanupString(net.ReadString())
    local teamOnly = channel == CustomChat.channels.team

    if text == "" then return end
    if #text > CustomChat.MAX_MESSAGE_LENGTH then
        text = string.sub(text,1,CustomChat.MAX_MESSAGE_LENGTH)
    end

    local now = RealTime()
    if (nextMessage[ply] or 0) > now then return end
    nextMessage[ply] = now + 0.35

    local result = hook.Run("PlayerSay",ply,text,teamOnly)
    if result == false or result == "" then return end
    if isstring(result) then text = result end

    local recipients = teamOnly and team.GetPlayers(ply:Team()) or player.GetHumans()

    net.Start("customchat.say")
    net.WriteUInt(teamOnly and CustomChat.channels.team or CustomChat.channels.everyone,4)
    net.WriteString(text)
    net.WriteEntity(ply)
    net.Send(recipients)
end)

local settings = {
    ["customchat.set_emojis"] = {permission = CustomChat.CanSetServerEmojis,key = "customchat.emojis"},
    ["customchat.set_theme"] = {permission = CustomChat.CanSetServerTheme,key = "customchat.theme"},
    ["customchat.set_tags"] = {permission = CustomChat.CanSetChatTags,key = "customchat.tags"}
}

local function RegisterSettingReceiver(netName,info)
    net.Receive(netName,function(_,ply)
        if not info.permission(ply) then return end

        local value = net.ReadString()
        if #value > 60000 then return end

        CustomChat.SetServerPreference(info.key,value)
    end)
end

for netName,info in pairs(settings) do
    RegisterSettingReceiver(netName,info)
end

hook.Add("PlayerDisconnected","CustomChat.ClearRateLimit",function(ply)
    nextMessage[ply] = nil
end)
