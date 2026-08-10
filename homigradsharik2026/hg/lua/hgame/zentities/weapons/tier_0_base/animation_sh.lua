local SWEP = oop.Get("hg_wep")
if not SWEP then return end

function SWEP:OnDeploy()
    self:PlayDeployAnimation()
end

function SWEP:OnHolster()
    self:PlayHolsterAnimation()
end

function SWEP:GetSequenceIdleIndex() return self:IsGateDelay() and self.IdleEmptySequenceIndex or (self.AnimationList["fire"] and self.AnimationList["fire"].index) or 0 end

function SWEP:OnGetSequenceIndex(sequenceObject,wm)
    if not wm.isWorldModel then return 0,1 end

    if self.PreGetSequenceIndex then return self:PreGetSequenceIndex(sequenceObject,wm) end

    if sequenceObject and self:IsGateDelay() and sequenceObject.indexEmpty then return sequenceObject.indexEmpty,sequenceObject:GetCycle("animation") end
end

SWEP.lastShoot = 0

function SWEP:SetupAttackVars()
    self.recoil = 1

    self.recoilRandAbs = math.randAbs()

    self.lastShoot = RealTime()

	if self:GetNWFloat("Smoke",0) < CurTime() then
		self:SetNWFloat("Smoke",CurTime() + 0.25)
	else
		self:SetNWFloat("Smoke",self:GetNWFloat("Smoke",0) + 0.25)
	end
end

SWEP.recoil = 0
SWEP.recoilRandAbs = 1
SWEP.recoilLerp = 0.15

SWEP.scopeLerp = 0
SWEP.recoilAngUp = 0

SWEP.scopeInterp = 0.07
SWEP.a_fSprintLerp = 0

local angle_zero = Angle()

local suicideAng = Angle(-45,0,0)
local standUpAng = Angle(0,0,0)
local scopeVecBack = Vector(1,1,1)

local angTemp = Angle()

function SWEP:SetupBones_OnChange(tpikMatrix,Pos,Ang,wmVector,wmAngle)
    local deltaTime = tpikMatrix.deltaTime
    local ent,link = tpikMatrix.ent,tpikMatrix.link

    if link:GetNWBool("Suicide") then
        suicideAng[2] = Ang[2]
        Ang:Set(suicideAng)
        
        return
    end

    local k = self:GetStandAnimK()

    standUpAng[2] = Ang[2]
    Ang:Lerp(1 - k,standUpAng)

    if not link:InFake() then
        if not RenderCamera then
            self.a_fSprintLerp = LerpFrameTime(self:IsSprinting() and 0.1 or 0.05,self.a_fSprintLerp or 0,self:IsSprinting() and 1 or 0,deltaTime)
        end
        
        --self.sprintLerp = 1

        if self.stateHandling != "holster" then self:SetStandType(self.a_fSprintLerp > 0.9 and "normal" or self.HoldType) end

        if self.a_fSprintLerp > 0.1 then
            local sLerp = math.ease.InCubic(self.a_fSprintLerp)

            local mat = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine4"))

            if mat then
                Pos:Lerp(sLerp,mat:GetTranslation())

                angTemp[1] = 0
                angTemp[2] = Ang[2]

                Ang:Lerp(sLerp,angTemp)
                
                wmAngle[1] = wmAngle[1] - 25 * sLerp
                wmAngle[2] = wmAngle[2] + 50 * sLerp
                
                wmVector[1] = wmVector[1] + 3 * sLerp
                wmVector[2] = wmVector[2] + 5 * sLerp

                --

                local delay,moveK = link:GetDelayFootstep()

                self.a_fSprintMode = LerpFrameTime(0.1,self.a_fSprintMode or 0,delay and 0 or 1,deltaTime)
                local a_fSprintMode = self.a_fSprintMode * sLerp

                wmAngle[1] = wmAngle[1] - 25 * a_fSprintMode
                wmVector[2] = wmVector[2] + 2 * a_fSprintMode
                wmVector[3] = wmVector[3] + 3 * a_fSprintMode

                tpikMatrix.rightDown = Lerp(a_fSprintMode,tpikMatrix.rightDown,120)
                tpikMatrix.leftDown = Lerp(a_fSprintMode,tpikMatrix.leftDown,180)

                if delay then
                    local time = CurTime()

                    if (self.a_fSprintDelay or 0) + delay < time then
                        self.a_fSprintDelay = time

                        self.a_modeSprint = not self.a_modeSprint
                    end

                    self.a_fSprint = LerpFrameTime(0.1,self.a_fSprint or 0,(1 - (self.a_fSprintDelay - time + delay) / delay) * (self.a_modeSprint and -1 or 1) + math.Rand(-0.1,0.1),deltaTime)
                    local a_fSprint = self.a_fSprint * sLerp * moveK

                    wmVector[2] = wmVector[2] + 5 * a_fSprint
                    wmVector[3] = wmVector[3] - 1 * a_fSprint
      
                    wmAngle[2] = wmAngle[2] + (a_fSprint > 0 and 25 or 45) * a_fSprint
                end
            end
        end
    else
        self.a_fSprintLerp = 0
    end

    if self.scopeLerp > 0.001 then
        wmVector:Add(scopeVecBack * self.scopeLerp)
    end

    if self.CameraFollowBackRecoil or not RenderCamera and self.recoil > 0.001 then
        self:DoAnimationRecoil(wmAngle,wmVector)
    end
