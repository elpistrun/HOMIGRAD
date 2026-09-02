local PLAYERS = {}
local FILE_PATH = "homigrad/playtime/"

local function SaveTime(ply)
    local saved = PLAYERS[ply]
    if not saved then return end

    local total = saved + (CurTime() - ply:GetNWFloat("TimeStart",CurTime()))
    total = math.floor(total)

    ply:SetNWInt("Time",total)

    file.Write(FILE_PATH .. ply:SteamID64() .. ".txt",tostring(total))
    if sql.TableExists("hg_playtime") then
        sql.Query("REPLACE INTO hg_playtime (steamid64, total) VALUES (" .. sql.SQLStr(ply:SteamID64()) .. ", " .. total .. ")")
    end
end

hook.Add("PlayerInitialSpawn","Playtime.Initialize",function(ply)
    if ply:IsBot() then return end

    if not file.Exists(FILE_PATH,"DATA") then pcall(file.CreateDir,FILE_PATH) end

    local saved
    if sql.TableExists("hg_playtime") then
        local row = sql.QueryRow("SELECT total FROM hg_playtime WHERE steamid64 = " .. sql.SQLStr(ply:SteamID64()))
        if row then saved = tonumber(row.total) end
    end
    if saved == nil then saved = tonumber(file.Read(FILE_PATH .. ply:SteamID64() .. ".txt","DATA")) or 0 end

    PLAYERS[ply] = saved
    ply:SetNWFloat("TimeStart",CurTime())
    ply:SetNWInt("Time",saved)
end)

hook.Add("PlayerDisconnected","Playtime.Save",function(ply)
    SaveTime(ply)
    PLAYERS[ply] = nil
end)

timer.Create("Playtime.AutoSave",60,0,function()
    for _,ply in ipairs(player.GetAll()) do SaveTime(ply) end
end)

hook.Add("Initialize","HG Playtime DB",function()
    if not sql.TableExists("hg_playtime") then sql.Query("CREATE TABLE hg_playtime (steamid64 TEXT PRIMARY KEY, total INTEGER)") end
    -- migrate file -> db once
    local files = file.Find(FILE_PATH .. "*.txt", "DATA")
    for _, fname in ipairs(files) do
        local sid = string.sub(fname, 1, -5)
        if not sql.QueryValue("SELECT steamid64 FROM hg_playtime WHERE steamid64 = " .. sql.SQLStr(sid)) then
            local txt = tonumber(file.Read(FILE_PATH .. fname, "DATA")) or 0
            sql.Query("INSERT INTO hg_playtime (steamid64, total) VALUES (" .. sql.SQLStr(sid) .. ", " .. txt .. ")")
        end
    end
end)