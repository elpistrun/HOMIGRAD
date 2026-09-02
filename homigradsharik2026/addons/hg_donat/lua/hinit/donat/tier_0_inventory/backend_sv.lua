-- Local authoritative inventory backend. The original addon snapshot only
-- shipped the HTTP client, so this stores the same item format in DATA.
local STORE_DIR = "hg_donat"
local STORE_FILE = STORE_DIR .. "/inventory.json"

file.CreateDir(STORE_DIR)
local function LoadFromDB(sid)
    if not sql.TableExists("hg_inventory") then return end
    local row = sql.QueryRow("SELECT data FROM hg_inventory WHERE steamid64 = " .. sql.SQLStr(sid))
    if row and row.data then return util.JSONToTable(row.data) or {} end
end
local function SaveDB(sid, items)
    if not sql.TableExists("hg_inventory") then return end
    sql.Query("REPLACE INTO hg_inventory (steamid64, data) VALUES (" .. sql.SQLStr(sid) .. ", " .. sql.SQLStr(util.TableToJSON(items) or "{}") .. ")")
end
hook.Add("Initialize","HG Inventory DB",function()
    if not sql.TableExists("hg_inventory") then sql.Query("CREATE TABLE hg_inventory (steamid64 TEXT PRIMARY KEY, data TEXT)") end
    local fileData = util.JSONToTable(file.Read(STORE_FILE,"DATA") or "") or {}
    for sid, items in pairs(fileData) do
        if not sql.QueryValue("SELECT steamid64 FROM hg_inventory WHERE steamid64 = " .. sql.SQLStr(sid)) then
            sql.Query("INSERT INTO hg_inventory (steamid64, data) VALUES (" .. sql.SQLStr(sid) .. ", " .. sql.SQLStr(util.TableToJSON(items) or "{}") .. ")")
        end
    end
end)

local inventory = util.JSONToTable(file.Read(STORE_FILE,"DATA") or "") or {}
local useDelay = {}

local function save()
    file.Write(STORE_FILE,util.TableToJSON(inventory,true) or "{}")
end

local function getInventory(steamid64)
    steamid64 = tostring(steamid64 or "")
    inventory[steamid64] = inventory[steamid64] or {}
    return inventory[steamid64]
end

local function canEdit(ply)
    if ply:IsSuperAdmin() then return true end
    return ply.HasSuccess and ply:HasSuccess("donat_moderate") == true
end

local function sendFull(ply)
    if not IsValid(ply) then return end

    local result = {[ply:SteamID64()] = getInventory(ply:SteamID64())}
    if ply:IsSuperAdmin() or (ply.HasSuccess and ply:HasSuccess("donat_moderate")) then
        result = inventory
    end

    net.Start("hg_donat_inventory_full")
    net.WriteString(util.TableToJSON(result) or "{}")
    net.Send(ply)
end

local function pushItem(ply,cmd,steamid64,item)
    net.Start("inventory_server")
    net.WriteString(cmd)
    if cmd == "add" or cmd == "remove" then
        net.WriteString(steamid64)
        net.WriteTable(item)
    else
        net.WriteString(util.TableToJSON(item) or "{}")
    end
    net.Send(ply)
end

