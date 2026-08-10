local black = Color(0,0,0,200)
local white = Color(255,255,255)

local radio = Material("icon16/feed.png")

local cframe1,cframe2 = Color(255,255,255,75),Color(0,0,0,125)

local white = Color(255,255,255)

function plyVoice.Draw(w,h,ply,forceMul)
	local force = ply:VoiceVolume() * 1.5 * forceMul

	surface.SetFigure("circle")

	local color = ply:GetUserColor() or white
	surface.SetDrawColor(color.r,color.g,color.b,math.max(255 * force,75))

	force = force + 0.75 * math.min(force * 10,1) * forceMul

	DisableClipping(true)
	draw.Figure(w/2,h/2,w * force,h * force)
	DisableClipping(false)
end

local function drawPanelAvatar(self,w,h)
	local ply = player.GetBySteamID64(self.steamid64)
	if not IsValid(ply) then return end

	plyVoice.Draw(w,h,ply,self.panel.lerp)
end

local function drawPanel(self,w,h)
	local ply = player.GetBySteamID64(self.steamid64)
	if not IsValid(ply) then return end
	
	local k = self.lerp

	if ply:Alive() then
		if not ply:GetBackground() then
			surface.SetDrawColor(20,20,20,200)
			surface.DrawRect(0,0,w,h)
		end
	else
		surface.SetDrawColor(255,0,0,55)
		surface.DrawRect(0,0,w,h)
	end

	if levelActive.red and levelActive.blue then
		local name,color = ply:GetTeamStatus()

		if color then
			surface.SetDrawColor(color)
			local size = h / 6
			surface.DrawRect(w - size + 1,0,size,h)
			local size2 = h / 2
			draw.GradientRight(w - size - size2 + 1,0,size2,h)
		end
	end

	if ply.voiceIsRadio then
		surface.SetDrawColor(255,125,0,25)
		surface.DrawRect(0,0,w,h)
	end

	if not IS64BIT then draw.SimpleText(ply:Name(),"ChatFont",w / 2,h / 2,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end

	if ply.voiceIsRadio then
		surface.SetDrawColor(255,255,255,25)
		surface.SetMaterial(radio)
		local size = 30 + 2.5 * math.sin(CurTime() * 15)
		surface.DrawTexturedRectRotated(h / 2,h / 2,size,size,math.cos(CurTime() * 30) * 10)
	end

	draw.Frame(0,0,w,h,cframe1,cframe2)
end

hook.Add("PlayerStartVoice","Homigrad",function(ply)
	if not InitNET or not IsValid(ply) then return true end

	ply.StartVoice = RealTime()
	ply.voiceEmit = true

    local HUD = plyVoice.HUD

	if not IsValid(HUD) then return end
	
	if HUD.listID[ply:SteamID64()] then
		HUD.list[HUD.listID[ply:SteamID64()]].lerp = 1

		return true
	end

	local panel,avatar = HUD:AddPlayer(ply)
	panel.steamid64 = ply:SteamID64()
	panel.lerp = 1
	panel.Draw = function(self,w,h)
		surface.SetAlphaMultiplier(panel.lerp)
		drawPanel(self,w,h)
		surface.SetAlphaMultiplier(1)
	end

	avatar.panel = panel
	avatar.steamid64 = ply:SteamID64()
	avatar.Draw = function(self,w,h)
		drawPanelAvatar(self,w,h)
	end
	
	return true
end)

hook.Add("PlayerEndVoice","Homigrad",function(ply)
	if not IsValid(ply) then return true end

	ply.voiceEmit = nil

	return true
end)

local hg_show_voicehud

function plyVoice.CreateHUD()
	if IsValid(plyVoice.HUD) then plyVoice.HUD:Remove() end

	local size = 40

	plyVoice.HUD = oop.CreatePanel("v_avatarlist"):ad(function(self,w,h)
		self:setSize(math.max(300,ScrW() *0.175),self:H()):setPos(w - 32 - self:W(),h - 32 - self:H())
	end)

    local HUD = plyVoice.HUD

	HUD:SetZPos(-100)
	HUD:Setup(size)

	function HUD:Step(w,h)
		local H = size * 0.25
	
		for steamid64,iteration in pairs(HUD.listID) do
			local panel = HUD.list[iteration].panel
			local ply = player.GetBySteamID64(steamid64)

			if not IsValid(ply) or (panel.lerp or 1) < 0.01 then
				HUD:RemovePanel(steamid64)

				continue
			end

			H = H + size + size * 0.25
			HUD:SetAlphaPanel(steamid64,panel.lerp)

			panel.lerp = LerpFT(ply.voiceEmit and 0.5 or 0.15,panel.lerp or 0,ply.voiceEmit and 1 or 0)
		end

		if H == 0 then H = 1 end
		HUD:setSize(HUD:W(),H,true)
		HUD:InvalidateChildren()
	end
end

cvars.CreateOption("hg_show_voicehud","1",function(value)
	hg_show_voicehud = tonumber(value or 0) > 0

	if hg_show_voicehud then
		plyVoice.CreateHUD()
	else
		if IsValid(plyVoice.HUD) then plyVoice.HUD:Remove() end
	end
end)

event.Add("Think","plyVoice.HUD",function()
	if not hg_show_voicehud or IsValid(plyVoice.HUD) then return end
	
	plyVoice.CreateHUD()
end)