-- Server-authoritative anti-cheat baseline. Client reports are evidence for
-- logging/inspection only; important gameplay decisions must remain serverside.
util.AddNetworkString("hg_ac_challenge")
util.AddNetworkString("hg_ac_response")

local enabled = CreateConVar("hg_ac_enabled","1",FCVAR_ARCHIVE,"Enable HG anti-cheat heartbeat")
local action = CreateConVar("hg_ac_action","1",FCVAR_ARCHIVE,"0=log, 1=kick clients that fail heartbeat")
local logPath = "homigrad/anticheat.log"
local protocol = "HGAC-2026-1"

local function Log(ply,reason,detail)
    local identity = IsValid(ply) and (ply:Nick() .. " [" .. ply:SteamID() .. "]") or "unknown"
    local line = os.date("%Y-%m-%d %H:%M:%S") .. " | " .. identity .. " | " .. reason .. " | " .. tostring(detail or "")
    file.CreateDir("homigrad")
    file.Append(logPath,line .. "\n")
    MsgC(Color(255,80,80),"[HG AntiCheat] ",color_white,line .. "\n")
end

local function Challenge(ply)
    if not enabled:GetBool() or not IsValid(ply) or ply:IsBot() then return end

    local nonce = tostring(math.random(1,2147483646)) .. ":" .. tostring(SysTime())
    ply.hgACNonce = nonce
    ply.hgACChallengeAt = CurTime()

    net.Start("hg_ac_challenge")
        net.WriteString(nonce)
    net.Send(ply)
end

net.Receive("hg_ac_response",function(_,ply)
    if not enabled:GetBool() or not ply.hgACNonce then return end

    local digest = net.ReadString()
    local flags = net.ReadUInt(16)
    local expected = util.CRC(ply.hgACNonce .. protocol)

    if digest ~= expected then
        Log(ply,"invalid heartbeat",digest)
        if action:GetInt() >= 1 then ply:Kick("HG AntiCheat: integrity response failed") end
        return
    end

    ply.hgACNonce = nil
    ply.hgACLastResponse = CurTime()

    if flags ~= 0 then
        ply.hgACIntegrityFlags = flags
        Log(ply,"client Lua functions changed","flags=" .. flags)
    end
end)

hook.Add("PlayerInitialSpawn","HG AntiCheat Init",function(ply)
    ply.hgACJoinGrace = CurTime() + 45
    ply.hgACMoveScore = 0
    timer.Simple(10,function() if IsValid(ply) then Challenge(ply) end end)
end)

hook.Add("PlayerSpawn","HG AntiCheat Spawn Grace",function(ply)
    ply.hgACMoveGrace = CurTime() + 5
    ply.hgACLastPos = ply:GetPos()
end)

timer.Create("HG AntiCheat Heartbeat",12,0,function()
    if not enabled:GetBool() then return end

    for _,ply in ipairs(player.GetHumans()) do
        if ply.hgACNonce and CurTime() - (ply.hgACChallengeAt or 0) > 35 then
            Log(ply,"heartbeat timeout")
            ply.hgACNonce = nil
            if action:GetInt() >= 1 and CurTime() > (ply.hgACJoinGrace or 0) then
                ply:Kick("HG AntiCheat: heartbeat timeout")
            end
        elseif not ply.hgACNonce then
            Challenge(ply)
        end
    end
end)

-- Generous movement sanity check. It records repeated impossible movement but
-- does not punish automatically because rounds, vehicles and ragdolls teleport.
timer.Create("HG AntiCheat Movement",0.25,0,function()
    if not enabled:GetBool() then return end

    for _,ply in ipairs(player.GetHumans()) do
        local pos = ply:GetPos()
        local old = ply.hgACLastPos
        ply.hgACLastPos = pos

        if not old or not ply:Alive() or CurTime() < (ply.hgACMoveGrace or 0)
        or ply:InVehicle() or ply:GetMoveType() == MOVETYPE_NOCLIP
        or ply:GetMoveType() == MOVETYPE_OBSERVER or ply:GetNWBool("fake") then continue end

        local distance = pos:Distance(old)
        local allowed = math.max((ply:GetRunSpeed() or 400) * 1.5,900)
        if distance > allowed then
            ply.hgACMoveScore = (ply.hgACMoveScore or 0) + 1
            if ply.hgACMoveScore == 4 then Log(ply,"repeated abnormal movement","distance=" .. math.floor(distance)) end
        else
            ply.hgACMoveScore = math.max((ply.hgACMoveScore or 0) - 0.25,0)
        end
    end
end)

concommand.Add("hg_ac_status",function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    for _,target in ipairs(player.GetHumans()) do
        local age = CurTime() - (target.hgACLastResponse or 0)
        print(string.format("[HG AC] %s heartbeat=%.1fs flags=%d movement=%.2f",target:Nick(),age,target.hgACIntegrityFlags or 0,target.hgACMoveScore or 0))
    end
end)

