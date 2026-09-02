-- Local authoritative outfit backend. The original addon only shipped the
-- HTTP client for "outfit_user", so "Play as model" / "Equip model" never
-- worked. This stores the equipped model item id per player and applies the
-- chosen model, bodygroups and color every spawn.

util.AddNetworkString("outfit_user")
util.AddNetworkString("hg_profile_local_sync")

local STORE_DIR = "hg_donat"
local STORE_FILE = STORE_DIR .. "/inventory.json"
local outfitBySid = {}

local function SaveOutfit(sid,itemID)
    if not sql.TableExists("hg_outfit") then sql.Query("CREATE TABLE hg_outfit (steamid64 TEXT PRIMARY KEY, itemID TEXT)") end
    if itemID then
        sql.Query("REPLACE INTO hg_outfit (steamid64, itemID) VALUES (" .. sql.SQLStr(sid) .. ", " .. sql.SQLStr(itemID) .. ")")
    else
        sql.Query("DELETE FROM hg_outfit WHERE steamid64 = " .. sql.SQLStr(sid))
    end
end

local function GetInventory()
    return util.JSONToTable(file.Read(STORE_FILE,"DATA") or "") or {}
end

local function pushEquipped(target,steamid64,itemID)
    local data = {[steamid64] = {playerModelItemID = itemID or ""}}
    net.Start("hg_profile_local_sync")
    net.WriteTable(data)
    if IsValid(target) then net.Send(target) else net.Broadcast() end
end

local function applyBodygroups(item,ply,config)
    local bg = istable(item.data) and item.data.bodygroups
    if not istable(bg) then return end

    local empty = config and config.bodygroupsEmpty or {}

    for x,value in pairs(bg) do
        local index = tonumber(x)
        if index then
            value = tonumber(value)
            if not value then continue end

            local defValue = empty[index]
            local real
            if defValue then
                if value == 0 then
                    real = defValue
                elseif value == defValue then
                    real = 0
                else
                    real = value
                end
            else
                real = value
            end

            if index == -1 then
                ply:SetSkin(real)
            else
                ply:SetBodygroup(index,real)
            end
        end
    end
end

local function applyColor(item,ply)
    local color = istable(item.data) and item.data.color
    if istable(color) and (#color >= 3) then
        ply:SetPlayerColor(Vector(math.Clamp(color[1] or 255,0,255) / 255,math.Clamp(color[2] or 255,0,255) / 255,math.Clamp(color[3] or 255,0,255) / 255))
    end
end

local function applyEquipped(ply)
    if not IsValid(ply) then return end

    local itemID = outfitBySid[ply:SteamID64()]
    if not itemID then return end

    local inventory = GetInventory()
    local items = inventory[tostring(ply:SteamID64())] or {}
    local item = items[tostring(itemID)]
    if not item or not istable(item.data) or not isstring(item.data.model) or item.data.model == "" then
        return
    end

    local config = DonatItems_PlayerModels and DonatItems_PlayerModels[item.data.model]

    if util.IsValidModel(item.data.model) then
        ply:SetModel(item.data.model)
    end

    applyBodygroups(item,ply,config)
    applyColor(item,ply)

    if config and isfunction(config.setupPlayerModel) then
        pcall(config.setupPlayerModel,item,ply)
    end
end

net.Receive("outfit_user",function(_,ply)
    local sessionId = net.ReadInt(7)
    local request = net.ReadTable()
    local success,msg = false,"invalid request"

    if istable(request) then
        local steamid64 = ply:SteamID64()
        local cmd = request.cmd

        if cmd == "model_equip" then
            local itemID = request.modelID and tostring(request.modelID) or nil

            if itemID then
                local inventory = GetInventory()
                local items = inventory[steamid64] or {}
                local item = items[itemID]

                if item and item.class == "playermodel" then
                    outfitBySid[steamid64] = itemID
                    SaveOutfit(steamid64,itemID)
                    pushEquipped(nil,steamid64,itemID)
                    success,msg = true,""
                else
                    msg = "you don't own this model"
                end
            else
                outfitBySid[steamid64] = nil
                SaveOutfit(steamid64,nil)
                pushEquipped(nil,steamid64,nil)
                success,msg = true,""
            end
        else
            msg = "unknown outfit command"
        end
    end

    net.Start("outfit_user")
    net.WriteInt(sessionId,7)
    net.WriteBool(success)
    net.WriteString(msg)
    net.Send(ply)
end)

hook.Add("Initialize","HG Outfit Load",function()
    if not sql.TableExists("hg_outfit") then sql.Query("CREATE TABLE hg_outfit (steamid64 TEXT PRIMARY KEY, itemID TEXT)") end
    local rows = sql.Query("SELECT steamid64, itemID FROM hg_outfit")
    if rows then
        for _,row in ipairs(rows) do
            outfitBySid[tostring(row.steamid64)] = tostring(row.itemID)
        end
    end
end)

hook.Add("PlayerInitialSpawn","HG Outfit Sync",function(ply)
    timer.Simple(1,function()
        if not IsValid(ply) then return end
        pushEquipped(ply,ply:SteamID64(),outfitBySid[ply:SteamID64()] or nil)
    end)
end)

hook.Add("PlayerSpawn","HG Outfit Apply",function(ply)
    timer.Simple(0.3,function()
        if IsValid(ply) and ply:Alive() then applyEquipped(ply) end
    end)
end)