end

function SWEP:DoAnimationRecoil(wmAngle)
    wmAngle[2] = wmAngle[2] + Lerp(self.scopeLerp,self.recoilAngUp,self.recoilAngUp_Scope or self.recoilAngUp) * self.recoil
end

SWEP.RecoilBackMul = 1
SWEP.CameraFollowBackRecoil = false

function SWEP:SetupBones_DoAnimation(tpikMatrix,pos,ang)
    local wm,rag,dt = tpikMatrix.wm,tpikMatrix.ent,tpikMatrix.deltaTime

    if self.CameraFollowBackRecoil or not RenderCamera then
        self.recoil = LerpFrameTime(self.recoilLerp,self.recoil or 0,0,dt)

        if self.recoil > 0.001 then
            pos:Add(-Vector(self.recoil,0,0):Rotate(ang) * self.RecoilBackMul)
        end
    end

    local len = self.CloseWallLen or 22

    local owner = self:GetOwner()

    if owner:GetNWBool("Suicide") then
        local head = rag:GetBoneMatrix(rag:LookupBone("ValveBiped.Bip01_Head1"))

        pos:Set(head:GetTranslation())

        pos:Add(Vector(0,-5,0):Rotate(head:GetAngles()))

        ang:Set((pos - head:GetTranslation()):Angle())
        ang:RotateAroundAxis(ang:Up(),180)

        pos:Sub(Vector(len * 0.75,0,0):Rotate(ang))

        self:Transform_GetCenter(pos,ang)
    
        return
    end

    local muzzlePos,muzzleAng = self:GetShootMatrix(wm)
    if not muzzlePos then return end

    self:DoCloseFraction(muzzlePos,muzzleAng,len,dt)

    pos:Add(muzzleAng:Forward():Mul(-(len + 4) * self.fraction))
    
    self:SetupBones_DoAnimationPost(wm,rag,pos,ang,dt)
end

function SWEP:SetupBones_DoAnimationPost() end

local action = SWEP:CreateAction("inspect")

function action.Start(self,cmd)
    if CLIENT and IsValid(vgui.GetHoveredPanel()) then return false,"ui" end

    local animName = self.AnimationInspectList[math.random(1,#self.AnimationInspectList)]
    if not animName then return end
    
    self:PlayAnimation(animName)
    if SERVER then self:SyncAnimation() end
    
    return true
end

if SERVER then
    concommand.Add("suicide",function(ply,cmd,args)
        ply:SetNWBool("Suicide",not ply:GetNWBool("Suicide"))
    end)

    event.Add("Player Spawn","Suicide",function(ply)
        ply:SetNWBool("Suicide",false)
    end)
else
    keyboard.DefaultBindCode("suicide",31,true)
end

SWEP.ParseAnimationFlags.chamber = {
    flags = {
        canInputStop = true,
        canScope = true
    },
    list = {
        "chamber","chamber_out"
    }
}

SWEP.ParseAnimationFlags.checkMagazine = {
    flags = {
        canScope = true
    },
    list = {
        "checkmagazine"
    }
}

SWEP:AttUpdate("Animation",function(self,class)
    self.RecoilBackMul = class.RecoilBackMul
    self.CameraFollowBackRecoil = class.CameraFollowBackRecoil
end,function(self,att,key)
    if att.RecoilBackMul then self.RecoilBackMul = att.RecoilBackMul end
    if att.CameraFollowBackRecoil ~= nil then self.CameraFollowBackRecoil = att.CameraFollowBackRecoil end
end)