local function recipientsFor(steamid64)
    local result = {}
    for _,ply in ipairs(player.GetAll()) do
        if ply:SteamID64() == steamid64 or ply:IsSuperAdmin() or (ply.HasSuccess and ply:HasSuccess("donat_moderate")) then
            result[#result + 1] = ply
        end
    end
    return result
end

local function broadcastItem(cmd,steamid64,item)
    for _,ply in ipairs(recipientsFor(steamid64)) do pushItem(ply,cmd,steamid64,item) end
end

local function nextId(items)
    local highest = 0
    for id in pairs(items) do highest = math.max(highest,tonumber(id) or 0) end
    return tostring(highest + 1)
end

local function normalizeItem(raw,steamid64,id)
    if not istable(raw) or not isstring(raw.class) or raw.class == "" then return end
    return {
        id = tostring(id),
        class = string.sub(raw.class,1,64),
        type = raw.type,
        steamid64 = steamid64,
        timestamp_create = tonumber(raw.timestamp_create) or os.time(),
        timestamp_update = os.time(),
        data = istable(raw.data) and raw.data or (function()
            local data = table.Copy(raw)
            data.id = nil data.class = nil data.type = nil data.steamid64 = nil
            data.timestamp_create = nil data.timestamp_update = nil
            return data
        end)()
    }
end

util.AddNetworkString("inventory_user")
util.AddNetworkString("inventory_server")
util.AddNetworkString("hg_donat_inventory_full")
util.AddNetworkString("hg_donat_inventory_request")
util.AddNetworkString("donatinventory_item_cmd")
util.AddNetworkString("shop_buy")

net.Receive("hg_donat_inventory_request",function(_,ply) sendFull(ply) end)
hook.Add("PlayerInitialSpawn","HG Donat Inventory Sync",function(ply)
    timer.Simple(2,function() sendFull(ply) end)
end)

net.Receive("inventory_user",function(_,ply)
    local sessionId = net.ReadInt(7)
    local request = net.ReadTable()
    local success,msg = false,"invalid request"

    if istable(request) then
        local steamid64 = tostring(request.steamid64 or ply:SteamID64())
        if canEdit(ply) then
            local items = getInventory(steamid64)
            local cmd = request.cmd

            if cmd == "add" and isstring(request.className) and request.className ~= "" then
                local id = nextId(items)
                local item = normalizeItem({class = request.className},steamid64,id)
                items[id] = item save() broadcastItem("add",steamid64,item)
                success,msg = true,""
            elseif cmd == "clone" and items[tostring(request.id)] then
                local id = nextId(items)
                local item = table.Copy(items[tostring(request.id)])
                item.id = id item.timestamp_create = os.time() item.timestamp_update = os.time()
                items[id] = item save() broadcastItem("add",steamid64,item)
                success,msg = true,""
            elseif cmd == "delete" and items[tostring(request.id)] then
                local item = items[tostring(request.id)]
                items[tostring(request.id)] = nil save() broadcastItem("delete",steamid64,item)
                success,msg = true,""
            elseif cmd == "edit" then
                local id = tostring(request.id or "")
                local decoded = util.JSONToTable(tostring(request.json or ""))
                local item = normalizeItem(decoded,steamid64,id)
                if items[id] and item then
                    item.timestamp_create = items[id].timestamp_create
                    items[id] = item save() broadcastItem("update",steamid64,item)
                    success,msg = true,""
                else
                    msg = "item or json is invalid"
                end
            else
                msg = "unknown inventory command"
            end
        else
            msg = "access denied"
        end
    end

    net.Start("inventory_user")
    net.WriteInt(sessionId,7)
    net.WriteBool(success)
    net.WriteString(msg)
    net.Send(ply)
end)

local function rollCaseItem(caseInfo)
    local totalWeight = 0
    for _,set in pairs(caseInfo.casino) do totalWeight = totalWeight + (set.weight or 0) end
    if totalWeight <= 0 then return end

    local rand = math.random() * totalWeight
    local cumulativeWeight = 0

    for _,set in pairs(caseInfo.casino) do
        cumulativeWeight = cumulativeWeight + (set.weight or 0)
        if rand <= cumulativeWeight then
            local list = set.list
            if istable(list) and #list > 0 then return list[math.random(1,#list)] end
            break
        end
    end
end

local function spawnInventoryItem(ply,item)
    if not ply:Alive() then return false,"player is dead" end
    local info = DonatItemsList and DonatItemsList[tostring(item.type or "")]
    if not info then return false,"item configuration is missing" end
    if info.cantSpawn then return false,"this item cannot be spawned" end

    if info.swep then
        if not weapons.Get(info.swep) then return false,"weapon class is missing" end
        ply:Give(info.swep)
    elseif info.ent then
        if not scripted_ents.Get(info.ent) then return false,"entity class is missing" end
        local ent = ents.Create(info.ent)
        if not IsValid(ent) then return false,"entity creation failed" end
        local trace = ply:GetEyeTrace()
        ent:SetPos(trace.HitPos + trace.HitNormal * 16)
        ent:SetAngles(Angle(0,ply:EyeAngles().y,0))
        ent:Spawn()
        ent:Activate()
        if info.spawnFunction then info.spawnFunction(ply,ent) end
    else
        return false,"item has no entity or weapon"
    end
    return true
end

net.Receive("donatinventory_item_cmd",function(_,ply)
    local sessionId = net.ReadInt(7)
    local steamid64 = net.ReadString()
    local id = net.ReadString()
    local request = net.ReadTable()
    local success,data = false,{msg = "invalid item request"}
    local skipUpdate = false

    if steamid64 == ply:SteamID64() and istable(request) then
        local items = getInventory(steamid64)
        local item = items[id]
        if item then
            item.data = istable(item.data) and item.data or {}
            local cmd = request.cmd

            if cmd == "use" then
                if (useDelay[ply] or 0) > CurTime() then
                    data = {msg = "wait before using this item again"}
                else
                    success,data.msg = spawnInventoryItem(ply,item)
                    if success then
                        useDelay[ply] = CurTime() + 5
                        local configured = DonatItemsList and DonatItemsList[tostring(item.type or "")]
                        local left = tonumber(item.data.countUse) or (configured and configured.countUse) or 250
                        item.data.countUse = math.max(left - 1,0)
                    end
                end
            elseif cmd == "activated" and not item.data.activated then
                item.data.activated = true item.data.activeTime = os.time() success = true
            elseif cmd == "set" then
                item.data.url = string.sub(tostring(request.url or ""),1,2048)
                item.data.name = string.sub(tostring(request.name or ""),1,128)
                success = true
            elseif cmd == "receiver" and istable(request.list) then
                item.data.receiver = request.list success = true
            elseif cmd == "outfit" then
                item.data.bodygroups = istable(request.bodygroups) and request.bodygroups or {}
                item.data.color = request.color success = true
            elseif cmd == "upgrade" then
                item.data.bodygroups = istable(request.bodygroupPos) and request.bodygroupPos or {}
                success = true
            elseif cmd == "open" then
                if item.class ~= "case" then
                    data = {msg = "item is not a case"}
                else
                    local caseInfo = DonatCasesClasses and DonatCasesClasses[tostring(item.type or "")]
                    if not caseInfo or not istable(caseInfo.casino) then
                        data = {msg = "case configuration is missing"}
                    else
                        local keyId
                        for otherId,otherItem in pairs(items) do
                            if otherItem.class == "case_key" and otherItem.type == item.type and tostring(otherId) ~= tostring(id) then
                                keyId = tostring(otherId)
                                break
                            end
                        end

                        if not keyId then
                            data = {msg = "key is missing"}
                        else
                            local reward = rollCaseItem(caseInfo)
                            if not reward or not isstring(reward.class) or not inventoryManager.listClass[reward.class] then
                                data = {msg = "reward item is invalid"}
                            else
                                local keyItem = items[keyId]
                                items[keyId] = nil
                                broadcastItem("delete",steamid64,keyItem)

                                local caseItem = items[id]
                                items[id] = nil
                                broadcastItem("delete",steamid64,caseItem)

                                local rewardId = nextId(items)
                                local rewardItem = normalizeItem(reward,steamid64,rewardId)
                                if rewardItem then
                                    items[rewardId] = rewardItem
                                    broadcastItem("add",steamid64,rewardItem)
                                    save()
                                    success = true
                                    skipUpdate = true
                                    data = {item = reward}
                                else
                                    data = {msg = "reward item is invalid"}
                                end
                            end
                        end
                    end
                end
            else
                data = {msg = "item command is not supported by local backend"}
            end

            if success and not skipUpdate then
                item.timestamp_update = os.time()
                save()
                broadcastItem("update",steamid64,item)
            end

            data = data or {}
        else
            data = {msg = "item was not found"}
        end
    end

    net.Start("donatinventory_item_cmd")
    net.WriteInt(sessionId,7)
    net.WriteBool(success)
    net.WriteTable(data or {})
    net.Send(ply)
end)

hook.Add("PlayerDisconnected","HG Donat Inventory Cleanup",function(ply) useDelay[ply] = nil end)

-- removed duplicate AddNetworkString
net.Receive("shop_buy",function(_,ply)
        if not donatPanel or not donatPanel.GetBalance or not donatPanel.shop then return end
        local prio = net.ReadInt(11)
        local idCategory = net.ReadInt(11)
        local itemId = net.ReadInt(11)
        local count = net.ReadInt(7)

        if not IsValid(ply) or not donatPanel or not donatPanel.shop then return end

        local category = donatPanel.shop[prio]
        if not category or not category.list then return end

        local rawItem = category.list[idCategory]
        if not rawItem then return end

        -- Handle sub-lists (categories within categories)
        if rawItem.list then
            rawItem = rawItem.list[itemId]
            if not rawItem then return end
        end

        local price = rawItem.price
        local priceDonat = rawItem.priceDonat
        local total = (price or priceDonat or 0) * math.Clamp(count,1,100)
        if total <= 0 then return end

        local steamid64 = ply:SteamID64()
        local data = donatPanel.GetBalance(steamid64)

        -- Deduct balance
        if price then
            if data.balance < total then return end
            data.balance = data.balance - total
        elseif priceDonat then
            if data.balance_donat < total then return end
            data.balance_donat = data.balance_donat - total
        else
            return
        end
        donatPanel.SaveBalance()
        donatPanel.BroadcastBalance(steamid64)

        -- Add item(s) to inventory
        local items = getInventory(steamid64)
        for i = 1,math.Clamp(count,1,100) do
            local id = nextId(items)
            local item = normalizeItem(rawItem,steamid64,id)
            if item then
                items[id] = item
                broadcastItem("add",steamid64,item)
            end
        end
        save()
    end)