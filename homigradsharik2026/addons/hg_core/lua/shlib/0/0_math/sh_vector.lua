local VECTOR = FindMetaTable("Vector")

function VECTOR:AddRotate(pos,ang)
	pos:Rotate(ang)
	
	self:Add(pos)

	return self
end

HVectorRotate = HVectorRotate or VECTOR.Rotate
local HVectorRotate = HVectorRotate

function VECTOR:Rotate(ang)
	HVectorRotate(self,ang)

	return self
end

function VECTOR:Clone() return Vector(self[1],self[2],self[3]) end

function VECTOR:Add(vec)
	self[1] = self[1] + vec[1]
	self[2] = self[2] + vec[2]
	self[3] = self[3] + vec[3]

	return self
end

function VECTOR:Sub(vec)
	self[1] = self[1] - vec[1]
	self[2] = self[2] - vec[2]
	self[3] = self[3] - vec[3]

	return self
end

function VECTOR:Div(value)
	self[1] = self[1] / value
	self[2] = self[2] / value
	self[3] = self[3] / value

	return self
end

function VECTOR:Mul(value)
	self[1] = self[1] * value
	self[2] = self[2] * value
	self[3] = self[3] * value

	return self
end

function VECTOR:Set(value)
	self[1] = value[1]
	self[2] = value[2]
	self[3] = value[3]

	return self
end

local vecZero = Vector()

local Lerp = Lerp
local LerpFT = LerpFT
local LerpFrameTime = LerpFrameTime

function VECTOR:Lerp(value,to)
	to = to or vecZero

	self[1] = Lerp(value,self[1],to[1])
	self[2] = Lerp(value,self[2],to[2])
	self[3] = Lerp(value,self[3],to[3])

	return self
end

function VECTOR:LerpFT(value,to)
	to = to or vecZero

	self[1] = LerpFT(value,self[1],to[1])
	self[2] = LerpFT(value,self[2],to[2])
	self[3] = LerpFT(value,self[3],to[3])

	return self
end

function VECTOR:LerpFrameTime(value,to,mul)
	to = to or vecZero

	self[1] = LerpFrameTime(value,self[1],to[1],mul)
	self[2] = LerpFrameTime(value,self[2],to[2],mul)
	self[3] = LerpFrameTime(value,self[3],to[3],mul)

	return self
end

local Clamp = math.Clamp

function VECTOR:Clamp(min,max)
	self[1] = Clamp(self[1],min[1],max[2])
	self[2] = Clamp(self[2],min[2],max[2])
	self[3] = Clamp(self[3],min[3],max[3])

	return self
end

function VECTOR:ClampLocal(min,max,origin)
	self[1] = Clamp(self[1],origin[1] + min[1],origin[1] + max[2])
	self[2] = Clamp(self[2],origin[2] + min[2],origin[2] + max[2])
	self[3] = Clamp(self[3],origin[3] + min[3],origin[3] + max[3])

	return self
end

local min = math.min
local vector_zero = Vector()

function VECTOR:NormalizeLengthOfSphere(maxLen,origin)
	origin = origin or vector_zero

	local dir = self - origin
	local len = dir:Length()

	dir:Normalize()

	self:Set(origin + dir:Mul(min(len,maxLen)))

	return self
end


HVectorNormalize = HVectorNormalize or VECTOR.Normalize
local HVectorNormalize = HVectorNormalize

function VECTOR:Normalize()
	HVectorNormalize(self)

	return self
end

local nan = 0 / 0

function VECTOR:ZeroIfNan()
	if
		self[1] != self[1] or self[2] != self[2] or self[3] != self[3]--если nan то nan != nan
	then
		self[1] = 0
		self[2] = 0
		self[3] = 0
	end
end

function RotateAroundPoint_LocalCenter(worldPos, worldAng, centerLocalOffset, rotateAng)--тупая машина, сам за 5 минут сделал
	return
		worldPos - (worldPos + centerLocalOffset:Clone():Rotate(worldAng)):Sub(worldPos + centerLocalOffset:Clone():Rotate(worldAng - rotateAng)),
		(worldAng + rotateAng):Normalize()
end

function ProjectPointToPlane(point, planeOrigin, planeNormal)
    planeNormal = planeNormal:GetNormalized()
    local v = point - planeOrigin
    local dist = v:Dot(planeNormal)
    return point - planeNormal * dist
end

local inf = 0 / 0
local abs = math.abs

function VECTOR:NonCrazy()
	if self[1] == inf or abs(self[1]) >= 32000 then self[1] = 0 end
	if self[2] == inf or abs(self[2]) >= 32000 then self[2] = 0 end
	if self[3] == inf or abs(self[3]) >= 32000 then self[3] = 0 end
end