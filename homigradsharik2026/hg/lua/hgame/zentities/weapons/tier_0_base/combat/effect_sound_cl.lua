local SWEP = oop.Get("hg_wep")
if not SWEP then return end


local min,max = math.min,math.max

local TraceLine = util.TraceLine

local disCloseMax = 45
local disFarEnd = 150
local disFarEndInDoor = 100

local hg_dev_dontsoundshoot

cvars.CreateDevOption("hg_dev_dontsoundshoot","0",function(value)
	hg_dev_dontsoundshoot = tonumber(value or 0) > 0
end,0,1)

function SWEP:ShootSound(pos,ang,entIndex,silence)
	if hg_dev_dontsoundshoot then return end
	
	local ent = Entity(entIndex)

	local isLocal

	if not IsValid(ent) or not ent:IsLocal() then
		ent = sound.GetVurtialEmit(pos,entIndex)
	else
		if GetViewEntity() == LocalPlayer() then
			ent = LocalPlayer()
			isLocal = true
		else
			ent = sound.GetVurtialEmit(pos,entIndex)
		end
	end
	
	local soundTable = self.Primary.Sound

	local soundClose
	local soundDistant

	local soundPositionState = sound.GetPositionState(pos,ent)

	if soundPositionState == "indoors" then
		if silence then
			soundClose = soundTable.indoor_close_silence or soundTable.indoor_close
			soundDistant = soundTable.indoor_distant_silence or soundTable.indoor_close
		else
			soundClose = soundTable.indoor_close
			soundDistant = soundTable.indoor_distant or soundTable.distant
		end
	else
		if silence then
			soundClose = soundTable.outdoor_close_silence
			soundDistant = soundTable.outdoor_distant_silence or soundTable.distant
		else
			soundClose = soundTable.outdoor_close
			soundDistant = soundTable.outdoor_distant or soundTable.distant
		end
	end

	soundClose = soundClose[math.random(1,#soundClose)]
	if soundDistant then soundDistant = soundDistant[math.random(1,#soundDistant)] end

	coroutine.wrap(function()
		local metrs = pos:Distance(RenderView.origin) * UNITS_TO_METERS

		sound.WaitDistance(metrs)
		if not IsValid(ent) then return end

		local dsp = 0

		if not silence then
			sound.EmitGunShoot(isLocal and ent or pos,entIndex .. "dwr",self.Primary.DWRName or "carabine",1)
		end

		if not isLocal then
			ent.pos = pos

			ent.panoramaEffect = silence and 0.3 or 0.9
			ent.Think = sound.ThinkGoAway
			ent:Think()
		end

		local pitch = self.Primary.SoundPitch or 100

		local t = 1 - min(metrs / disCloseMax,1)

		if t > 0 then
			if ent.lastSoundClose then ent:StopSound(ent.lastSoundClose) end
			ent.lastSoundClose = soundClose

			t = min(t * 1.2,1)

			sound.EmitNative(ent,soundClose,140,t,Lerp(t,pitch - 20,pitch),nil,dsp,CHAN_STATIC)
		end

		if self.Primary.Silencer then return end

		local disFarEnd = soundPositionState == "indoors" and disFarEndInDoor or disFarEnd
		local t = 1 - min(metrs / disFarEnd,1)

		local kFade = (1 - disCloseMax / disFarEnd + 0.1)

		if t > kFade then
			t = 1 - (t - kFade) / (1 - kFade)
			t = math.max(t - 0.7,0) / 0.3
		end
		
		local volumeDistant = t

		if soundDistant and t > 0 then
			if ent.lastSoundDistant then ent:StopSound(ent.lastSoundDistant) end
			ent.lastSoundDistant = soundDistant

			sound.EmitNative(ent,soundDistant,140,volumeDistant,Lerp(t,pitch - 20,pitch),nil,dsp,CHAN_STATIC)
		end
	end)()
end