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

Event_ChatCommands = Event_ChatCommands or {}

function Event_ChatCommand_Add(name, func)
    local obj = {name = name, func = func, args = {}, category = "general", description = ""}
    function obj:SetArgs(args)
        self.args = args
        return self
    end
    function obj:SetCategory(cat)
        self.category = cat
        return self
    end
    function obj:SetCategoryAndDesc(cat, desc)
        self.category = cat
        self.description = desc or ""
        return self
    end
    function obj:SetDescription(desc)
        self.description = desc
        return self
    end
    Event_ChatCommands[name] = obj
    if SERVER then
        timer.Simple(0.1, function()
            local grouped = {}
            for k,v in pairs(Event_ChatCommands) do
                local cat = v.category or "general"
                grouped[cat] = grouped[cat] or {}
                grouped[cat][k] = v.description or true
            end
            net.Start("event_info_cmd")
            net.WriteTable(grouped)
            net.Broadcast()
        end)
    end
    return obj
end

if SERVER then
    util.AddNetworkString("event_info_cmd")
    util.AddNetworkString("event_chat_command")
    net.Receive("event_chat_command", function(len, ply)
        local name = net.ReadString()
        local args = net.ReadTable()
        local obj = Event_ChatCommands[name]
        if not obj then return end
        local ok, ret, msg = pcall(obj.func, ply, unpack(args))
        if not ok then
            ErrorNoHalt("[Event_ChatCommand] " .. name .. " error: " .. tostring(ret) .. "\n")
            return
        end
        if msg and isstring(msg) then ply:ChatPrint(msg) end
    end)
    hook.Add("PlayerSay", "Event_ChatCommands", function(ply, text)
        if text:sub(1,1) ~= "!" and text:sub(1,1) ~= "/" then return end
        local content = text:sub(2)
        local parts = string.Explode(" ", content)
        local cmdName = table.remove(parts, 1)
        if not cmdName then return end
        cmdName = string.lower(cmdName)
        local obj = Event_ChatCommands[cmdName]
        if not obj then return end
        local parsed = {}
        for i, argType in ipairs(obj.args or {}) do
            local raw = parts[i]
            if argType == "number" then
                parsed[i] = tonumber(raw)
                if parsed[i] == nil then
                    ply:ChatPrint("Argument " .. i .. " must be number")
                    return ""
                end
            else
                parsed[i] = raw
            end
        end
        for i = #parsed+1, #parts do parsed[i] = parts[i] end
        local ok, ret, msg = pcall(obj.func, ply, unpack(parsed))
        if not ok then
            ErrorNoHalt("[Event_ChatCommand] " .. cmdName .. " error: " .. tostring(ret) .. "\n")
            return ""
        end
        if msg and isstring(msg) then ply:ChatPrint(msg) end
        return ""
    end)
    hook.Add("PlayerInitialSpawn", "Event_ChatCommands_Sync", function(ply)
        timer.Simple(2, function()
            if not IsValid(ply) then return end
            local grouped = {}
            for k,v in pairs(Event_ChatCommands) do
                local cat = v.category or "general"
                grouped[cat] = grouped[cat] or {}
                grouped[cat][k] = v.description or true
            end
            net.Start("event_info_cmd")
            net.WriteTable(grouped)
            net.Send(ply)
        end)
    end)
end
if SERVER then return end

net.Receive("event_claimed_info",function()
    Event_Claimed = net.ReadTable()
    Event_ClaimedID = net.ReadString()

    if Event_ClaimedID == "" then Event_Claimed = nil Event_ClaimedID = nil return end

    event.Run("Event Claimed Info Updated")
end)