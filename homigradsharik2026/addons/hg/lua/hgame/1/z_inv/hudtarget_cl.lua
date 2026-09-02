local targetEntity

function GetHUDTarget() return targetEntity end

local halosColor = Color(255,255,255,75)
local tableHallos = {}

hook.Add("PreDrawHalos","HudTarget",function()
	tableHallos[1] = targetEntity

	halo.Add(tableHallos,halosColor,1,1,1)
end)

local listTargetEntity = {}

local tr = {
	mask = MASK_SHOT,
	output = {}
}

local function findTarget()
	local ply = LocalPlayer()

	local pos,ang = ply:Eye()

	tr.start = pos
	tr.endpos = pos + ang:Forward():Mul(PlayerDisUse)
	tr.filter = ply:GetDummy()

	local trace = util.TraceLine(tr)

	local ent = trace.Entity

	for i,ent in pairs(ents.FindInSphere(pos,PlayerDisUse)) do
		if not ent.DeterminateUse or ent:GetNoDraw() or (not ent.AlwaysDeterminateUse and not ent:IsSolid()) then continue end
		
		local result = ent:DeterminateUse(ply,trace)
		if result ~= true then continue end

		return ent
	end

	if IsValid(ent) then
		if ent.DeterminateUse then
			local result = ent:DeterminateUse(ply,trace)

			if result ~= true then return end
		end

		return ent
	end
end

function HUDTargetRenderText(text,k,color)
	color.a = 255 * k

	local x,y = ScrW() / 2,ScrH() / 2 - 50 * (1 - k)

	draw.SimpleText(L(text),"HS.18",x,y,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

	return x,y
end

local oldActiveButton

hook.Add("HUDPaint","HudTarget",function()
	local lply = LocalPlayer()

	if not lply:Alive() or lply:InFake() then return end

	targetEntity = nil

	local w,h = ScrW(),ScrH()
	
	halosColor.a = 255
	halosColor.g = 255
	halosColor.b = 255
	halosColor.a = 75

	local ent = findTarget()

	local activeButton = lply:KeyDown(IN_USE)
	
	local lply = LocalPlayer()

	if activeButton and ent and not lply:IsCooldown("use") then
		if event.Call("Use",lply,ent) != false then
			net.Start("use")
			net.WriteEntity(ent)
			net.SendToServer()

			if not lply:IsCooldown("use") then lply:SetCooldown("use",0.1) end
		end
	end

	if ent then
		local k = listTargetEntity[ent]

		local result = event.Run("HUD Target",ent,k or 0,w,h)

		surface.SetAlphaMultiplier(k or 1)

		if not result and ent.HUDTarget then
			result = ent:HUDTarget(ent,k or 0,w,h)
			if result == nil then result = true end
		end

		surface.SetAlphaMultiplier(1)

		if result then
			if IsColor(result) then
				halosColor.r = result.r
				halosColor.g = result.g
				halosColor.b = result.b
				halosColor.a = result.a
			end

			targetEntity = ent

			if not k then listTargetEntity[ent] = 0 end
		end
	end

	for ent,k in pairs(listTargetEntity) do
		if not IsValid(ent) then listTargetEntity[ent] = nil continue end

		local active = targetEntity == ent and 1 or 0

		k = LerpFT(0.26,k,active)

		listTargetEntity[ent] = k

		if active == 0 then
			surface.SetAlphaMultiplier(k or 1)

			if event.Run("HUD Target",ent,k,w,h) ~= true then
				ent:HUDTarget(ent,k or 0,w,h)
			end

			surface.SetAlphaMultiplier(1)

			if k <= 0.01 then listTargetEntity[ent] = nil end
		end
	end
end)

local white = Color(255,255,255)

local tbl = {
	["prop_door_rotating"] = "door",
	["class C_BaseEntity"] = "button", -- будем надеется что это кнопка,
	["class C_BaseToggle"] = "button"
}

event.Add("HUD Target","Buttons",function(ent,k,w,h)
	local text = tbl[ent:GetClass()]

	if text then
		HUDTargetRenderText(text,k,white)

		return true
	end
end)

--

local size = 98
local color = Color(255,255,255)

local WeaponIconMatrix = render.WeaponIconMatrix

event.Add("HUD Target","Weapon",function(ent,k,w,h)
    local obj = weapons.Get(ent:GetClass())
	
    if obj then
        local func = ent.CanHUDTarget
        if func and func(ent) == false then return true end

        surface.SetAlphaMultiplier(k)
        render.SetBlend(k)

		local x,y = HUDTargetRenderText(obj.PrintName or ent:Getclass(),k,color)

        render.SetBlend(math.min(k * 15,1))
        
        render.ClearWeaponIcon()

        WeaponIconMatrix.self = ent
        WeaponIconMatrix.x = x - size / 2
        WeaponIconMatrix.y = y
        WeaponIconMatrix.w = size
        WeaponIconMatrix.h = size
        WeaponIconMatrix.Pos = ent.dwsPos
        WeaponIconMatrix.Ang = ent.dwsAng
		WeaponIconMatrix.tag = "hudtarget"

        surface.SetAlphaMultiplier(1)
        render.SetBlend(1)

        return true
    end
end)