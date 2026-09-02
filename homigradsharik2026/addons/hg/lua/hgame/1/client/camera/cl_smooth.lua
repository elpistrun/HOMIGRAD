local forwardPos = Vector()
local forwardPos2 = Vector()

local oldAng = Angle()

local imersiveAng = Angle()
local imersiveAngSet = Angle()

local hg_camera_smooth = true// CreateClientConVar("hg_camera_smooth","1",)

function BounceLerp(t,t2,to,from,vel,tt)
    local ft = math.Clamp(FrameTime(),0,0.25) * tt
    local apply = (from - to):Mul(t)

    vel:Add(apply)
    to:Add(vel * ft)
    vel:Sub(apply * t2)
end

event.Add("PreCalcView","Smooth",function(ply,view)
    view.imersiveSetL = 0.95
    view.imersiveL = 0.9
    
    view.forwardL = 0.9
    view.forwardSubL = 0.2

    view.forwardMul = 1
    view.forwardSubMul = 3
end,-4)

event.Add("PreCalcView","Smooth",function(ply,view)
    if not ply:Alive() or (ply:GetMoveType() == MOVETYPE_NOCLIP and not IsValid(AttachmentMenuWeapon)) then return end
    
    local angStart = view.ang:Clone()
    local diff = angStart:Forward() - oldAng:Forward()

    view.forwardDiff = diff * (view.smoothMultiply or 1)

	forwardPos:Add(diff):LerpFT(view.forwardL / (view.smoothMultiply or 1))
    forwardPos2:Add(diff):LerpFT(view.forwardSubL / (view.smoothMultiply or 1))

    local vec = view.vec
    vec:Add(forwardPos * view.forwardMul * 0.1)
    vec:Sub(forwardPos2 * view.forwardSubMul * 0.1)

    view.fov = view.fov + forwardPos:Length()
    local ang = view.ang

    ang[3] = ang[3] + forwardPos2:Dot(ang:Right()) * 4

    local diff = angStart - oldAng
    diff:Normalize()

    view.angDiff = diff

    imersiveAngSet:Add(diff)
    local len = imersiveAngSet:Length()

    imersiveAngSet:LerpFT(view.imersiveSetL * math.max((len - 8),1) * (LocalPlayer():IsSprinting() and 5 or 1))
    imersiveAng:LerpFT(view.imersiveL,imersiveAngSet)

    imersiveAng:Mul(0.1)
    
    ang:Sub(imersiveAng)

    oldAng = angStart
end,2)