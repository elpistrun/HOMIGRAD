adminPanel.successRegistry("eventplaning_access",nil,"rights")
adminPanel.successRegistry("eventplaning_moderator",nil,"rights")

function Event_CanAccess(steamid64,checkHired,event)
    local ply = steamid64
    if not IsValid(ply) then return true end
    if TypeID(steamid64) == TYPE_ENTITY then steamid64 = ply:SteamID64() end

    event = event or Event_Claimed
    if not event then return end

    return event.owner.steamid64 == steamid64 or event.friends[steamid64] and true or false
end

EventCanHelpHiredAdmins = false

if SERVER then return end

net.Receive("event_claimed_info",function()
    Event_Claimed = net.ReadTable()
    Event_ClaimedID = net.ReadString()

    if Event_ClaimedID == "" then Event_Claimed = nil Event_ClaimedID = nil return end

    event.Run("Event Claimed Info Updated")
end)