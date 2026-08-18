if not SERVER then return end

-- ========================
-- Файловая IPC коммуникация
-- GMod <-> Python backend
-- ========================

local IPC_DIR = "hg_discord_ipc"
local REQ_DIR = IPC_DIR .. "/req"
local RES_DIR = IPC_DIR .. "/res"

file.CreateDir(IPC_DIR)
file.CreateDir(REQ_DIR)
file.CreateDir(RES_DIR)

local SEND_INTERVAL = 30
local pendingCallbacks = {}

-- Очистка старых файлов при старте
local function CleanDir(dir)
    local files = file.Find(dir .. "/*", "DATA")
    if files then
        for _, f in ipairs(files) do
            file.Delete(dir .. "/" .. f)
        end
    end
end
CleanDir(REQ_DIR)
CleanDir(RES_DIR)

-- Отправка запроса через файл
local function SendRequest(method, body, onSuccess, onFail)
    local id = tostring(RealTime()) .. "_" .. math.random(10000, 99999)
    pendingCallbacks[id] = {success = onSuccess, failed = onFail}

    local reqData = {id = id, method = method, body = body}
    file.Write(REQ_DIR .. "/" .. id .. ".json", util.TableToJSON(reqData))
end

-- Поллинг ответов
timer.Create("HG_Discord_IPC_Poll", 0.5, 0, function()
    local files = file.Find(RES_DIR .. "/*.json", "DATA")
    if not files then return end

    for _, fileName in ipairs(files) do
        local id = fileName:gsub(".json", "")
        local cb = pendingCallbacks[id]
        if cb then
            local raw = file.Read(RES_DIR .. "/" .. fileName, "DATA")
            if raw then
                local result = util.JSONToTable(raw)
                if result and result.ok then
                    if cb.success then cb.success(result) end
                else
                    if cb.failed then cb.failed(result and result.error or "unknown") end
                end
            end
            pendingCallbacks[id] = nil
        end
        file.Delete(RES_DIR .. "/" .. fileName)
    end
end)

-- ========================
-- Отправка статуса сервера
-- ========================

local function SendServerStatus()
    local body = {
        ip = game.GetIPAddress(),
        hostname = GetConVar("hostname"):GetString(),
        map = game.GetMap(),
        players = player.GetCount(),
        maxPlayers = game.MaxPlayers(),
        gamemode = engine.ActiveGamemode()
    }
    SendRequest("status", body)
end

timer.Create("HG_Discord_Status_Send", SEND_INTERVAL, 0, function()
    SendServerStatus()
end)

hook.Add("Initialize", "HG Discord Status", function()
    timer.Simple(3, SendServerStatus)
end)

-- ========================
-- Верификация Discord
-- ========================

local function VerifyDiscord(ply)
    if not IsValid(ply) then return end
    local steamid = ply:SteamID64()

    SendRequest("verify_generate", {steamid = steamid},
        function(result)
            if not IsValid(ply) then return end
            if result.error == "already_verified" then
                ply:ChatPrint("[Discord] Ваш аккаунт уже привязан!")
            elseif result.code then
                ply:ChatPrint("[Discord] Ваш код: " .. result.code)
                ply:ChatPrint("[Discord] Введите его в Discord канале верификации")
            else
                ply:ChatPrint("[Discord] Ошибка: " .. (result.error or "unknown"))
            end
        end,
        function(err)
            if not IsValid(ply) then return end
            ply:ChatPrint("[Discord] Сервер верификации недоступен. (" .. tostring(err) .. ")")
        end
    )
end

local function UnverifyDiscord(ply)
    if not IsValid(ply) then return end
    local steamid = ply:SteamID64()

    SendRequest("verify_unverify", {steamid = steamid},
        function(result)
            if not IsValid(ply) then return end
            if result.ok then
                ply:ChatPrint("[Discord] Аккаунт отвязан.")
            elseif result.error == "not_verified" then
                ply:ChatPrint("[Discord] Ваш аккаунт не привязан.")
            else
                ply:ChatPrint("[Discord] Ошибка сервера.")
            end
        end,
        function(err)
            if not IsValid(ply) then return end
            ply:ChatPrint("[Discord] Сервер верификации недоступен.")
        end
    )
end

hook.Add("PlayerSay", "HG Discord Verify", function(ply, text)
    local lower = string.lower(text)
    if lower == "!verify_discord" then
        VerifyDiscord(ply)
        return ""
    elseif lower == "!unverify_discord" then
        UnverifyDiscord(ply)
        return ""
    end
end)

print("\t[hg_discord] IPC file-based sender started")
