local SWEP = oop.Reg("tpik_animate",{"hg_wep_base","base_anim"},true)
if not SWEP then return INCLUDE_BREAK end

SWEP:Event_Add("Think","AnimationThink",function(self) self:AnimationThink() end,1)
SWEP:Event_Add("ThinkOutside","AnimationThink",function(self) self:AnimationThink() end,1)

SWEP:Event_Add("StopAction","ResetAnimation",function(self) self:ResetAnimation() end)

--

local vec_zero,ang_zero = Vector(),Angle()
local wmVector,wmAngle = Vector(),Angle()

local MatrixLocal,MatrixWorld = Matrix(),Matrix()

local VecSet,AngSet = Vector(),Angle()

function SWEP:SetupBones_WorldModel_ByTPIK(tpikMatrix)
    local link,ent = tpikMatrix.link,tpikMatrix.ent

    local Pos,Ang = link:Eye()
    if not Pos then return end

    --[[if link:GetNWBool("Fake") then
        ent:CopyBoneMatrixHash(ent:LookupBone("ValveBiped.Bip01_Head1"),MatrixWorld)

        MatrixWorld:SetPYR(AngSet)

        AngSet[3] = 0
        AngSet:Normalize()
    end]]--

    wmVector:Set(self.wmData.vec or vec_zero)
    wmAngle:Set(self.wmData.ang or ang_zero)

    local isLocalClient = CLIENT and self:IsLocal()

    if isLocalClient then self:SetupBones_OnChange_Immersive(tpikMatrix,Pos,Ang,wmVector,wmAngle) end

    self:SetupBones_OnChange_Animation(tpikMatrix,Pos,Ang,wmVector,wmAngle)
    
    if not self:SetupBones_OnChange_Vehicle(tpikMatrix,Pos,Ang,wmVector,wmAngle) then
        if not self:SetupBones_OnChange(tpikMatrix,Pos,Ang,wmVector,wmAngle) then
            MatrixLocal:Identity()
            MatrixLocal:SetTranslation(wmVector)
            MatrixLocal:SetAngles(wmAngle)

            MatrixWorld:Identity()
            MatrixWorld:SetTranslation(Pos)
            MatrixWorld:SetAngles(Ang)

            MatrixWorld:Mul(MatrixLocal)
            MatrixWorld:SetXYZ_PYR(Pos,Ang)

            self:Transform_GetCenter(Pos,Ang)
        end
    end

    self:SetupBones_DoAnimation(tpikMatrix,Pos,Ang)
    if isLocalClient then self:SetupBones_DoAnimation_Immersive(tpikMatrix,Pos,Ang) end
    self:SetupBones_Finish(tpikMatrix,Pos,Ang)

    local wm = tpikMatrix.wm

    wm:SetPos(Pos)
    wm:SetAngles(Ang)
    
    self:ApplySequenceOnWorldModel(wm)

    if CLIENT then self:SetupModel(wm) end
    
    return Pos,Ang
end

function SWEP:SetupBones_OnChange(tpikMatrix,Pos,Ang,wmVector,wmAngle) end
function SWEP:SetupBones_Finish(tpikMatrix,Pos,Ang) end

function SWEP:SetupBones_OnChange_Vehicle(tpikMatrix,Pos,Ang,wmVector,wmAngle)
    local link = tpikMatrix.link
    local ent = tpikMatrix.ent
    if not link:InVehicle() then return end

    local matHead = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1"))
    if not matHead then return end

    local vehicleAng = link:GetVehicleEntity():GetAngles()

    local newPos,newAng = LocalToWorld(Vector(-3,0,0),wmAngle,matHead:GetTranslation(),vehicleAng:Clamp(Ang,90))

    Pos:Set(newPos)
    Ang:Set(newAng)

    return true
end

function SWEP:SetupBones_OnChange_Animation(tpikMatrix,Pos,Ang,wmVector,wmAngle)
    local sequenceObject = self.sequenceObject

    if sequenceObject then
        local cycle = sequenceObject:GetCycle()

        if sequenceObject.OnChangeEye then sequenceObject:OnChangeEye(tpikMatrix,Pos,Ang,wmVector,wmAngle) end

        if sequenceObject.GraphVectorWM then
            wmVector:Add(math.EvalGraphVector(cycle,sequenceObject.GraphVectorWM))
        end

        if sequenceObject.GraphElbowRight then
            tpikMatrix.rightDown = math.EvalGraph(cycle,sequenceObject.GraphElbowRight)
        end

        if sequenceObject.GraphElbowLeft then
            tpikMatrix.leftDown = math.EvalGraph(cycle,sequenceObject.GraphElbowLeft)
        end
    end
end

function SWEP:SetupBones_DoAnimation(tpikMatrix,Pos,Ang) end

local vec_zero = Vector()

local hg_dev_disable_immersive

if CLIENT then
    cvars.CreateDevOption("hg_dev_disable_immersive","0",function(value)
        hg_dev_disable_immersive = tonumber(value or 0) > 0
    end,0,1)
end

function SWEP:SetupBones_OnChange_Immersive(tpikMatrix,Pos,Ang,wmVector,wmAngle)
    if hg_dev_disable_immersive then return end

    local wm = tpikMatrix.wm
    local time = RealTime()

    if RenderCamera then return end

    if not wm.immersiveWMVector then
        wm.immersiveWMVector = Vector()
        wm.immersiveWMVectorSet = Vector()
        wm.immersiveWMVectorDelay = 0
        
        wm.immersiveWMAngle = Angle()
        wm.immersiveWMAngleSet = Angle()
        wm.immersiveWMAngleDelay = 0
    end

    if wm.immersiveWMVectorDelay < time then
        wm.immersiveWMVectorDelay = time + math.Rand(1 / 11,1 / 12)

        local len = math.Rand(-0.1,0.1)

        if tpikMatrix.link:InFake() then len = len / 5 end
        
        wm.immersiveWMVectorSet:Set(vec_zero)
        wm.immersiveWMVectorSet[1] = len
        wm.immersiveWMVectorSet:Rotate(Angle(math.Rand(-15,15),math.Rand(-20,20),0))
    end

    wm.immersiveWMVector:LerpFT(0.1,wm.immersiveWMVectorSet)

    wmVector:Add(wm.immersiveWMVector:Clone():Rotate(wmAngle))
