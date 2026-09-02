local ANGLE = FindMetaTable("Angle")

function ANGLE:Clone() return Angle(self[1],self[2],self[3]) end

function ANGLE:Add(vec)
	self[1] = self[1] + vec[1]
	self[2] = self[2] + vec[2]
	self[3] = self[3] + vec[3]

	return self
end

function ANGLE:Sub(vec)
	self[1] = self[1] - vec[1]
	self[2] = self[2] - vec[2]
	self[3] = self[3] - vec[3]

	return self
end

function ANGLE:Div(value)
	self[1] = self[1] / value
	self[2] = self[2] / value
	self[3] = self[3] / value

	return self
end

function ANGLE:Mul(value)
	self[1] = self[1] * value
	self[2] = self[2] * value
	self[3] = self[3] * value

	return self
end

function ANGLE:Set(value)
	self[1] = value[1]
	self[2] = value[2]
	self[3] = value[3]

	return self
end

function ANGLE:SetRoll(value) self[3] = value return self end//for vr

local abs = math.abs

function ANGLE:Length()
	return (abs(self[1]) + abs(self[2]) + abs(self[3])) / 3
end

local ang_zero = Angle()

local Lerp = Lerp
local LerpFT = LerpFT
local LerpFrameTime = LerpFrameTime

local AngleDifference = math.AngleDifference

function ANGLE:Lerp(lerp,to)
	to = to or angle_zero

    self[1] = self[1] + AngleDifference(to[1],self[1]) * lerp
    self[2] = self[2] + AngleDifference(to[2],self[2]) * lerp
    self[3] = self[3] + AngleDifference(to[3],self[3]) * lerp

	return self
end

local min = math.min

function ANGLE:LerpFT(lerp,to)
	to = to or angle_zero

	lerp = min(lerp * GetFT(),1)

    self[1] = self[1] + AngleDifference(to[1],self[1]) * lerp
    self[2] = self[2] + AngleDifference(to[2],self[2]) * lerp
    self[3] = self[3] + AngleDifference(to[3],self[3]) * lerp

	return self
end

function ANGLE:LerpFrameTime(lerp,to,mul)
	to = to or angle_zero

	lerp = min(lerp * mul,1)

    self[1] = self[1] + AngleDifference(to[1],self[1]) * lerp
    self[2] = self[2] + AngleDifference(to[2],self[2]) * lerp
    self[3] = self[3] + AngleDifference(to[3],self[3]) * lerp

	return self
end

HRotateAroundAxis = HRotateAroundAxis or ANGLE.RotateAroundAxis
local HRotateAroundAxis = HRotateAroundAxis

function ANGLE:RotateAroundAxis(axis,rot)
	HRotateAroundAxis(self,axis,rot)

	return self
end

local vec_zero = Vector()
local LocalToWorld = LocalToWorld

function ANGLE:Rotate(ang)
	local pos,ang = LocalToWorld(vec_zero,ang,vec_zero,self)

	self[1] = ang[1]
	self[2] = ang[2]
	self[3] = ang[3]

	--[[self:RotateAroundAxis(self:Up(),ang[1])
	self:RotateAroundAxis(self:Right(),ang[2])
	self:RotateAroundAxis(self:Forward(),ang[3])]]--

	return self
end

HAngleNormalize = HAngleNormalize or ANGLE.Normalize
local HAngleNormalize = HAngleNormalize

function ANGLE:Normalize()
	HAngleNormalize(self)

	return self
end

function ANGLE:Clamp(b,value)
    self[1] = self[1] - math.Clamp(math.AngleDifference(self[1],b[1]),-value,value)
    self[2] = self[2] - math.Clamp(math.AngleDifference(self[2],b[2]),-value,value)
    self[3] = self[3] - math.Clamp(math.AngleDifference(self[3],b[3]),-value,value)
    
	return self
end

local nan = 0 / 0

function ANGLE:ZeroIfNan()
	if
		self[1] != self[1] or self[2] != self[2] or self[3] != self[3]--если nan то nan != nan
	then
		self[1] = 0
		self[2] = 0
		self[3] = 0
	end
end

local inf = 0 / 0
local abs = math.abs

function ANGLE:NonCrazy()
	if self[1] == inf then self[1] = 0 end
	if self[2] == inf then self[2] = 0 end
	if self[3] == inf then self[3] = 0 end

	self:Normalize()
end