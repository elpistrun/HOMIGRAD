local cl_interp = GetConVar("cl_interp")
local cl_interp_ratio = GetConVar("cl_interp_ratio")
local cl_updaterate = GetConVar("cl_updaterate")

local max = math.max

function GetLerpTime()
    local interp = cl_interp:GetFloat()
    local ratio = cl_interp_ratio:GetFloat()
    local updaterate = cl_updaterate:GetFloat()
    
    return max(interp, ratio / updaterate)
end

function GetRenderTime()
    return UnPredictedCurTimeTick() - GetLerpTime() - TickInterval() * 3
end

function GetRenderTick()
    return UnPredictedCurTimeTick() - GetLerpTime() - Ping() / 2
end

ClientLastAttackDownTime = ClientLastAttackDownTime or 0

hook.Add("CreateMove","LastAttackDown",function(cmd)
	if cmd:KeyDown(IN_ATTACK) then ClientLastAttackDownTime = RealTime() end
end)

net.WriteEyeAttack = function(pos,ang)
    net.WriteDouble(pos[1])
    net.WriteDouble(pos[2])
    net.WriteDouble(pos[3])

    net.WriteDouble(ang[1])
    net.WriteDouble(ang[2])
    net.WriteDouble(ang[3])

    net.WriteDouble(GetRenderTime())
end