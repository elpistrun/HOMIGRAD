local max = math.max

local PLAYER = FindMetaTable("Player")

function PLAYER:GetStamina()
	if CLIENT then return self:GetNW2Float("stamina",100) end
	return self.stamina or 100
end

function PLAYER:SetStamina(value)
	self.stamina = math.Clamp(tonumber(value) or 0,0,100)
	if SERVER then self:SetNW2Float("stamina",self.stamina) end
end

if SERVER then
	local function ResetMetabolism(ply)
		ply.stamina = 100
		ply.hungry = 10
		ply.blood = ply.blood or 5000
		ply.staminaRegenAt = 0

		ply:SetNW2Float("stamina",ply.stamina)
		ply:SetNW2Float("hungry",ply.hungry)
		ply:SetNW2Float("blood",ply.blood)
		ply:SetNW2Float("staminamul",1)
		ply:SetNW2Float("pulse",1 / 80)
	end

	hook.Add("PlayerSpawn","HG Metabolism Reset",ResetMetabolism)

	timer.Create("HG Metabolism Stamina",0.1,0,function()
		local dt = 0.1

		for _,ply in ipairs(player.GetAll()) do
			if not ply:Alive() then continue end

			ply.stamina = math.Clamp(ply.stamina or 100,0,100)
			ply.hungry = math.Clamp(ply.hungry or 10,0,10)
			ply.blood = math.Clamp(ply.blood or 5000,0,5000)

			local running = ply:GetMoveType() == MOVETYPE_WALK and ply:IsOnGround()
				and ply:KeyDown(IN_SPEED) and ply:KeyDown(IN_FORWARD)
				and ply:GetVelocity():Length2D() > ply:GetWalkSpeed()
				and not ply:InFake()

			if running and ply.stamina > 0 and not ply.stopStamina then
				local drain = {14 * dt * (ply.mulStamina or 1)}
				event.Call("Stamina Sub",ply,drain)
				ply.stamina = math.max(ply.stamina - (drain[1] or 0),0)
				ply.staminaRegenAt = CurTime() + 1.25
			elseif (ply.staminaRegenAt or 0) <= CurTime() then
				local hungerMul = 0.35 + ply.hungry / 10 * 0.65
				ply.stamina = math.min(ply.stamina + 10 * hungerMul * dt,100)
			end

			local exhausted = 1 - ply.stamina / 100
			local speedMul = math.Clamp(1 - exhausted * 0.5,0.5,1)
			local bpm = 80 + exhausted * 80

			ply:SetNW2Float("stamina",ply.stamina)
			ply:SetNW2Float("hungry",ply.hungry)
			ply:SetNW2Float("blood",ply.blood)
			ply:SetNW2Float("staminamul",speedMul)
			ply:SetNW2Float("pulse",1 / bpm)
		end
	end)
end

event.Add("Move","Homigrad Stamina",function(ply,mv)
	if not ply:Alive() then return end

	local maxspeed = mv:GetMaxSpeed() * ply:GetNW2Float("staminamul",1)

	mv:SetMaxSpeed(maxspeed)
	mv:SetMaxClientSpeed(maxspeed)
end)

local dir,vec_zero = Vector(),Vector()

event.Add("StartCommand","Dont Sprint Back",function(ply,cmd)
	if ply:GetStamina() <= 0 then cmd:RemoveKey(IN_SPEED) end

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

PLAYER.GetMetabolismPulse = function(self)  return self:GetNW2Float("pulse",1 / 80) end
PLAYER.GetMetabolismStaminaDelay = function(self) return 1 - (self:GetMetabolismPulse() / (1 / 80)) end

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
