local BULLET = oop.Reg("bullet_entity",{"bullet","custom_networker"},true)
if not BULLET then return INCLUDE_BREAK end

BULLET.RemoveOnHit = false
BULLET.DefaultTypeTransmit = "byParent"
BULLET.AlwaysThinkLocalPhysics = false

BULLET:Event_Add("SetClassBullet","Entity",function(self,classBullet,bulletInfo)
    self.modelPath = bulletInfo.modelPath
    self.flySound = bulletInfo.FlySound
end)

if CLIENT then
    BULLET:Event_Add("Init","CreateClientSideNetworker",function(self)
        if self:IsValidAnyNetworker() then return end

        local cNetworker = self:SetNetworker(self.modelPath)
        if not cNetworker then return end--sNetworker is exists

        cNetworker:SetAngles(self.ang)
        cNetworker:SetPos(self.pos:Clone())
    end)
end

BULLET:Event_Add("Think","Networker",function(self)
    if CLIENT then
        local networker = self.cNetworker

        if IsValid(networker) and not self:GetPVSVar("Hit") then
            networker:SetPos(self.pos)
            networker:SetAngles(self.ang)
        end

        local sNetworker = self.sNetworker

        if IsValid(sNetworker) then
            if sNetworker.BulletSetupPosition then sNetworker.BulletSetupPosition() end

            if not self.AlwaysThinkLocalPhysics and not self:IsLocal() then
                self.pos:Set(sNetworker:GetPos())
            end
        end
    else
        local networker = self.sNetworker

        if IsValid(networker) then
            if not self:GetPVSVar("Hit") then
                networker:SetPos(self.pos)
                networker:SetAngles(self.ang)
            end

            if IsValid(networker:GetOwner()) then
                self:Remove()
            end--ИДИ НА_ХУЙ
        end
    end
end)

BULLET:Event_Add("Init","MatrixLerp",function(self)
    self.MatrixLerp = Matrix()
end,-10)

local MatrixSetWorld = Matrix()
local MatrixSetLocal = Matrix()
local MatrixSetLocalBone = Matrix()

local vec_zero,ang_zero = Vector(),Angle()

function BULLET:GetRenderMatrix(sNetworker,MatrixSetOld,animationK)
    local MatrixLerp = self.MatrixLerp

    local parent = sNetworker:GetParent()

    if IsValid(parent) then
        local bone = self:GetPVSVar("Bone") or 0
        
        if parent:GetBoneCount() > 0 then
            parent = parent.GetDummy and parent:GetDummy()
            parent:CopyBoneMatrixHash(bone,MatrixSetWorld)

            if MatrixSetWorld:IsZero() then return end
        else
            MatrixSetWorld:Identity()
            MatrixSetWorld:SetTranslation(parent:GetPos())
            MatrixSetWorld:SetAngles(parent:GetAngles())
        end

        MatrixSetLocalBone:Identity()
        MatrixSetLocalBone:SetTranslation(self:GetPVSVar("LocalPos") or vec_zero)
        MatrixSetLocalBone:SetAngles(self:GetPVSVar("LocalAng") or ang_zero)

        MatrixSetWorld:Mul(MatrixSetLocalBone)
    else
        MatrixSetWorld:SetTranslation(sNetworker:GetPos())
        MatrixSetWorld:SetAngles(sNetworker:GetAngles())
    end

    local modelInfo = self:GetAmmoClassBullet().CenterModel

    if modelInfo then
        MatrixSetLocal:Identity()
        MatrixSetLocal:SetTranslation(modelInfo[1])
        MatrixSetLocal:SetAngles(modelInfo[2])

        MatrixSetWorld:Mul(MatrixSetLocal)
    end

    if MatrixSetOld and animationK > 0 then
        MatrixSetWorld:Lerp(animationK,MatrixSetOld)
    end
    
    if not self:GetPVSVar("Hit") then
        if MatrixLerp then
            if MatrixLerp:IsIdentity() then MatrixLerp:Set(MatrixSetWorld) end

            MatrixLerp:Lerp(math.Clamp(30 * FrameTime(),0,1),MatrixSetWorld)

            return MatrixLerp
        else
            return MatrixSetWorld
        end
    else    
        return MatrixSetWorld
    end
end