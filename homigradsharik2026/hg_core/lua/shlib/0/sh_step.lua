local mul = 1
local FrameTime,TickInterval = engine.AbsoluteFrameTime,engine.TickInterval

TickInterval = TickInterval()

local CurTime = CurTime
local delay1,delay025,delay01 = 0,0,0
local Run = event.Call

if SERVER then
	util.AddNetworkString("server_performance")
else
	ServerPerformance = {}
	
	net.Receive("server_performance",function()
		ServerPerformance[1] = net.ReadString()
		ServerPerformance[2] = net.ReadString()
	end)
end

hook.Add("Think","!",function()
	GarbageLock("think")

	mul = FrameTime() / TickInterval

	local time = CurTime()
	
	Run("Think")

	if delay1 <= time then
		delay1 = time + 1
		
		Run("Think 1",time,mul)
	end

	if delay025 <= time then
		delay025 = time + 0.25

		Run("Think 0.25",time,mul)
	end

	if delay01 <= time then
		delay01 = time + 0.1

		Run("Think 0.1",time,mul)
	end

	GarbageFree("think")

	if SERVER then
		net.Start("server_performance",true)
		net.WriteString(FrameTime())
		net.WriteString(physenv.GetLastSimulationTime())
		net.Broadcast()
	end
end,-2)--mdam

function GetFT() return mul end

local Lerp,LerpVector,LerpAngle = Lerp,LerpVector,LerpAngle
local math_min = math.min

function LerpFT(lerp,source,set)
	return Lerp(math_min(lerp * mul,1),source,set)
end

function LerpVectorFT(lerp,source,set)
	return LerpVector(math_min(lerp * mul,1),source,set)
end

function LerpAngleFT(lerp,source,set)
	return LerpAngle(math_min(lerp * mul,1),source,set)
end

function LerpFrameTime(lerp,source,set,mul)
	return Lerp(math_min(lerp * (mul / (1 / 60)),1),source,set)
end

function LerpVectorFrameTime(lerp,source,set,mul)
	return LerpVector(math_min(lerp * (mul / (1 / 60)),1),source,set)
end

function LerpAngleFrameTime(lerp,source,set,mul)
	return LerpAngle(math_min(lerp * (mul / (1 / 60)),1),source,set)
end

local abs = math.abs

function LerpFTLess(lerp,source,set,less)
	local v = LerpFT(lerp,source,set)
	
	if abs(set - source) <= (less or 1) then v = set end
	
	return v
end

function LerpFrameTimeLess(lerp,source,set,less,mul)
	local v = LerpFrameTime(lerp,source,set,mul)
	
	if abs(set - source) <= (less or 1) then v = set end
	
	return v
end

function LerpLess(lerp,source,set,less)
	local v = Lerp(lerp,source,set)
	
	if abs(set - source) <= (less or 1) then v = set end
	
	return v
end
