local SWEP = oop.Get("wep_lib_camera")
if not SWEP then return end

function SWEP:InitCameraModel(wm)
    return self:InitWorldModel("CameraModel","nodraw")
end

local tpikMatrix = {}

function SWEP:GetCameraWM(ply)
    local wm = self.wm
    if not IsValid(wm) then return end--WTTTFFF

    local cameraWM,isCreate = self:InitCameraModel(wm)
    if not IsValid(cameraWM) then return end
    self.cameraWM = cameraWM
    
    local oldPos,oldAng = wm:GetPos(),wm:GetAngles()

    tpikMatrix.ent = ply:GetDummy()
    tpikMatrix.link = ply
    tpikMatrix.wm = wm
    tpikMatrix.deltaTime = FrameTime()
    
    tpikMatrix.leftDown = 120
    tpikMatrix.rightDown = 120

    RenderCamera = true
    self:SetupBones_WorldModel_ByTPIK(tpikMatrix)
    RenderCamera = nil
    
    local wmCameraPos,wmCameraAng = wm:GetPos(),wm:GetAngles()
    
    wm:SetPos(oldPos)
    wm:SetAngles(oldAng)
    
    cameraWM:SetNoDraw(true)
    cameraWM:SetPos(wmCameraPos)
    cameraWM:SetAngles(wmCameraAng)
    
    cameraWM:SetSequence(0)
    cameraWM:SetCycle(0)
    
    self:SetupModel(cameraWM)
    if not hg_tpik_lerp then self:SetupModel(wm) end
    
    return cameraWM
end

SWEP.CameraMovementMul = 1
SWEP.ImmersiveCameraMul = 0

ScopeLerp = ScopeLerp or 0
ScopeOpticLerp = ScopeOpticLerp or 0
OldScopeLerp = ScopeLerp or 0

local lastEyeAng = Angle()
local immersiveAngSet,immersiveAng = Angle(),Angle()

function SWEP:CalcViewScope(ply,view,cameraPos,cameraAng,setFOV)
    ScopeLerp = self.scopeLerp
    if not ScopeLerp then return end---wtf
    
    view.fov = Lerp(math.ease.InExpo(ScopeLerp),view.fov,setFOV or 100)
    
    local diff = math.abs(OldScopeLerp - ScopeLerp)
    OldScopeLerp = ScopeLerp

    local wm = self.wm

    if IsValid(wm) and wm.immersiveMoveSet then
        if diff > 0 then
            diff = math.min(diff * 5,1)

            wm.immersiveVelocity:Add(VectorRand():Mul(3 * diff))
        end
    end

    view.vec:Lerp(ScopeLerp,cameraPos)
    view.ang:Lerp(ScopeLerp,cameraAng)

    CameraLandSet:LerpFT(ScopeLerp,Vector())
    CameraLand:LerpFT(ScopeLerp,Vector())

    local CImersiveSetL = self.CImersiveSetL

    if CImersiveSetL then
        CImersiveSetL = Lerp(ScopeLerp,CImersiveSetL,self.CImersiveSetL_Scope or CImersiveSetL)

        view.imersiveSetL = Lerp(1,view.imersiveSetL,CImersiveSetL)
    end

    local CImersiveL = self.CImersiveL
    if CImersiveL then view.imersiveL = Lerp(ScopeLerp,CImersiveL,self.CImersiveL_Scope or CImersiveL) end

    view.multiplyMovement = 1 - ScopeLerp * (self.CameraMovementMul)

    local eyeAng = RenderView.angles
    local diffAng = lastEyeAng - eyeAng
    lastEyeAng = eyeAng

    immersiveAngSet:Add(diffAng)
    immersiveAngSet:LerpFT(Lerp(immersiveAngSet:Length() / 12,0,0.4))
    immersiveAng:LerpFT(0.3,immersiveAngSet)

    view.ang:Add(immersiveAng * ScopeLerp * (1 - ScopeOpticLerp) * self.ImmersiveCameraMul)
end

local ang_zero = Angle()

SWEP.cameraAnimAng = Angle()

function SWEP:CalcViewAnimatedBone(ply,view,bone_name,mul,mulRoll,max)
    bone_name = bone_name or "camera_animated"

    local cameraWM = self:GetCameraWM(ply)
    if not IsValid(cameraWM) then return end

    local wm = self.wm

    local animWM = CSM.GetByID(wm:GetModel(),"CameraMDLAnimate")
    if not animWM then return end--maybe watafaaa

    animWM:SetNoDraw(true)

    local bone_camera = animWM:LookupBone(bone_name)
    if not bone_camera then return end

    animWM:SetPos(cameraWM:GetPos())
    animWM:SetAngles(cameraWM:GetAngles())
    
    animWM:SetSequence(wm:GetSequence())
    animWM:SetCycle(wm:GetCycle())
    animWM:UseClientSideAnimation()
    animWM:SetupBones()
    
    local mat = animWM:GetBoneMatrix(bone_camera)
    if not mat then return end

    local cameraAng = mat:GetAngles()
    cameraAng:RotateAroundAxis(cameraAng:Up(),-90)
    cameraAng:Normalize()
    
    local ang = (view.ang - cameraAng)
    ang:Normalize()

    ang:Mul(mul or 1)
    ang[3] = ang[3] * (mulRoll or 1)

    ang:Normalize()

    local animAng = self.cameraAnimAng
    animAng:LerpFT(0.33,ang)
    animAng:Normalize()

    view.ang:Add(animAng * math.min(self:GetStandAnimK() * (self.stateHolding == "deploy" and 8 or 1),1))
    view.ang[1] = math.Clamp(view.ang[1],-90,90)
end

SWEP:Event_Add("Off","CameraAnimated",function(self)

end)

event.Add("Think","Camera Local Player Unvisible",function()
    --[[local ent = LocalPlayer():GetDummy()
    
    if ScopeLerp > 0.1 then
        ent.r_onlyHands = true
    else
        ent.r_onlyHands = nil
    end]]--
end)