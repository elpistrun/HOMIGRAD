FindMetaTable("Player").IsGhostWalk = function(self) return self:KeyDown(IN_DUCK) end

hook.Add("CalcMainActivity","Run",function(ply,vel)
    if ply:InVehicle() or not ply:IsOnGround() or vel:Length() <= 280 then return end

    return ACT_RUN,ply:LookupSequence("run_all_02")
end)

FindMetaTable("Player").GetDelayFootstep = function(self)
	local velMetrs = self:GetVelocity():Length() * UNITS_TO_METERS
	if velMetrs <= 0.6 then return end

	return Lerp(velMetrs / 6,0.6,0.28),math.min(math.max(velMetrs - 0.6,0) / 1,1)
end

event.Add("Player Think 20","Footstep",function(ply)
	if CLIENT and ply != LocalPlayer() then return end
	
    if not ply:Alive() or not ply:IsOnGround() or ply:GetMoveType() != MOVETYPE_WALK then return end
	if CLIENT and ply:GetPos():Distance(RenderView.origin) * UNITS_TO_METERS > SOUND_FOOTSTEP_METRS then return end
	
	local delay = ply:GetDelayFootstep()
	if not delay then return end

    if (ply.lastFootTime or 0) + delay < CurTime() then
        ply.lastFootTime = CurTime()
		ply.footMode = not ply.footMode

		if ply:IsGhostWalk() then return end

		local surfaceName,pos = player.GetFootstepSurface(ply)

		event.Call("Footstep",ply,ply.footMode,surfaceName,pos)
    end
end)

local cos,sin,rad,min,max = math.cos,math.sin,math.rad,math.min,math.max

hook.Add("UpdateAnimation","Footstep",function(ply,velocity,maxSpeed)
	if ply:GetMoveType() == MOVETYPE_NOCLIP then ply:SetPoseParameter("move_x",0); ply:SetPoseParameter("move_y",0); return end
	local speed = velocity:Length()

	local move_x,move_y = 0,0

	local lowSpeedMul = 0

	if speed > 1 then
		lowSpeedMul = min(speed / 60,1)

		local multiply = Lerp(lowSpeedMul,speed * UNITS_TO_METERS / 3,max(speed * UNITS_TO_METERS,2.5) / 3)

		local dx = velocity[1] / speed
		local dy = velocity[2] / speed

		local yaw = rad(ply:EyeAngles()[2])
		local cy = cos(yaw)
		local sy = sin(yaw)

		move_x =  dx * cy + dy * sy
		move_y = -dx * sy + dy * cy

		move_x = move_x * multiply
		move_y = -move_y * multiply
	end

	local lerp = Lerp(lowSpeedMul,0.8,0.33)

	ply.move_x = LerpFT(lerp,ply.move_x or 0,move_x)
	ply.move_y = LerpFT(lerp,ply.move_y or 0,move_y)

    local mul = 1
	
	ply:SetPoseParameter("move_x",ply.move_x * mul)
	ply:SetPoseParameter("move_y",ply.move_y * mul)
end)