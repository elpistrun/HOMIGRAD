local PLAYER = FindMetaTable("Player")

function PLAYER:SetMuted(value)
	self.isMuted = value

	UpdateVoiceVolumeScale()
end

plyVoice:Event_Add("Volume","Muted",function(ply,value)
	if ply.isMuted then value[1] = 0 return false end
end,-10)

plyVoice:Event_Add("Volume","Muted",function(ply,value)
	if not InitNET then value[1] = 0 return false end
end,-1000)

function PLAYER:IsMuted() return self.isMuted end

if not HSetVoiceVolumeScale then HSetVoiceVolumeScale = PLAYER.SetVoiceVolumeScale end
local HSetVoiceVolumeScale = HSetVoiceVolumeScale
local event_Run = event.Run

function PLAYER:UpdateVoiceVolumeScale()
	local value = {1}

	if plyVoice:Event_Call("Volume",self,value) == false then value[1] = 0 end

	value = value[1]

	if self.voiceVolumeScale ~= value then
		self.voiceVolumeScale = value
		HSetVoiceVolumeScale(self,value)
	end
end

function plyVoice.Update()
	for i,ply in pairs(player.GetAll()) do
		if ply == LocalPlayer() then continue end

		ply.voiceVolumeScale = nil

		ply:UpdateVoiceVolumeScale()
	end
end

if not HVoiceVolume then HVoiceVolume = PLAYER.VoiceVolume end

function PLAYER:VoiceVolume()
	if self == LocalPlayer() and not GetConVar("voice_loopback"):GetBool() then
		return self.voiceEmit and 0.15 + math.cos(RealTime() * 50) / 7 or 0
	else
		return HVoiceVolume(self)
	end
end

plyVoice:Event_Add("Volume","Game",function(ply,value)
	value[1] = ply.worldVoiceVolume or 1
end,-2)

local hg_radio_volume = 1
cvars.CreateOption("hg_radio_volume","1",function(value) hg_radio_volume = tonumber(value or 0) or 0 end,0,1)

local Player = Player

net.Receive("voice",function()
	for userID,data in pairs(net.ReadTable()) do
		local ply = Player(userID)
		if not ply.SetVoiceVolumeScale then continue end

		local volume = data[1]
		local typeEmit = data[2]

		ply.voiceIsRadio = false
		ply.voiceIs3D = false
		
		if typeEmit == "radio" then
			ply.voiceIsRadio = true
			ply.worldVoiceVolume = hg_radio_volume
		elseif typeEmit == true then
			ply.voiceIs3D = true
			ply.worldVoiceVolume = volume
		elseif typeEmit == false then
			ply.worldVoiceVolume = 1
		else
			ply.worldVoiceVolume = volume
		end

		ply:UpdateVoiceVolumeScale()
	end
end)

local hg_voiceflex

cvars.CreateOption("hg_voiceflex","1",function(value) hg_voiceflex = tonumber(value) > 0 end)

ModelSettings_Flex = ModelSettings_Flex or {}

local defaultFlex = {
	"jaw_drop",
	"left_part",
	"right_part",
	"left_mouth_drop",
	"right_mouth_drop",

	"A",
	"mouth_a",
	"mouthA"
}

function SetFlexMouth(ply,ent,mul)
	if not hg_voiceflex then return end

	local flexes = ModelSettings_Flex[ent:GetModel()] or defaultFlex

	local weight = ply:IsSpeaking() and math.Clamp(ply:VoiceVolume() * 5,0,5) * mul

	if weight then
		ent.oldFlex = {}

		for k, v in pairs(flexes) do
			v = ent:GetFlexIDByName(v)
			if not v then continue end
		
			ent.oldFlex[k] = v

			ent:SetFlexWeight(v,weight)
		end
	else
		if ent.oldFlex then
			for k, v in pairs(ent.oldFlex) do
				ent:SetFlexWeight(v,0)
			end

			ent.oldFlex = nil
		end
	end
end

local white = Color(165,165,165)
local mat = Material("homigrad/vgui/icons/speaker/voice_3.png")

function PlayerBones_Mouth(ply,tag,link)
	if not ply.voiceEmit then return end

	if (ply.SetFlexMountDelay or 0) > RealTime() then
		ply.SetFlexMountDelay = RealTime() + 1 / (math.random(29,31))

		SetFlexMouth(link or ply,ply,2)
	end
end

local empty = {}

hook.Add("PostDrawTranslucentRenderables","Voice",function()
	local HUD = plyVoice.HUD

	for steamid64 in pairs(IsValid(HUD) and HUD.listID or empty) do
		local ply = player.GetBySteamID64(steamid64)
		if not ply:Alive() or ply:IsDormant() then continue end

		local head = ply:LookupBone("ValveBiped.Bip01_Head1")
	
		if not head then
			vec = ply:EyePos()
			vec[3] = vec[3] + 25
		else
			vec = ply:GetDummy():GetBoneMatrix(head)
			if not vec then return end

			vec = vec:GetTranslation()
			vec[3] = vec[3] + 15
		end
	
		local volume = ply:VoiceVolume() or 0
		if volume <= 0 then return end
	
		ply.voiceLerpScene = LerpFT(0.2,ply.voiceLerpScene or 0,255 * math.min(volume * 15,1))
	
		white.a = 168 * (ply.voiceLerpScene / 255)
		
		render.SetMaterial(mat)
		render.DrawSprite(vec,8,8,white)
	end
end)