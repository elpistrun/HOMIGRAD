if true then return end

Camera_Chache = Camera_Chache or {}

for k,v in pairs(Camera_Chache) do v:Remove() end

local SetBlend = render.SetBlend

local transforms = {}

hook.Add("PostDrawOpaqueRenderables","Dead Players CamerMAAANN",function()
	local lply = LocalPlayer()

	local func = levelActive.ShouldViewCamera
	if func and func() then elseif SpectateHideNick or lply:Alive() then return end

	local lpos = EyePos()

	for i,ply in pairs(player.GetAll()) do
		if not ply.PVS or ply == lply or ply:Alive() or ply:GetNWBool("SpecEnt") then continue end

		local pos = ply:GetPos()
		local ang = ply:EyeAngles()

		local dis = pos:Distance(lpos)
		if dis > 1000 then continue end

		local tr = transforms[ply]

		if not tr then
			tr = {pos,ang}

			transforms[ply] = tr
		end

		local mdl = Camera_Chache[ply]
		if not IsValid(mdl) then
			mdl = ClientsideModel("models/maxofs2d/camera.mdl")
			mdl:SetNoDraw(true)

			Camera_Chache[ply] = mdl
		end

		mdl:SetPos(tr[1])
		mdl:SetAngles(tr[2])

		tr[1]:LerpFT(0.25,pos)
		tr[2]:LerpFT(0.1,ang)

		SetBlend(1 - dis / 1000)

		mdl:DrawModel()
	end

	SetBlend(0)
end)

local white = Color(255,255,255)

hook.Add("HUDPaint","Dead Players CamerMAAANN",function()
	local lply = LocalPlayer()
	local lpos = EyePos()

	local func = levelActive.ShouldViewCamera
	if func and func() then elseif SpectateHideNick or lply:Alive() then return end

	for i,ply in pairs(player.GetAll()) do
		if not ply.PVS or ply == lply or ply:Alive() or ply:GetNWBool("SpecEnt") then continue end

		local tr = transforms[ply]

		if not tr then continue end

		local pos = tr[1]

		local dis = pos:Distance(lpos)
		white.a = 25 * (1 - dis / 1000)

		pos = pos:ToScreen()

		draw.SimpleText(ply:Name(),"H.18",pos.x,pos.y,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
end)