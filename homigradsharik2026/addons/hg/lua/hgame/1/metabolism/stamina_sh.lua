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

function PLAYER:RelieveBreath(value)
	if not SERVER then return end
	self.breathLoad = math.max((self.breathLoad or 0) - (tonumber(value) or 0),0)
	self:SetNW2Float("breath_load",self.breathLoad)
end

if SERVER then
	util.AddNetworkString("breath")
	util.AddNetworkString("cough")

	local function SendBreath(ply,strength)
		local delay = Lerp(math.Clamp(strength,0,1),0.95,0.32)
		ply.breathModeOut = not ply.breathModeOut

		net.Start("breath")
		net.WriteEntity(ply)
		net.WriteString(tostring(delay))
		net.WriteBool(not ply.breathModeOut)
		net.SendPVS(ply:GetPos())

		ply.nextBreathAt = CurTime() + delay
	end

	local function ResetMetabolism(ply)
		ply.stamina = 100
		ply.hungry = 10
		ply.blood = ply.blood or 5000
		ply.staminaRegenAt = 0
		ply.breathLoad = 0
		ply.nextBreathAt = 0
		ply.breathModeOut = false

		ply:SetNW2Float("stamina",ply.stamina)
		ply:SetNW2Float("hungry",ply.hungry)
		ply:SetNW2Float("blood",ply.blood)
		ply:SetNW2Float("staminamul",1)
		ply:SetNW2Float("pulse",1 / 80)
		ply:SetNW2Float("breath_load",0)
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

			if not running then ply.staminaRunK = 0 end

			if running and ply.stamina > 0 and not ply.stopStamina then
				-- Smooth drain: eases in over the first second of sprinting
				-- instead of slamming in, plus a gentler health penalty.
				ply.staminaRunK = math.min((ply.staminaRunK or 0) + dt / 1.2,1)

				local runK = Lerp(ply.staminaRunK,0.3,1)
				local hp = math.Clamp(ply:Health() / math.max(ply:GetMaxHealth(),1),0,1)
				local hpMul = 1 + (1 - hp) * 0.4
				local drain = {1.8 * dt * (ply.mulStamina or 1) * hpMul * runK}
				event.Call("Stamina Sub",ply,drain)
				local spent = math.max(drain[1] or 0,0)
				ply.stamina = math.max(ply.stamina - spent,0)
				ply.breathLoad = math.min((ply.breathLoad or 0) + spent,100)
				ply.staminaRegenAt = CurTime() + 0.9
			elseif ply:InFakeDeath() then
				-- Lying in fake (fake death) slowly restores stamina and clears breath
				if (ply.staminaRegenAt or 0) <= CurTime() then
					ply.stamina = math.min((ply.stamina or 100) + 8 * dt,100)
				end
				ply.breathLoad = math.max((ply.breathLoad or 0) - 12 * dt,0)
			elseif (ply.staminaRegenAt or 0) <= CurTime() then
			-- Gentle passive regen so stamina isn't permanently punishing.
			ply.stamina = math.min((ply.stamina or 100) + 3.5 * dt,100)
			ply.breathLoad = math.max((ply.breathLoad or 0) - 5 * dt,0)
		end

			-- The longer the sprint and the lower the stamina, the louder/faster
			-- and stronger the choking: smaller stamina -> stronger effect.
			if not running then
				local exhausted = 1 - (ply.stamina or 100) / 100
				local strength = math.max((ply.breathLoad or 0) / 100,(exhausted - 0.4) * 1.4)

				if strength > 0.05 then
					if (ply.nextBreathAt or 0) <= CurTime() then SendBreath(ply,strength) end
					ply.breathLoad = math.max((ply.breathLoad or 0) - (1.5 + strength * 2.5) * dt,0)
				else
					ply.breathLoad = math.max((ply.breathLoad or 0) - 5 * dt,0)
				end
			end

			-- Gas 1/2 drain
			if HomigradGas then
				local gasDrain = 0
				for _,gas in ipairs(HomigradGas) do
					if IsValid(gas) and gas:GetNWFloat("Size",0) > 0 and ply:GetPos():Distance(gas:GetPos()) < gas:GetNWFloat("Size",0) and gas:CanSee(ply,ply:EyePos()) then
						gasDrain = gasDrain + 4 * dt
					end
				end
				if gasDrain > 0 then
					ply.stamina = math.max(ply.stamina - gasDrain,0)
					ply.breathLoad = math.min((ply.breathLoad or 0) + gasDrain * 0.5,100)
					ply.staminaRegenAt = CurTime() + 0.9
				end
			end

			local exhausted = 1 - ply.stamina / 100
			-- Preserve normal running speed for most of the bar. Only the final
			-- 20% gradually slows the player, without the former 50% speed cliff.
			local lowStamina = math.Clamp(ply.stamina / 20,0,1)
			local speedMul = Lerp(lowStamina,0.8,1)
			local bpm = 80 + exhausted * 80

			ply:SetNW2Float("stamina",ply.stamina)
			ply:SetNW2Float("hungry",ply.hungry)
			ply:SetNW2Float("blood",ply.blood)
			ply:SetNW2Float("staminamul",speedMul)
			ply:SetNW2Float("pulse",1 / bpm)
			ply:SetNW2Float("breath_load",ply.breathLoad or 0)
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
