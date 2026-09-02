-- This addon snapshot contains only the client-side donation managers. Pool
-- their request channels so opening the UI cannot produce an unpooled net
-- error. Until a real backend is installed, answer explicitly instead of
-- leaving client coroutines suspended with nil state.
-- NOTE: "outfit_user" is intentionally NOT pooled here anymore, it is served
-- by outfit_backend_sv.lua.
local channels = {
    "balance_user",
    "email_user"
}

for _,channel in ipairs(channels) do
    util.AddNetworkString(channel)

    net.Receive(channel,function(_,ply)
        local sessionId = net.ReadInt(7)

        net.Start(channel)
        net.WriteInt(sessionId,7)
        net.WriteBool(false)
        net.WriteString("server backend is not available")
        net.Send(ply)
    end)
end
