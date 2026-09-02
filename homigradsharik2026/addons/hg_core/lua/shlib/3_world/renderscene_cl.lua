RenderView = {
	x = 0,
	y = 0,
	
	drawhud = false,
	drawviewmodel = true,
	dopostprocess = true,
	drawmonitors = false,
	bloomtone = true,

	fov = 90,
	drawviewer = true,

	origin = Vector(),
	angles = Angle(),

	viewid = 0
}

function render.ScaleFOVRatio(fovDegrees,ratio)
    local halfAngleRadians = math.rad(fovDegrees / 2)
    
    local t = math.tan(halfAngleRadians)
    
    t = t * (ratio / (4 / 3))
    
    local radians = math.atan(t)
    
    return math.deg(radians) * 2
end


local ReplaceRenderIsMeName
function SetReplaceRenderIsMeName(value) ReplaceRenderIsMeName = value end

local render_GetRenderTarget = render.GetRenderTarget

function RenderIsMe()
	local rt = render_GetRenderTarget()
	if not rt then return true end
	
	local rtName = rt:GetName()
	if rtName == ReplaceRenderIsMeName or rtName == "_rt_resolvedfullframedepth" then return true end

	return false
end

function PlayersBonesBeforeWorld(ent,link)
	RENDER_BEFORE_WORLD = true
	PlayerDeterminate(ent,nil,link)
	RENDER_BEFORE_WORLD = nil
end

function PlayerLocalUpdate()
	PlayersBonesBeforeWorld(LocalPlayer():GetDummy(),LocalPlayer())
end

local listPass = {}

function RenderHighPass(ent,min,max)
	if (ent.renderHighPass or 0) < RealTime() then
		ent.renderHighPass = RealTime() + (1 / math.random(min or 18,max or 22))
		ent.renderPass = true

		listPass[#listPass + 1] = ent

		return true
	else
		return ent.renderPass or false
	end
end

local hg_lua_gc_render

cvars.CreateOption("hg_lua_gc_render","1",function(value)
	hg_lua_gc_render = tonumber(value or 0) > 0
end,0,1)

hook.Add("PreRender","!SHLIB",function()
	if hg_lua_gc_render and not GC_STOP then collectgarbage("stop") end

	FRAME_NUMBER = FrameNumber()
	
	for i = 1,#listPass do
		local ent = listPass[i]
		if IsValid(ent) then ent.renderPass = nil end

		listPass[i] = nil
	end

	local result = event.Call("PreRender")

	if hg_lua_gc_render and result == false and not GC_STOP then collectgarbage("restart") end

	return result
end)

local inf = 0 / 0

function DoCalcView(ply,origin,angles,fov)
	local view = CalcView(ply,origin,angles,fov)
	if not view then return end

	local vec = view.vec
	
	if vec[1] == inf then vec[1] = 0 end
	if vec[2] == inf then vec[2] = 0 end
	if vec[3] == inf then vec[3] = 0 end

	local ang = view.ang
	ang:Normalize()
	
	if ang[1] == inf then ang[1] = 0 end
	if ang[2] == inf then ang[2] = 0 end
	if ang[3] == inf then ang[3] = 0 end

	RenderView.fov = view.fov
	RenderView.origin = vec
	RenderView.angles = ang
	RenderView.znear = view.znear or 1
	RenderView.zfar = view.zfar or 2 ^ 32
	RenderView.drawviewer = view.drawviewer
	RenderView.drawviewmodel = view.drawviewmodel
	
	return RenderView
end

local hg_disable_render
cvars.CreateOption("hg_disable_render","0",function(value) hg_disable_render = tonumber(value or 0) > 0 end)

hook.Add("CalcView","!",function(ply,origin,angles,fov)
	if hg_disable_render then return end
	
	RenderView.fov = RenderView.originalFOV

	if GetViewEntity() != ply then
		RenderView.origin = origin
		RenderView.angles = angles
	end

	return RenderView
end)

local view = {}

CalcView = function(ply,origin,angles,fov,znear,zfar)
	view.origin = origin
	view.angles = angles
	view.fov = fov
	view.znear = znear
	view.zfar = zfar
	view.drawviewer = true

	view.vec = view.origin:Clone()
	view.ang = view.angles:Clone()

	local result = event.Call("PreCalcView",ply,view,oldView or view)
	
	if result ~= nil then
		if result == false then return false end
		
		if TypeID(result) == TYPE_TABLE then
			oldView = table.Copy(result)
		end

		return result
	end

	oldView = table.Copy(view)

	return view
end

function CamReset(znear,zfar)--WTF
	cam.Start3D(RenderView.origin,RenderView.angles,nil,0,0,ScrW(),ScrH(),znear,zfar)
end

event.Add("PreCalcView","CalcView Weapon",function(ply,view)
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) or not wep.CalcView then return end
	
	local pos,ang,fov = wep:CalcView(ply,view.origin,view.angles,view.fov)

	if pos then view.pos = pos end
	if ang then view.angles = ang end
	if fov then view.fov = fov end
end,-24)

local chacheFirstFrame = {}

local hg_dev_fov = 0

cvars.CreateDevOption("hg_dev_fov","0",function(value)
	hg_dev_fov = tonumber(value or 0)
end,0,120)

hook.Add("AdjustMouseSensitivity","hg_dev_fov",function()
	if hg_dev_fov == 0 then return end

	return hg_dev_fov / 90
end)

local hg_stop_render
cvars.CreateOption("hg_stop_render","0",function(value) hg_stop_render = tonumber(value or 0) > 0 end)

if not HGetViewEntity then HGetViewEntity = GetViewEntity end

local ReplaceViewEntity
function SetReplaceViewEntity(value) ReplaceViewEntity = value end

local abs = math.abs

local RenderScene = function(origin,angles,fov)
	if hg_stop_render then return true end
	
	SetReplaceViewEntity()
	ClearRenderFrame()

	local lply = LocalPlayer()
	
	if hg_disable_render then
		lply:SetFOV(90)

		return
	end

	CurretRenderViewEntity = HGetViewEntity(lply)

	local result = event.Call("RenderScene",origin,angles,fov)
	if result ~= nil then return result end

	RenderView.w = ScrW()
	RenderView.h = ScrH()

	RenderView.aspectratio = ScrW() / ScrH()

	RenderView.origin = origin
	RenderView.angles = angles
	RenderView.fov = fov
	
	if GetViewEntity() == lply then
		lply:GetDummy():SetupBones()
		
		origin,angles = lply:Eye(true)

		RenderView.origin = origin
		RenderView.angles = angles
	end

	if lply:Alive() then
		PlayerLocalUpdate()
	end

	DoCalcView(lply,origin,angles,fov)

	if event.Call("PreRenderScene") == false then return true end
	if hg_dev_fov != 0 then RenderView.fov = hg_dev_fov end

	RenderView.origin:NonCrazy()
	RenderView.angles:NonCrazy()

	RenderView.fov = math.Clamp(RenderView.fov,0,180)
	
	RenderView.originalFOV = RenderView.fov
	RenderView.fov = render.ScaleFOVRatio(RenderView.fov,RenderView.aspectratio)

	render.RenderView(RenderView)
	render.RenderHUD(0,0,RenderView.w,RenderView.h)

	return true
end

hook.Add("RenderScene","ZWorld",function(origin,angles,fov)
	local result = RenderScene(origin,angles,fov)
	if hg_lua_gc_render and not GC_STOP then collectgarbage("restart") end

	return result
end)

function GetViewEntity()
	return ReplaceViewEntity or CurretRenderViewEntity
end
