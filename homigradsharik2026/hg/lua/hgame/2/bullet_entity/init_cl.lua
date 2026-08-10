local BULLET = oop.Get("bullet_entity")
if not BULLET then return end

local bulletCracks_close = {
    "weapons/bow/arrow_incoming1.ogg"
}

local bulletCracks_distant = {
    "weapons/bow/arrow_crack1.ogg",
    "weapons/bow/arrow_crack2.ogg",
    "weapons/bow/arrow_crack3.ogg"
}

BULLET.bulletCracks_close = {
    "weapons/bow/arrow_incoming1.ogg"
}

BULLET.bulletCracks_distant = {
    "weapons/bow/arrow_crack1.ogg",
    "weapons/bow/arrow_crack2.ogg",
    "weapons/bow/arrow_crack3.ogg",
}

BULLET.bulletCracks_distant_far = {
    "weapons/bow/arrow_crack1.ogg",
    "weapons/bow/arrow_crack2.ogg",
    "weapons/bow/arrow_crack3.ogg",
}

BULLET.CloseCrackMetrs = 5
BULLET.MaxCrackMetrs = 50

local max = math.max
local LocalToWorld = LocalToWorld

local vec_zero,ang_zero = Vector(0,0,0),Angle(0,0,0)

local MatrixSetWorld = Matrix()
local MatrixSetLocal = Matrix()
local MatrixSetLocalBone = Matrix()

local VecSet,AngSet = Vector(),Angle()

local delayInterpolation = 0.08

function BULLET:OnNetworkerCreate(sNetworker,oldNetworker)
    local cNetworker = self.cNetworker

    if IsValid(self.flySoundObject) then self.flySoundObject.snd:Stop() self.flySoundObject:Remove() end--ez

    local MatrixSetOld

    if IsValid(cNetworker) then
        MatrixSetOld = Matrix()
        MatrixSetOld:SetTranslation(cNetworker:GetPos())
        MatrixSetOld:SetAngles(cNetworker:GetAngles())
    end

    self:RemoveClientSideNetworker()

    local start = RealTime()
    
    local posLerp,angLerp

    local MatrixLerp = Matrix()
    MatrixLerp:Zero()

    sNetworker.BulletSetupPosition = function()
        local animationK = max(start + delayInterpolation - RealTime(),0) / delayInterpolation

        sNetworker:SetRenderOrigin()
        sNetworker:SetRenderAngles()

        local matrix = self:GetRenderMatrix(sNetworker,MatrixSetOld,animationK)

        matrix:SetXYZ_PYR(VecSet,AngSet)

        sNetworker:SetRenderOrigin(VecSet)
        sNetworker:SetRenderAngles(AngSet)
    end

    local classBullet = self:GetAmmoClassBullet()

    if classBullet then
        if classBullet.OnNetworkerCreate then classBullet.OnNetworkerCreate(self,sNetworker,oldNetworker) end
    end

    local oldHUDTarget = sNetworker.oldHUDTarget or sNetworker.HUDTarget
    sNetworker.oldHUDTarget = oldHUDTarget

    if self.classBullet then
        sNetworker.HUDTarget = function(_,ent,k,w,h) return self:HUDTarget(sNetworker,k,w,h) end
    end

    local oldDeterminateUse = sNetworker.oldDeterminateUse or sNetworker.DeterminateUse
    sNetworker.oldDeterminateUse = oldDeterminateUse

    sNetworker.DeterminateUse = function(_,ply,trace) return self:DeterminateUse(sNetworker,ply,trace) end
    
    self:Event_Add("Remove","sNetworker",function()
        if not IsValid(sNetworker) then return end

        sNetworker.BulletSetupPosition = nil
        sNetworker.HUDTarget = oldHUDTarget
        sNetworker.DeterminateUse = oldDeterminateUse
        sNetworker:SetRenderOrigin()
        sNetworker:SetRenderAngles()
    end)

    sNetworker.BulletSetupPosition()

    sNetworker.AlwaysDeterminateUse = true

    self.traceHullMin = sNetworker.bullet_traceHullMin
    self.traceHullMax = sNetworker.bullet_traceHullMax
