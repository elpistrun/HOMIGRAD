local SWEP = oop.Get("hg_wep")
if not SWEP then return end

SWEP.CameraPos = Vector(-30,0,0)

SWEP.RecoilCameraMul = 0.157
SWEP.RecoilCameraMulScope = 0.15

local hg_scope_sensivity_mul

cvars.CreateOption("hg_scope_sensivity_mul","1",function(value)
    hg_scope_sensivity_mul = tonumber(value or 1) or 1
end,0.001,2)

SWEP.ScopeSensitivity = 0.3

SWEP.CameraMovementMul = 0.98

SWEP.CameraRecoil = 0
SWEP.CameraRecoil_Scope = 0
SWEP.CameraLinies = {}

SWEP:AttUpdate("Camera",function(self,class)
    self.CameraPos = class.CameraPos
    self.CameraAttachment = nil
    
    self.CameraRecoil = class.CameraRecoil
    self.CameraRecoil_Scope = class.CameraRecoil_Scope
    self.CImersiveSetL = class.CImersiveSetL
    self.RecoilCameraMulScope = class.RecoilCameraMulScope
end,function() end)

SWEP:Event_Add("Attachment Update","Camera World Model",function(self)
    if not IsValid(self.wm) then return end

    CSM.Delete(self:InitCameraModel(self.wm))
    self:InitCameraModel(self.wm)
end,100)

SWEP.CameraPosLocal = Vector()

SWEP.CameraRoll = 3
local cameraRollLerp = 0

local matMuzzle = Matrix()
local matCamera = Matrix()

local fovLerp = 90

local empty = {}

ScopeOpticLerp = ScopeOpticLerp or 0
CameraAnimatedLerp = CameraAnimatedLerp or 0

SWEP:Event_Add("Init","cameraLine",function(self)
    self.cameraLine = 1
end)

local empty = {}

local oldScope = false

