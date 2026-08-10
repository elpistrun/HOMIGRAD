ZoneDistance = ZoneDistance or 0

adminPanel.commandRegistry("zone",{"number","number"},"game")
adminPanel.commandRegistry("zone_speed",{"number"},"game")

local red = Color(255,0,0,75)
local mat = Material("color")

hook.Add("PostDrawTranslucentRenderables","Zone",function()
	ZoneOrigin = GetGlobalVar("Zone")
	
	if not ZoneOrigin then
		if snd and snd:IsPlaying() then snd:Stop() end

		return
	end

	local set = GetGlobalVar("ZoneDistance")
	if not set then return end--lol
	
	if set - ZoneDistance > 128 then ZoneDistance = set end --weeee

	ZoneDistance = LerpFT(0.01,ZoneDistance,set)

	local ply = LocalPlayer()

	local k = math.max(1 - math.abs(ZoneDistance - ply:GetPos():Distance(ZoneOrigin)) / 1000,0)

	red.a = 255 * k

	render.SetMaterial(mat)
	render.DrawSphere(ZoneOrigin,ZoneDistance,64,64,red)
	render.DrawSphere(ZoneOrigin,-ZoneDistance,64,64,red)

	if not snd or not snd:IsPlaying() then
		snd = CreateSound(ply,"ambient/energy/force_field_loop1.wav")
		snd:PlayEx(0,0)
	end

	/*if not ply:Alive() then
		if snd and snd:IsPlaying() then snd:Stop() end

		return
	end*/

	snd:ChangePitch(math.Clamp(155 * k,75,255))
	snd:ChangeVolume(0.5 * k)
end)

adminPanel.commandRegistry("redzone",{{type = "number",name = "distance",require = true},{type = "number",name = "speed",require = true}})