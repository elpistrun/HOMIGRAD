local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

util.AddNetworkString("weapon_action")

-- Counterpart of net.WriteEyeAttack from shlib/0/net_0/init_cl.lua.
-- Keep the reported muzzle close to the authoritative server position so a
-- modified client cannot start bullets from an arbitrary point on the map.
net.ReadEyeAttack = net.ReadEyeAttack or function(serverPos,serverAng)
    local pos = Vector(net.ReadDouble(),net.ReadDouble(),net.ReadDouble())
    local ang = Angle(net.ReadDouble(),net.ReadDouble(),net.ReadDouble())
    local renderTime = net.ReadDouble()

    if pos:DistToSqr(serverPos) > 16384 then pos = serverPos end
    renderTime = math.Clamp(renderTime,UnPredictedCurTime() - 1,UnPredictedCurTime() + 0.1)

    return pos,ang,renderTime
end

net.Receive("weapon_action",function(len,ply)
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or wep:GetOwner() != ply or not wep.Actions then return end

    local name = net.ReadString()
    local action = wep.Actions[name]
    if not action then return end

    local cmd = {
        name = name,
        ply = ply,
        startTime = UnPredictedCurTime()
    }

    if action.netRead then action.netRead(wep,cmd) end

    -- Do not let an already finished server animation poison the next input.
    -- This also recovers weapons created before their animation flags were
    -- reconstructed after a Lua refresh.
    local sequenceObject = wep.sequenceObject
    if sequenceObject and sequenceObject.IsEnd and sequenceObject:IsEnd() then
        wep:ResetAnimation("server_action_cleanup")
        if wep.SyncAnimation then wep:SyncAnimation() end
    end

    local success,err = wep:DoAction(cmd)
    if success then return end

    local activeSequence = wep.sequenceObject
    MsgC(Color(255,180,80),"[HG weapon action] ",Color(255,255,255),
        tostring(ply)," / ",tostring(wep:GetClass())," / ",tostring(name),
        " rejected: ",tostring(err or "action rejected"),
        " (sequence=",tostring(activeSequence and activeSequence.name or "none"),")\n")

    net.Start("weapon_action")
    net.WriteTable({name = name,err = err or "action rejected"})
    net.Send(ply)
end)
