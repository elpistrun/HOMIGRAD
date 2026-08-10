local footSet = 0,0
CameraFoot = 0

local footSideSet = 0,0
CameraFootSide = 0

local footPos,footPosSet = Vector(),Vector()

local velSet = Vector()
local vel = Vector()
local sideLerp = 0

local limit = 1
CameraLand,CameraLandSet = Vector(),Vector()

local sprint = 0

local pith = 0
local velLenght = 0

event.Add("PreCalcView","Movement",function(ply,view)
    if not ply:Alive() or view.disableMovement or ply:InVehicle() then return end

    local vec = view.vec
    local ang = view.ang

    CameraFoot = LerpFT(0.2,CameraFoot,footSet)
    footSet = LerpFT(0.025,footSet,0)

    CameraFootSide = LerpFT(0.25,CameraFootSide,footSideSet)

    local k = view.multiplyMovement or 1
    
    // Footsteps Shake

    footPos:LerpFT(0.2,footPosSet)
    footPosSet:LerpFT(0.2)

    vec:Add(footPos * k)
    
    ang[1] = ang[1] + 2 * CameraFoot * k
    ang[3] = ang[3] + CameraFoot * CameraFootSide / 1 + math.min(math.cos(RealTime() * 0.075) * 1.5,1) * (view.movementRollMul or 1)

    local diff = (ply:GetVelocity():Angle() - ang)
    diff:Normalize()

    // Side Roll Camera

    local v = CalcSideK(diff[2])
    v = v * math.Clamp(ply:GetVelocity():Length() / 512,0,1) * k
    sideLerp = LerpFT(0.25,sideLerp,v)
    ang[3] = ang[3] - 15 * sideLerp * (view.mulSideLerp or 1)

    // Velocity

    velSet:LerpFT(0.8,ply:GetVelocity():Div(55))
    vel:LerpFT(0.1,velSet)
    vel:NormalizeLengthOfSphere(1)
    vec:Add(vel * k)

    pith = LerpFT(0.5,pith,vel[3])
    ang[1] = ang[1] + pith * 25
    
    vel[3] = 0--fuck you!
    
    // Speed Zoom

    sprint = LerpFT(0.1,sprint,ply:IsOnGround() and ply:IsSprinting() and math.min(ply:GetVelocity():Length() / ply:GetRunSpeed(),1) or 0)
    velLenght = LerpFT(0.25,velLenght,vel:Length() / 300)
    view.fov = view.fov + 5 * sprint + velLenght
    
    // Land

    vec:Add(CameraLand:Clone():NormalizeLengthOfSphere(10):Div(10))

    ang[1] = ang[1] + CameraLand:Length() / 1
    ang[3] = ang[3] + CameraLand:Length() * CameraFootSide / 2

    CameraLand:LerpFT(0.25,CameraLandSet)
    CameraLandSet:LerpFT(0.95)
end,1)

local Rand = math.Rand

event.Add("Footstep","Camera",function(ply,_footSide)
    if ply ~= LocalPlayer() then return end

    footSideSet = _footSide and 1 or 0
    
    local sprint = ply:IsSprinting()

    footPosSet = EyeAngles():Right() * -footSideSet + Vector(0,0,2)
    footPosSet:Mul(sprint and 2 or 1)

    footSet = sprint and 2.5 or 1
end,-1)

event.Add("Landing","Camera",function(ply,inWater,onFloat,speed)
    if ply ~= LocalPlayer() then return end

    CameraLandSet:Add(ply:GetVelocity():Div(12))
end,-1)