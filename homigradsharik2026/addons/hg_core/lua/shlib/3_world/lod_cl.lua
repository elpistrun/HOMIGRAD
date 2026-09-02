function CanRender(eyePos,pos,distanceCone,fov,dir)
	return true--util.IsPointInCone(pos,eyePos,dir,fov,distanceCone)
end

function SetDeterminateLODAlways(self)
	self.DeterminateLODAlways = RealTime() + 0.1
end

function IsDeterminateLODAlways(self)
	if self.DeterminateLODAlways then
		if self.DeterminateLODAlways > RealTime() then return true end

		self.DeterminateLODAlways = nil
	end

	return false
end

cvars.CreateOption("hg_lod0","300",function(value) RenderLOD0_Distance = tonumber(value or 300) or 300 end)
cvars.CreateOption("hg_lod1","600",function(value) RenderLOD1_Distance = tonumber(value or 600) or 600 end)
cvars.CreateOption("hg_lod2","1200",function(value) RenderLOD2_Distance = tonumber(value or 1200) or 1200 end)
cvars.CreateOption("hg_lod2_5","2000",function(value) RenderLOD2_5_Distance = tonumber(value or 2000) or 2000 end)
cvars.CreateOption("hg_lod3","4000",function(value) RenderLOD3_Distance = tonumber(value or 4000) or 4000 end)
cvars.CreateOption("hg_lod4","7000",function(value) RenderLOD4_Distance = tonumber(value or 7000) or 7000 end)

local dir = Vector()
local vec_zero = Vector()

function GetRenderLOD(pos)
	local addDis = 8000 * math.ease.InExpo(1 - (DEVCAMERAFOV or RenderView.fov) / 90)
	local eyePos = RenderView.origin

	dir:Set(vec_zero)
	dir:Rotate(RenderView.angles)
	
	if eyePos:Distance(pos) <= RenderLOD0_Distance then--lod0 рисуем пальцы
		return
			true,
			true,
			true,
			true,
			true,
			true
	elseif CanRender(eyePos,pos,RenderLOD1_Distance,0.5,dir) then--lod1 рисуем все детали
		return
			false,
			true,
			true,
			true,
			true,
			true
	elseif CanRender(eyePos,pos,RenderLOD2_Distance + addDis,0.6,dir) then
		return
			false,
			false,
			true,
			true,
			true,
			true
	elseif CanRender(eyePos,pos,RenderLOD2_5_Distance + addDis,0.6,dir) then--lod2 рисуем средние, крупные детали
		return
			false,
			false,
			false,
			true,
			true,
			true
	elseif CanRender(eyePos,pos,RenderLOD3_Distance + addDis,0.6,dir) then--lod3 рисуем только силует, где-то может 6x12 пикселей
		return
			false,
			false,
			false,
			false,
			true,
			true
	elseif CanRender(eyePos,pos,RenderLOD4_Distance + addDis,0.6,dir) then--lod4 здесь уже остаётся пару пикселей
		return
			false,
			false,
			false,
			false,
			false,
			true
	else
		return
			false,
			false,
			false,
			false,
			false,
			false
	end
end

function DeterminateLODFirst(ent)
	if IsFirstFrame(ent,"r_fDeterminateLOD") then DeterminateLOD(ent) end
end

fakeObject:Event_Add("Create","LOD",function(fake)
	SetAllLOD(fake)
end)

