if not SERVER then return end

-- Network strings
util.AddNetworkString("hg_trade_request")
util.AddNetworkString("hg_trade_accept")
util.AddNetworkString("hg_trade_decline")
util.AddNetworkString("hg_trade_start")
util.AddNetworkString("hg_trade_update")
util.AddNetworkString("hg_trade_end")
util.AddNetworkString("hg_trade_add")
util.AddNetworkString("hg_trade_remove")
util.AddNetworkString("hg_trade_confirm")
util.AddNetworkString("hg_trade_cancel")

-- Active trade sessions: { [ply] = session }
-- session = { partner = ply, items = { [ply] = {...} }, confirmed = { [ply] = bool } }
local trades = {}

-- Pending requests: { [target] = requester }
local pendingRequests = {}

local function SendTradeUpdate(ply)
    local trade = trades[ply]
    if not trade then return end

    local partner = trade.partner
    if not IsValid(partner) then return end

    for _, target in ipairs({ply, partner}) do
        if not IsValid(target) then continue end
        net.Start("hg_trade_update")
            net.WriteEntity(ply)
            net.WriteEntity(partner)
            -- Player A's items
            local itemsA = trade.items[ply] or {}
            net.WriteUInt(#itemsA, 8)
            for _, info in ipairs(itemsA) do
                net.WriteString(info.spawnname or "")
            end
            -- Player B's items
            local itemsB = trade.items[partner] or {}
            net.WriteUInt(#itemsB, 8)
            for _, info in ipairs(itemsB) do
                net.WriteString(info.spawnname or "")
            end
            -- Confirm states
            net.WriteBool(trade.confirmed[ply] or false)
            net.WriteBool(trade.confirmed[partner] or false)
        net.Send(target)
    end
end

local function EndTrade(ply, reason)
    local trade = trades[ply]
    if not trade then return end

    local partner = trade.partner
    trades[ply] = nil
    if partner then trades[partner] = nil end

    for _, target in ipairs({ply, partner}) do
        if IsValid(target) then
            net.Start("hg_trade_end")
                net.WriteString(reason or "cancelled")
            net.Send(target)
        end
    end
end

local function CompleteTrade(ply)
    local trade = trades[ply]
    if not trade then return end

    local partner = trade.partner
    if not IsValid(partner) then EndTrade(ply, "partner_left") return end

    local itemsA = trade.items[ply] or {}
    local itemsB = trade.items[partner] or {}

    -- Validate all items still exist
    for _, info in ipairs(itemsA) do
        if not info.item or not info.inv then EndTrade(ply, "item_missing") return end
    end
    for _, info in ipairs(itemsB) do
        if not info.item or not info.inv then EndTrade(ply, "item_missing") return end
    end

    -- Check distance
    if not IsValid(ply) or not IsValid(partner) then EndTrade(ply, "too_far") return end
    if ply:GetPos():DistToSqr(partner:GetPos()) > 40000 then EndTrade(ply, "too_far") return end

    local invA = ply.inv
    local invB = partner.inv
    if not IsValid(invA) or not IsValid(invB) then EndTrade(ply, "no_inventory") return end

    -- Remove A's items from A's inventory
    local removedA = {}
    for _, info in ipairs(itemsA) do
        local slot = info.inv:GetSlot(info.x, info.y)
        if slot then
            for depth, item in ipairs(slot.list) do
                if item == info.item then
                    table.remove(slot.list, depth)
                    for d, other in ipairs(slot.list) do other.depth = d end
                    removedA[#removedA + 1] = info
                    break
                end
            end
        end
    end

    -- Remove B's items from B's inventory
    local removedB = {}
    for _, info in ipairs(itemsB) do
        local slot = info.inv:GetSlot(info.x, info.y)
        if slot then
            for depth, item in ipairs(slot.list) do
                if item == info.item then
                    table.remove(slot.list, depth)
                    for d, other in ipairs(slot.list) do other.depth = d end
                    removedB[#removedB + 1] = info
                    break
                end
            end
        end
    end

    -- Insert A's items into B's inventory
    for _, info in ipairs(removedA) do
        local slot = inventoryGame.ServerEmptySlot(invB)
        if slot then
            inventoryGame.ServerInsertItem(info.item, slot)
        end
    end

    -- Insert B's items into A's inventory
    for _, info in ipairs(removedB) do
        local slot = inventoryGame.ServerEmptySlot(invA)
        if slot then
            inventoryGame.ServerInsertItem(info.item, slot)
        end
    end

    -- Sync inventories
    if invA.Sync then invA:Sync() end
    if invB.Sync then invB:Sync() end

    if IsValid(ply) then ply:ChatPrint("[Trade] " .. L("trade_complete")) end
    if IsValid(partner) then partner:ChatPrint("[Trade] " .. L("trade_complete")) end

    trades[ply] = nil
    trades[partner] = nil

    for _, target in ipairs({ply, partner}) do
        if IsValid(target) then
            net.Start("hg_trade_end")
                net.WriteString("complete")
            net.Send(target)
        end
    end
end

-- Helper functions for direct calls from PlayerSay
local function SendTradeRequest(ply, target)
    if not IsValid(target) or not target:IsPlayer() then
        ply:ChatPrint("[Trade] " .. L("trade_no_target"))
        return
    end
    if target == ply then return end
    if not ply:Alive() or not target:Alive() then
        ply:ChatPrint("[Trade] " .. L("trade_dead"))
        return
    end
    if ply:GetPos():DistToSqr(target:GetPos()) > 40000 then
        ply:ChatPrint("[Trade] " .. L("trade_too_far"))
        return
    end
    if trades[ply] or trades[target] then
        ply:ChatPrint("[Trade] " .. L("trade_busy"))
        return
    end

    pendingRequests[target] = ply

    net.Start("hg_trade_request")
        net.WriteEntity(ply)
    net.Send(target)

    ply:ChatPrint("[Trade] " .. L("trade_request_sent", target:Name()))
end

local function AcceptTrade(ply)
    local requester = pendingRequests[ply]
    if not IsValid(requester) then return end
    pendingRequests[ply] = nil

    if trades[ply] or trades[requester] then return end
    if not ply:Alive() or not requester:Alive() then return end
    if ply:GetPos():DistToSqr(requester:GetPos()) > 40000 then
        ply:ChatPrint("[Trade] " .. L("trade_too_far"))
        return
    end

    local session = {
        partner = requester,
        items = { [ply] = {}, [requester] = {} },
        confirmed = { [ply] = false, [requester] = false }
    }
    trades[ply] = session
    trades[requester] = session

    for _, target in ipairs({ply, requester}) do
        net.Start("hg_trade_start")
            net.WriteEntity(requester)
            net.WriteEntity(ply)
        net.Send(target)
    end
end

local function DeclineTrade(ply)
    local requester = pendingRequests[ply]
    pendingRequests[ply] = nil
    if IsValid(requester) then
        requester:ChatPrint("[Trade] " .. L("trade_declined", ply:Name()))
    end
end

-- Network handlers
net.Receive("hg_trade_request", function(len, ply)
    local target = net.ReadEntity()
    SendTradeRequest(ply, target)
end)

net.Receive("hg_trade_accept", function(len, ply)
    AcceptTrade(ply)
end)

net.Receive("hg_trade_decline", function(len, ply)
    DeclineTrade(ply)
end)

-- Network: add item to trade
net.Receive("hg_trade_add", function(len, ply)
    local trade = trades[ply]
    if not trade then return end

    local x = net.ReadUInt(7)
    local y = net.ReadUInt(7)

    local inv = ply.inv
    if not IsValid(inv) then return end

    local slot = inv:GetSlot(x, y)
    if not slot or not slot.list[1] then return end

    local item = slot.list[1]

    -- Reset confirmations
    trade.confirmed[ply] = false
    trade.confirmed[trade.partner] = false

    local items = trade.items[ply]
    items[#items + 1] = {
        item = item,
        inv = inv,
        x = x,
        y = y,
        spawnname = item.spawnname
    }

    SendTradeUpdate(ply)
end)

-- Network: remove item from trade
net.Receive("hg_trade_remove", function(len, ply)
    local trade = trades[ply]
    if not trade then return end

    local index = net.ReadUInt(8)
    local items = trade.items[ply]
    if not items[index] then return end

    table.remove(items, index)

    trade.confirmed[ply] = false
    trade.confirmed[trade.partner] = false

    SendTradeUpdate(ply)
end)

-- Network: confirm trade
net.Receive("hg_trade_confirm", function(len, ply)
    local trade = trades[ply]
    if not trade then return end

    trade.confirmed[ply] = true

    if trade.confirmed[ply] and trade.confirmed[trade.partner] then
        CompleteTrade(ply)
    else
        SendTradeUpdate(ply)
        if IsValid(trade.partner) then
            trade.partner:ChatPrint("[Trade] " .. L("trade_partner_confirmed"))
        end
    end
end)

-- Network: cancel trade
net.Receive("hg_trade_cancel", function(len, ply)
    EndTrade(ply, "cancelled")
end)

-- Chat commands (call helpers directly since we're on server)
hook.Add("PlayerSay", "HG Trade Commands", function(ply, text)
    local lower = string.lower(text)

    if lower == "!trade" then
        local tr = util.TraceLine({
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:GetAimVector() * 150,
            filter = ply
        })

        local target = tr.Entity
        SendTradeRequest(ply, target)
        return ""
    end

    if lower == "!accept" then
        if pendingRequests[ply] and IsValid(pendingRequests[ply]) then
            AcceptTrade(ply)
        end
        return ""
    end

    if lower == "!decline" then
        if pendingRequests[ply] then
            DeclineTrade(ply)
            ply:ChatPrint("[Trade] " .. L("trade_decline_confirm"))
        end
        return ""
    end
end)

-- Cleanup
hook.Add("PlayerDisconnected", "HG Trade Cleanup", function(ply)
    pendingRequests[ply] = nil
    if trades[ply] then EndTrade(ply, "disconnected") end
end)

hook.Add("PlayerDeath", "HG Trade Death", function(ply)
    if trades[ply] then EndTrade(ply, "died") end
end)