end

SWEP.ImmersiveAngleSetMul = 1
SWEP.ImmersiveAngleVelocityMul = 1
SWEP.ImmersiveAngleMul = 1
SWEP.ImmersiveAngleBreathMul = 1

SWEP.ImmersiveAngleSmooth = 3

local Clamp = math.Clamp

function SWEP:SetupBones_DoAnimation_Immersive(tpikMatrix,Pos,Ang)
    if hg_dev_disable_immersive then return end
    if RenderCamera then return end

    local _,EyeAng = tpikMatrix.link:Eye()
    
    local wm = tpikMatrix.wm
    local deltaTime = tpikMatrix.deltaTime
    local link = tpikMatrix.link

    if not wm.lastEyeAng then
        wm.lastEyeAng = EyeAng

        wm.immersiveAng = Angle()
        wm.immersiveAngSet = Angle()

        wm.immersiveMoveSet = Vector()
        wm.immersiveMove = Vector()
        wm.immersiveMoveDelay = 0

        wm.immersiveVelocitySet = Angle()
        wm.immersiveVelocity = Angle()

        wm.immersiveBreathSet = Angle()
        wm.immersiveBreath = Angle()
        wm.immersiveBreathDelay = 0
    end

    --

    local diffAng = EyeAng - wm.lastEyeAng
    wm.lastEyeAng = EyeAng

    local immersiveAngSet = wm.immersiveAngSet
    immersiveAngSet:Add(diffAng)
    immersiveAngSet:LerpFrameTime(66 * self.ImmersiveAngleSetMul,nil,deltaTime)
    immersiveAngSet:Normalize()

    local immersiveAng = wm.immersiveAng
    immersiveAng:LerpFrameTime(33 * self.ImmersiveAngleMul,immersiveAngSet,deltaTime)
    immersiveAng:Normalize()

    immersiveAng[1] = Clamp(immersiveAng[1],-45,45)
    immersiveAng[2] = Clamp(immersiveAng[2],-45,45)
    immersiveAng[3] = Clamp(immersiveAng[3],-45,45)

    local time = RealTime()

    if wm.immersiveBreathDelay < time then
        wm.immersiveBreathDelay = time + math.Rand(1 / 20,1 / 25)

        local len = self:GetImmersiveVelocity(wm,link)
        wm.immersiveVelocitySet:LerpFT(0.7,Angle(math.Rand(-len,len),math.Rand(-len,len),math.Rand(-len,len)))

        local len = self:GetImmersiveBreath(wm,link)
        wm.immersiveBreathSet:Set(Angle(math.Rand(-len,len),math.Rand(-len,len),0))
    end
    
    wm.immersiveVelocity:LerpFT(0.2,wm.immersiveVelocitySet)
    wm.immersiveBreath:LerpFT(0.07,wm.immersiveBreathSet)

    if wm.immersiveMoveDelay < time then
        wm.immersiveMoveDelay = time + math.Rand(1 / 42,1 / 40)
        
        local len = self:GetImmersiveMove(wm,link)        
        wm.immersiveMoveSet:Lerp(0.2,VectorRand():Mul(len))
    end

    wm.immersiveMove:LerpFT(0.15,wm.immersiveMoveSet)

    --

    wm.immersiveRotateK = LerpFT(0.1,wm.immersiveRotateK or 0,(link:InFake() or link:Crouching()) and 0.5 or 2)

    local rotateAng = immersiveAng * Lerp(math.min(immersiveAng:Length() / self.ImmersiveAngleSmooth,1),wm.immersiveRotateK,0)
    rotateAng:Add(wm.immersiveVelocity * self.ImmersiveAngleVelocityMul)
    rotateAng:Add(wm.immersiveBreath * self.ImmersiveAngleBreathMul)
    
    if self.sequenceObject then
        if self.sequenceObject.GraphRotateWM then
            rotateAng:Add(math.EvalGraphAngle(self:GetCycle(),self.sequenceObject.GraphRotateWM))
        end
    end

    rotateAng:Mul(0.1)
    
    local newPos,newAng = RotateAroundPoint_LocalCenter(Pos,Ang,-self.WorldModelCenter[1]:Clone(),rotateAng)
    
    newPos:Add(wm.immersiveMove)
   
    newAng:Add(wm.immersiveAng / 6)
    newAng:Add(wm.immersiveVelocity)

    Pos:Set(newPos)
    Ang:Set(newAng)
end

function SWEP:GetImmersiveVelocity(wm,link)
    local len = link:GetVelocity():Div(60):Length()
    if link:Crouching() then len = len * 2 end
    if link:IsSprinting() and link:GetDelayFootstep() then len = len + 3  end

    return len
end

function SWEP:GetImmersiveBreath(wm,link)
    return (link:InFake() and 0 or 0.3) + math.min(link:GetMetabolismStaminaDelay() * 7,3)
end

function SWEP:GetImmersiveMove(wm,link)
    local len = wm.immersiveAng:Length() / 5
    if self.sequenceObject and (not self.sequenceObject.fire and not self.sequenceObject.dontShake) then len = len + 2 end

    return len
end