cvars.CreateOption("hg_renderlod_force","-1",function(value)
	value = tonumber(value or -1) or -1

	function DeterminateLOD(ent)
		if DeterminateLODAlways or (ent == GetViewEntity() or ent == LocalPlayer()) then
			ent.renderLOD0 = true
			ent.renderLOD1 = true
			ent.renderLOD2 = true
			ent.renderLOD2_5 = true
			ent.renderLOD3 = true
			ent.renderLOD4 = true
		else
			local lod0,lod1,lod2,lod2_5,lod3,lod4 = GetRenderLOD(ent:GetPos())
			ent.renderLOD0 = lod0--максимальная детализация
			ent.renderLOD1 = lod1--пальцев нет, но всеравно оставляем оптику например
			ent.renderLOD2 = lod2--убираем детали, средняя детализация
			ent.renderLOD2_5 = lod2_5
			ent.renderLOD3 = lod3--оставляем силует игрока (важные положение костей!)
			ent.renderLOD4 = lod4--скорее всего здесь уже он превращён в пиксели, и собого смысла в силуете нет
		end
	end

	function SetAllLOD(ent)
		ent.renderLOD0 = true
		ent.renderLOD1 = true
		ent.renderLOD2 = true
		ent.renderLOD2_5 = true
		ent.renderLOD3 = true
		ent.renderLOD4 = true
	end

	if value == 0 then
		RenderLOD0_Distance = 32000
		RenderLOD1_Distance = 32000
		RenderLOD2_Distance = 32000
		RenderLOD2_5_Distance = 32000
		RenderLOD3_Distance = 32000
		RenderLOD4_Distance = 32000

		function DeterminateLOD(ent)
			ent.renderLOD0 = true
			ent.renderLOD1 = true
			ent.renderLOD2 = true
			ent.renderLOD2_5 = true
			ent.renderLOD3 = true
			ent.renderLOD4 = true
		end
	elseif value == 1 then
		RenderLOD0_Distance = 0
		RenderLOD1_Distance = 32000
		RenderLOD2_Distance = 32000
		RenderLOD2_5_Distance = 32000
		RenderLOD3_Distance = 32000
		RenderLOD4_Distance = 32000

		function DeterminateLOD(ent)
			ent.renderLOD0 = false
			ent.renderLOD1 = true
			ent.renderLOD2 = true
			ent.renderLOD2_5 = true
			ent.renderLOD3 = true
			ent.renderLOD4 = true
		end
	elseif value == 2 then
		function DeterminateLOD(ent)
			RenderLOD0_Distance = 0
			RenderLOD1_Distance = 0
			RenderLOD2_Distance = 32000
			RenderLOD2_5_Distance = 32000
			RenderLOD3_Distance = 32000
			RenderLOD4_Distance = 32000

			ent.renderLOD0 = false
			ent.renderLOD1 = false
			ent.renderLOD2 = true
			ent.renderLOD2_5 = true
			ent.renderLOD3 = true
			ent.renderLOD4 = true
		end
	elseif value == 3 then
		RenderLOD0_Distance = 0
		RenderLOD1_Distance = 0
		RenderLOD2_Distance = 0
		RenderLOD2_5_Distance = 32000
		RenderLOD3_Distance = 32000
		RenderLOD4_Distance = 32000

		function DeterminateLOD(ent)
			ent.renderLOD0 = false
			ent.renderLOD1 = false
			ent.renderLOD2 = false
			ent.renderLOD2_5 = true
			ent.renderLOD3 = true
			ent.renderLOD4 = true
		end
	elseif value == 4 then
		RenderLOD0_Distance = 0
		RenderLOD1_Distance = 0
		RenderLOD2_Distance = 0
		RenderLOD2_5_Distance = 0
		RenderLOD3_Distance = 32000
		RenderLOD4_Distance = 32000

		function DeterminateLOD(ent)
			ent.renderLOD0 = false
			ent.renderLOD1 = false
			ent.renderLOD2 = false
			ent.renderLOD2_5 = false
			ent.renderLOD3 = true
			ent.renderLOD4 = true
		end
	elseif value == 5 then
		RenderLOD0_Distance = 0
		RenderLOD1_Distance = 0
		RenderLOD2_Distance = 0
		RenderLOD2_5_Distance = 0
		RenderLOD3_Distance = 0
		RenderLOD4_Distance = 32000

		function DeterminateLOD(ent)
			ent.renderLOD0 = false
			ent.renderLOD1 = false
			ent.renderLOD2 = false
			ent.renderLOD2_5 = false
			ent.renderLOD3 = false
			ent.renderLOD4 = true
		end
	elseif value == 6 then
		RenderLOD0_Distance = 0
		RenderLOD1_Distance = 0
		RenderLOD2_Distance = 0
		RenderLOD2_5_Distance = 0
		RenderLOD3_Distance = 0
		RenderLOD4_Distance = 0

		function DeterminateLOD(ent)
			ent.renderLOD0 = false
			ent.renderLOD1 = false
			ent.renderLOD2 = false
			ent.renderLOD2_5 = false
			ent.renderLOD3 = false
			ent.renderLOD4 = false
		end
	else
		RenderLOD0_Distance = GetConVar("hg_lod0"):GetFloat()
		RenderLOD1_Distance = GetConVar("hg_lod1"):GetFloat()
		RenderLOD2_Distance = GetConVar("hg_lod2"):GetFloat()
		RenderLOD2_5_Distance = GetConVar("hg_lod2_5"):GetFloat()
		RenderLOD3_Distance = GetConVar("hg_lod3"):GetFloat()
		RenderLOD4_Distance = GetConVar("hg_lod4"):GetFloat()
	end
end)