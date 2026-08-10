local view = {}

local old

local vecFull = Vector(1,1,1)

SpectateVec = EyePos()

local outdistance = 75
local outface,forwardface = 0,0

local watchFace

local function getVehicle(ply,filter)
	if not ply.GetVehicle then return end
	
	local vehicle = ply:GetVehicle()

	if IsValid(vehicle) then
		filter[#filter + 1] = vehicle

		vehicle = vehicle:GetParent()

		if IsValid(vehicle) then
			filter[#filter + 1] = vehicle:GetParent()
		end
	end
end

local closedPlyVec = Vector()//для плавного перехода

local oldSpectate

local filter = {}

local tr = {
	filter = function(ent)
		return not filter[ent]
	end,
	output = {}
}

local MatrixSet = Matrix()

event.Add("PreCalcView","spectate",function(ply,view)
	if CameraSpectator then return end

	ply = LocalPlayer()

	if ply:Alive() then outdistance = 75 return end
	
	local func = levelActive.DisableSpectate
	if func and func(ply,view) ~= false then return end

	local vec,ang = view.vec,view.ang
	local spec = SpecEnt
	
	oldSpectate = spec

	SpectateVec:LerpFT(0.25,ply:GetPos())

	view.mulSide = 0.5
	
	if not IsValid(spec) then
		view.vec = SpectateVec
		view.ang = ang

		return view
	end

	local ent = spec:GetDummy()

	ent:SetupBones()
	ent:InvalidateBoneCache()
	if spec.Eye then spec:Eye(true) end
	
	SetReplaceViewEntity(spec)
	PlayersBonesBeforeWorld(ent,spec)
	
	local dir = Vector(1,0,0):Rotate(ang)
	
	outdistance = math.max(outdistance - wheel * 5,0)

	if IsSpectate != 1 then return end

	for k,v in pairs(filter) do filter[k] = nil end

	if outdistance == 0 then
		if not watchFace then
			watchFace = true
			
			ply:ChatPrint(L("spectate_wathface"))
		end
		
		local func = ent.Spectate2

		if func then
			return func(ent,ply,view)
		else
			if not spec.Eye then return end

			local pos,ang = spec:Eye()
	
			ent.r_headPop = true

			view.vec = pos
			view.ang = ang

			if not CameraSpectator then
				CameraSpectator = true
				event.Run("PreCalcView",spec,view)
				CameraSpectator = nil
			end

			return view
		end
	else
		if watchFace then
			watchFace = nil
			ply:ChatPrint(L("spectate_wath"))
		end

		local func = ent.Spectate1

		if func then
			return func(ent,ply,view)
		else
			ent:CopyBoneMatrixHash(ent:LookupBone("ValveBiped.Bip01_Head1"),MatrixSet)
	
			if not MatrixSet:IsZero() then
				tr.start = MatrixSet:GetTranslation()
				tr.endpos = tr.start - dir * outdistance
			else
				tr.start = ent:GetPos() + ent:OBBCenter()
				tr.endpos = tr.start - dir * outdistance
			end

			filter[ent] = true
			getVehicle(ent,filter)

			if ent.SpectateFunc then ent:SpectateFunc(view) end

			local result = util.TraceLine(tr)

			view.vec = result.HitPos
			view.ang = ang
		end

		view.vec:Add(closedPlyVec)
		closedPlyVec:LerpFT(0.5)
		
		return view
	end
end,-21)

--

local oldKeyWalk

local oldNext
local oldBack

local function SetSpectate(ply)
	SpecEnt = ply

	if IsSpectate == 2 then
		ViewEntity = ply
	else
		ViewEntity = nil
	end

	if ply then
		if IsValid(ply) then
			RunConsoleCommand("hg_spectate",tostring(ply:EntIndex()))
		end
	else
		ViewEntity = nil
		
		RunConsoleCommand("hg_spectate")
	end
end

IsSpectate = 1

local function getClosedPly(tbl)
	local closedPly

	for i,ply in pairs(tbl) do
		if not closedPly then closedPly = ply continue end

		local dis = EyePos():Distance(ply:GetPos())

		if closedPly:GetPos():Distance(EyePos()) > dis then
			closedPly = ply
		end
	end

	return closedPly
end

hook.Add("Think","Spectate",function()
	local ply = LocalPlayer()
	if ply:Alive() then IsSpectate = 2 SpecEnt = nil return end

	if (InWindowTime or 0) + 0.25 > CurTime() then return end

	local key = ply:KeyDown(IN_RELOAD)

	if hook.Run("Lock R Spectate") == nil then
		if key ~= oldKeyWalk and key then
			if IsSpectate == 1 then
				IsSpectate = 2//свободный полёт
				SetSpectate()
				ply:ChatPrint(L("spectate_fly"))
			else
				IsSpectate = 1//наблюдение за игроком
				outdistance = 75
			end
		end
	end
	
	oldKeyWalk = key

	local tbl = {}

	for i,ply in pairs(player.GetAll()) do
		if not ply:Alive() then continue end

		tbl[#tbl + 1] = ply
	end

	if IsSpectate == 1 then
		if levelActive then
			local func = levelActive.SpectateNext
			if func and func(levelActive,tbl) == false then return end
		end//mdam
		
		if #tbl == 0 then SpecEnt = nil return end

		if not IsValid(SpecEnt) or (SpecEnt.Alive and not SpecEnt:Alive()) then
			local closedPly = getClosedPly(tbl)

			if not closedPly then
				IsSpectate = 2//свободный полёт
				SetSpectate()
				ply:ChatPrint(L("spectate_fly"))
			else
				closedPlyVec = EyePos() - closedPly:EyePos()
				SetSpectate(closedPly)
			end
		end

		local next,back = ply:KeyDown(IN_ATTACK),ply:KeyDown(IN_ATTACK2)

		if oldNext ~= next and next then
			for i,ply in pairs(tbl) do
				if ply == SpecEnt then
					SetSpectate(tbl[(i + 1 > #tbl and 1) or (i + 1)])

					break
				end
			end
		end

		if oldBack ~= back and back then
			for i,ply in pairs(tbl) do
				if ply == SpecEnt then	
					SetSpectate(tbl[(i - 1 < 0 and #tbl) or (i - 1)])

					break
				end
			end
		end

		oldNext = next
		oldBack = back
	end
end)