end

BULLET:Event_Add("Think","FlySound",function(self)
    local networker = IsValid(self.sNetworker) and self.sNetworker or self.cNetworker

    local flyConfig = self.flySound
    if not flyConfig or not IsValid(networker) then return end

    if not self:GetPVSVar("Hit") then
        local flySoundObject = self.flySoundObject

        if not IsValid(flySoundObject) then
            flySoundObject = sound.GetVurtialEmit(self.pos,nil,1)
            flySoundObject.snd = CreateSound(flySoundObject,flyConfig.list[math.random(1,#flyConfig.list)])
            flySoundObject.snd:SetSoundLevel(flyConfig.level)

            self.flySoundObject = flySoundObject
        end

        flySoundObject.sndTimeout = RealTime() + 1

        if not flySoundObject.snd:IsPlaying() then flySoundObject.snd:PlayEx(flyConfig.volume,flyConfig.pitch) end

        flySoundObject:SetPos(self.pos)
    else
        if IsValid(self.flySoundObject) then
            self.flySoundObject.snd:Stop()
            self.flySoundObject:Remove()
        end
    end
end)

BULLET:Event_Add("Remove","flySoundObject",function(self)
    if not IsValid(self.flySoundObject) then return end

    self.flySoundObject.snd:Stop()
    self.flySoundObject:Remove()
end)

function BULLET:OnClientSideNetworkerCreate(cNetworker)
    local classBullet = self:GetAmmoClassBullet()

    if classBullet then
        if classBullet.OnClientSideNetworkerCreate then classBullet.OnClientSideNetworkerCreate(self,cNetworker) end
    end
end

local hg_dev_show_physbox
cvars.Hook("hg_dev_show_physbox","CUENT_BULLET",function(value)
    hg_dev_show_physbox = tonumber(value or 0) > 0
end)

local mins,maxs = -Vector(1,1,1),Vector(1,1,1)

local vec_zero,ang_zero = Vector(),Angle()

function BULLET:DeterminateUse(sNetworker,ply,trace)
    local pos,ang = sNetworker:GetPos(),sNetworker:GetAngles()

    local classBullet = self:GetAmmoClassBullet()
    local mins,maxs = classBullet.DeterminateUseMin or mins,classBullet.DeterminateUseMax or maxs

    if hg_dev_show_physbox then
        local posBack = sNetworker:GetPos()

        sNetworker:SetRenderOrigin()

        local pos = sNetworker:GetPos()
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
            MatrixSetWorld:SetTranslation(pos)
            MatrixSetWorld:SetAngles(ang_zero)
        end

        debugoverlay.BoxAngles(MatrixSetWorld:GetTranslation(),-Vector(1,1,1),Vector(1,1,1),Angle(),0.1,Color(0,0,255,0))

        sNetworker:SetRenderOrigin(posBack)
        debugoverlay.BoxAngles(posBack,mins,maxs,ang,0.1,Color(255,255,255,0))
    end

    local hitPos = util.IntersectRayWithOBB(trace.StartPos,trace.Normal * trace.StartPos:Distance(trace.HitPos),pos,ang,mins,maxs)

    if hitPos then return true end
end

local white = Color(255,255,255)

function BULLET:HUDTarget(sNetworker,k,w,h)
    white.a = 255 * k

    draw.SimpleText(self:GetAmmoClassBullet().name,"HS.18",w/2,h/2,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    
    return true
end

BULLET:Event_Add("HitEnd","Main",function(self,traceResult)
    local cNetworker = self.cNetworker
    local sNetworker = self.sNetworker

    if IsValid(sNetworker) then
        --self:RemoveClientSideNetworker()
    else
        if IsValid(cNetworker) then
            cNetworker:SetPos(traceResult.HitPos)
            cNetworker:SetAngles(traceResult.Normal:Angle())
        end
    end
end)