function SWEP:PreCalcView(ply,view)
    local wm = self:GetWorldModel()
    if not IsValid(wm) then return end

    local cameraWM = self:GetCameraWM(ply)
    if not IsValid(cameraWM) then return end

    local cameraLine = self.CameraLinies[self.cameraLine]
    cameraLine = cameraLine and cameraLine[1] or empty
    
    local attConfig = empty

    if cameraLine.AttachmentPath then
        attConfig = attachmentGame.config[self.attachments[cameraLine.AttachmentPath][2][1]]

        attConfig = self:GetAttachmentScopeConfig(attConfig,self.cameraOption)
        cameraPos = attConfig.CameraPos or cameraPos
    end

    --

    local cameraPos = self.CameraPos:Clone()

    local muzzlePos,muzzleAng = self:GetShootMatrix(cameraWM,true)
    local cameraAng = muzzleAng

    cameraPos = muzzlePos + cameraPos:Clone():Rotate(muzzleAng)
    local startCameraPos = cameraPos:Clone()

    if cameraLine.AttachmentPath then
        local mdl = cameraWM.attachments[cameraLine.AttachmentPath]
        if not IsValid(mdl) then return end

        local ang = mdl:GetAngles()
  
        cameraPos = mdl:GetPos() + Vector(-(attConfig.BackCamera or 0),attConfig.ScopeRight,attConfig.ScopeHeight):Rotate(ang)
        cameraAng = ang
    end

    if not attConfig.CameraAnchorPosition then
        local mdl = cameraWM.attachments[cameraLine.AttachmentPath]
        
        if IsValid(mdl) then
            cameraPos = ProjectPointToPlane(cameraPos,startCameraPos,Vector(1,0,0):Rotate(muzzleAng))
        end

        ScopeOpticLerp = LerpFT(0.5,ScopeOpticLerp,0)
    else
        ScopeOpticLerp = LerpFT(0.5,ScopeOpticLerp,1)
    end

    --

    matMuzzle:SetTranslation(muzzlePos)
    matMuzzle:SetAngles(muzzleAng)

    matCamera:SetTranslation(cameraPos)
    matCamera:SetAngles(cameraAng)

    matMuzzle:Invert()
    matMuzzle:Mul(matCamera)

    self.CameraPosLocal:Lerp(0.1,matMuzzle:GetTranslation())

    fovLerp = LerpFT(0.25,fovLerp,attConfig.FOV or 100)

    self:CalcViewScope(ply,view,muzzlePos + self.CameraPosLocal:Clone():Rotate(muzzleAng),cameraAng,fovLerp)

    CameraAnimatedLerp = LerpFT(0.1,CameraAnimatedLerp,self.sequenceObject and not self.sequenceObject.fire and 1 or 0)
    local mul = CameraAnimatedLerp * 1 * (1 - self.a_fSprintLerp)
    if IsValid(AttachmentMenuWeapon) then mul = mul * (1 - AttachmentMenuWeapon:GetK()) end
    
    self:CalcViewAnimatedBone(ply,view,"camera_animated",mul,1.2)

    if (attConfig.ScopeZoom or 0) <= 0 then
        cameraRollLerp = LerpFT(0.5,cameraRollLerp,(attConfig.CameraRoll or self.CameraRoll) * ScopeLerp)
        view.ang[3] = view.ang[3] + cameraRollLerp
    end

    --

    local recoil,recoilRandAbs = self.recoil,self.recoilRandAbs

    if recoil > 0.00001 then
        view.vec:Add(Vector(Lerp(ScopeLerp,attConfig.CameraRecoil or self.CameraRecoil,attConfig.CameraRecoil_Scope or self.CameraRecoil_Scope or self.CameraRecoil),0,0):Rotate(view.ang):Mul(recoil))

        local mul = Lerp(ScopeLerp,attConfig.RecoilCameraMul or self.RecoilCameraMul,attConfig.RecoilCameraMulScope or self.RecoilCameraMulScope)

        view.vec:Add(VectorRand():Mul(recoil * mul * (1 - ScopeLerp * 0.9)))
        view.fov = view.fov + recoil * 0.5

        local mul = 0.3 * (1 - ScopeLerp * 0.6)

        view.ang[1] = view.ang[1] + recoil * math.randAbs() * mul
        view.ang[2] = view.ang[2] + recoil * math.randAbs() * mul
    end

    /*
    local mdl = cameraWM.attachments[cameraLine.AttachmentPath]
    view.ang[2] = view.ang[2] + 90
    view.vec = mdl:GetPos() - Vector(10,0,0):Rotate(view.ang)
    local diffPos,diffAng,startPos,endPos = self:GetDiffMatrixScope(mdl,self.attachmentsClassIndex[self.attachments[cameraLine.AttachmentPath][2][1]])
    debugoverlay.BoxAngles(startPos,-Vector(0.1,0.1,0.1),Vector(0.1,0.1,0.1),Angle(),0.1,Color(255,0,0))
    debugoverlay.BoxAngles(endPos,-Vector(0.1,0.1,0.1),Vector(0.1,0.1,0.1),Angle(),0.1,Color(0,0,255))*/

    local scope = self:IsScope()

    if oldScope != scope then
        oldScope = scope

        local ScopeSounds = self.ScopeSounds

        if ScopeSounds then
            local volume = ScopeSounds.volume or 0.3

            if scope then
                sound.Emit(self,ScopeSounds.listIn[math.random(1,#ScopeSounds.listIn)],75,volume,100)
            else
                sound.Emit(self,ScopeSounds.listOut[math.random(1,#ScopeSounds.listOut)],75,volume,100)
            end
        end
    end

    self:CalcViewAnimation(ply,view)

    return self:CalcViewAttachmentMenu(ply,view)
end

SWEP:Event_Add("Off","ScopeLerp",function(self)
    if not self:IsLocal() then return end
    
    ScopeLerp = 0
    ScopeOpticLerp = 0
    CameraAnimatedLerp = 0
end)

function SWEP:AdjustMouseSensitivity()
    return Lerp(ScopeLerp,1,self.ScopeSensitivity * hg_scope_sensivity_mul)
end