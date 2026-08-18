if not SERVER then return end

local MUTATOR = Mutator_Get("base")
if not MUTATOR then return end

util.AddNetworkString("mutator_cmd")
util.AddNetworkString("mutator_data")

-- Helper: build sync data table for a mutator
local function BuildSyncData(mutator)
    local data = {enabled = mutator:GetActive()}
    local varNames = rawget(mutator,"_varNames")
    if varNames then
        for _,varName in ipairs(varNames) do
            local getter = mutator["Get" .. varName]
            if getter then data[varName] = getter(mutator) end
        end
    end
    return data
end

-- Receive commands from clients (admin only)
net.Receive("mutator_cmd",function(len,ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    local className = net.ReadString()
    local cmdName = net.ReadString()
    local args = net.ReadTable()

    local mutator = MutatorClasses[className]
    if not mutator then return end

    if cmdName == "enabled" then
        if args[1] == 1 then
            mutator.enabled = true
            mutator:Event_Call("On")
        else
            mutator.enabled = false
            mutator:Event_Call("Off")
        end
    elseif mutator.CMDs[cmdName] then
        mutator.CMDs[cmdName](mutator,ply,args)
    end

    -- Sync full state to all clients
    net.Start("mutator_data")
        net.WriteString(className)
        net.WriteTable(BuildSyncData(mutator))
    net.Broadcast()
end)

-- Sync all mutator states to a specific player (on join)
function MutatorSyncPlayer(ply)
    for className,mutator in pairs(MutatorClasses) do
        if className == "base" then continue end
        net.Start("mutator_data")
            net.WriteString(className)
            net.WriteTable(BuildSyncData(mutator))
        net.Send(ply)
    end
end

hook.Add("PlayerInitialSpawn","HG Mutator Sync",function(ply)
    timer.Simple(2,function()
        if IsValid(ply) then MutatorSyncPlayer(ply) end
    end)
end)

-- Reset mutators on round cleanup
hook.Add("CleanUpMap","HG Mutator Reset",function()
    for className,mutator in pairs(MutatorClasses) do
        if className == "base" then continue end
        if mutator.ResetWithCleanUp and mutator:GetActive() then
            mutator.enabled = false
            mutator:Event_Call("Off")
        end
    end
end)
