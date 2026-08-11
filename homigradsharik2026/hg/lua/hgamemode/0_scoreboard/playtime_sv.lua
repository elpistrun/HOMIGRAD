local PLAYERS = {}
local FILE_PATH = "homigrad/playtime/"

local function SaveTime(ply)
    local saved = PLAYERS[ply]
    if not saved then return end

    local total = saved + (CurTime() - ply:GetNWFloat("TimeStart",CurTime()))
    total = math.floor(total)

    ply:SetNWInt("Time",total)

    file.Write(FILE_PATH .. ply:SteamID64() .. ".txt",tostring(total))
end

hook.Add("PlayerInitialSpawn","Playtime.Initialize",function(ply)
    if ply:IsBot() then return end

    if not file.Exists(FILE_PATH,"DATA") then pcall(file.CreateDir,FILE_PATH) end

    local saved = tonumber(file.Read(FILE_PATH .. ply:SteamID64() .. ".txt","DATA")) or 0

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