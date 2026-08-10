local max = math.max

event.Add("Move","Homigrad Stamina",function(ply,mv)
	if not ply:Alive() then return end

	local maxspeed = mv:GetMaxSpeed() * ply:GetNW2Float("staminamul",1)

	mv:SetMaxSpeed(maxspeed)
	mv:SetMaxClientSpeed(maxspeed)
end)

local dir,vec_zero = Vector(),Vector()

event.Add("StartCommand","Dont Sprint Back",function(ply,cmd)
	if ply:GetMoveType() == MOVETYPE_WALK and ply:IsOnGround() and cmd:KeyDown(IN_SPEED) and not ply:GetNWBool("Fake") then
		if not ply.startRun then ply.startRun = CurTime() end

		local k = 1 - math.max((ply.startRun + DEFAULT_RUNSPEED_DELAYSPRING - CurTime()) / DEFAULT_RUNSPEED_DELAYSPRING,0)

		dir:Set(vec_zero)
		
		if cmd:KeyDown(IN_FORWARD) then dir[1] = dir[1] + 1 end
		if cmd:KeyDown(IN_BACK) then dir[1] = dir[1] - 1 end

		if cmd:KeyDown(IN_MOVELEFT) then dir[2] = dir[2] - 1 end
		if cmd:KeyDown(IN_MOVERIGHT) then dir[2] = dir[2] + 1 end

		if dir[1] == 0 and dir[2] == 0 then return end

		local walkSpeed = ply:GetWalkSpeed()
		local runSpeed = ply:GetRunSpeed()

		dir[1] = dir[1] * runSpeed

		if dir[1] <= 0 then
			cmd:RemoveKey(IN_SPEED)

			return
		else
			dir[2] = dir[2] * runSpeed / 2.5
		end

		k = math.max(k,walkSpeed / runSpeed + 0.3)

		dir[1] = dir[1] * k
		dir[2] = dir[2] * k


		cmd:ClearMovement()

		cmd:SetForwardMove(dir[1])
		cmd:SetSideMove(dir[2])
	else
		ply.startRun = nil
	end
end)

local pulseStart = 0

FindMetaTable("Player").GetMetabolismPulse = function(self)  return self:GetNW2Float("pulse",1 / 80) end
FindMetaTable("Player").GetMetabolismStaminaDelay = function(self) return 1 - (self:GetMetabolismPulse() / (1 / 80)) end

hook.Add("RenderScreenspaceEffects","Stamina",function()
	local ply = LocalPlayer()
	if not ply:Alive() or ply:GetNWBool("Otrub") then return end

	local pulse = 1 / ply:GetMetabolismPulse()

	local volume = 1 - pulse / 80

	volume = volume / 2

	local time = RealTime()

	if volume <= 0 then return end

	if pulseStart + 1 / pulse * 60 < time then
		pulseStart = time 

		if volume > 0.1 then
			LocalPlayer():EmitSound("snd_jack_hmcd_heartpound.wav",75,100,volume)
			LocalPlayer():ViewPunch(Angle(-3 * volume,0,0))
		end
	end
	
	if hook.Run("Should Draw Screenspace") == false then return end

	//DrawSobel(ply:GetNWFloat("adrenaline") / 4)
end)
