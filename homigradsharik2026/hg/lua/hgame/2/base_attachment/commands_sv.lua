local nextChange = {}

local function GetWeapon(ply)
    if not IsValid(ply) or not ply:Alive() then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.AttachmentSet or not wep.attachments then return end

    local now = RealTime()
    if (nextChange[ply] or 0) > now then return end
    nextChange[ply] = now + 0.05

    return wep
end

local function FinishUpdate(wep)
    wep:OnAttachmentUpdate()
end

local function Reply(ply,text)
    if IsValid(ply) then ply:ChatPrint("[HG attachments] " .. text) end
end

concommand.Add("hg_attachment_set",function(ply,cmd,args)
    local wep = GetWeapon(ply)
    if not wep then return end

    local path = tostring(args[1] or "")
    local value = tostring(args[2] or "")
    if path == "" or #path > 128 or #value > 128 then return end

    local numberValue = tonumber(value)
    if numberValue != nil then value = numberValue end

    local success,err = wep:AttachmentSet(path,value)
    if success then
        FinishUpdate(wep)
    else
        Reply(ply,"ошибка: " .. tostring(err or "недопустимый attachment"))
    end
end)

concommand.Add("hg_attachment_set_cosmetic",function(ply,cmd,args)
    local wep = GetWeapon(ply)
    if not wep then return end

    local path = tostring(args[1] or "")
    local cosmeticName = args[2]
    local key = wep.attachments[path]
    if not key then return end

    if cosmeticName == "" or cosmeticName == "none" then cosmeticName = nil end

    if cosmeticName then
        local config = attachmentGame.config[key[2][1]]
        if not config or not config.cosmetic or not config.cosmetic[cosmeticName] then return end
    end

    key[1].cosmetic = cosmeticName
    FinishUpdate(wep)
end)

concommand.Add("hg_attachment_set_skin",function(ply,cmd,args)
    local wep = GetWeapon(ply)
    if not wep then return end

    local path = tostring(args[1] or "")
    local skinName = args[2]
    local skinSlot = tostring(args[3] or "0")
    local key = wep.attachments[path]
    if not key then return end

    if skinName == "" or skinName == "none" then skinName = nil end
    if skinName and not attachmentGame.config_skin[skinName] then return end

    if skinSlot == "0" then
        key[1].skin_0 = skinName
    else
        if not key[3].skin or key[3].skin[skinSlot] == nil then return end

        key[1].skin = key[1].skin or {}
        key[1].skin[skinSlot] = skinName
    end

    FinishUpdate(wep)
end)

hook.Add("PlayerDisconnected","HG Attachment Rate Limit",function(ply)
    nextChange[ply] = nil
end)
