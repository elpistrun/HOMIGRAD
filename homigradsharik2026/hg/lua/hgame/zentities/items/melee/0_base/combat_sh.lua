local SWEP = oop.Get("wep_melee_base")
if not SWEP then return end

function SWEP:CanAttack(_,startTime)
    return not self:IsCooldown("attack",self:GetOwner())
end

local tr = hitBoxGame.CreateTraceTable()
tr.mask = MASK_SHOT

function SWEP.anm_ActionLoad(object,cmd)
    if not object.isLocal then return end

    local self = object.parent

    local pos,ang,renderTime

    if cmd then
        pos,ang,renderTime = cmd.pos,cmd.ang,cmd.renderTime
    else
        pos,ang = self:GetShootMatrix()
        renderTime = GetRenderTime()
    end
    
    local self = object.parent
    local owner = self:GetOwner()

    tr.ClearFilterTrace()
    tr.filterTrace[owner] = true
    tr.filterTrace[owner:GetDummy()] = true

    tr.start = pos + object.attackPosStart:Clone():Rotate(ang)
    tr.endpos = pos + object.attackPosEnd:Clone():Rotate(ang)
    tr.mins = object.hitboxMins
    tr.maxs = object.hitboxMaxs

    local result

    local debug = owner:GetLagCompresionDebug() > 0

    local closeHitPos

    for i = 1,self[object.typeAttack].MultiAttack or 1 do
        if self[object.typeAttack].FirstHullTrace then
            result = hitBoxGame.LagTraceHull(tr,renderTime,debug)

            if not result.Hit then
                result = hitBoxGame.LagTraceLine(tr,renderTime,debug)
            end
        else
            result = hitBoxGame.LagTraceLine(tr,renderTime,debug)

            if not result.Hit then
                result = hitBoxGame.LagTraceHull(tr,renderTime,debug)
            end
        end

        if not result.HitPos then continue end--wtf

        local length = result.HitPos:Length(result.StartPos)

        closeHitPos = math.min(closeHitPos or length,length)

        if length > closeHitPos + 6 then continue end

        debug = nil

        if tr.filterTrace[result.Entity] then continue end--fucking world
        tr.filterTrace[result.Entity] = true

        if result.Hit then self:Hit(result,object.typeAttack) end

        tr.filterTrace[result.Entity:GetDummy()] = true
    end
end

SWEP:ConstructAnimationAction("attack_primary",
    function(object,cmd)
        local self = object

        self:SetCooldown("attack",self.Primary.Delay)

        local sequenceObject = self:PlayAnimation("attack_primary")
        sequenceObject.typeAttack = "Primary"
        
        if SERVER then self:SyncAnimation() end

        return true
    end,
    function(self,anim)
        anim.Load = self[1].anm_ActionLoad
    end,
    true
)

SWEP:ConstructAnimationAction("attack_secondary",
    function(object,cmd)
        local self = object

        self:SetCooldown("attack",self.Secondary.Delay)

        local sequenceObject = self:PlayAnimation("attack_secondary")
        sequenceObject.typeAttack = "Secondary"
        
        if SERVER then self:SyncAnimation() end

        return true
    end,
    function(self,anim)
        anim.Load = self[1].anm_ActionLoad
    end,
    true
)

local recipientFilter = SERVER and RecipientFilter(true)

SWEP.EnableSoundBulllet = true

local evalVibration = {
    {0,0},
    {0.26,0.5},
    {1,1}
}

function SWEP:Hit(result,typeAttack)
    local entity = result.Entity

    local surfaceName = surfaceWorld.GetSurfaceNameByTrace(result)
    local info = surfaceWorld.Fast.sound.bullet[surfaceName]

    if self.EnableSoundBulllet and info then
        local fleshSnd = self[typeAttack].SoundHitFlesh

        local volume = self[typeAttack].Volume
        
        if util.IsHumanoid(entity) and fleshSnd then
            self:EmitLocalSound(fleshSnd.list[math.random(1,#fleshSnd.list)],75,fleshSnd.volume or volume,fleshSnd.pitch)
        else
            local sndHit = self[typeAttack].SoundHit

            if sndHit then
                self:EmitLocalSound(sndHit.list[math.random(1,#sndHit.list)],75,sndHit.volume or volume,sndHit.pitch)
            end

            self:EmitLocalSound(info.list[math.random(1,#info.list)],75,volume)
        end
    end

    local dmgTab

    if SERVER then
        if IsValid(entity) then
            entity = entity:GetController() or entity
            dmgTab = CreateDamageTab(entity,self:GetOwner(),self,self[typeAttack].Damage,self[typeAttack].DamageType)
            dmgTab.isMelee = true
            dmgTab.pos = result.HitPos
            dmgTab.ent = entity
            dmgTab.bone = result.HitBone

            dmgTab.pain = self[typeAttack].DamagePain
            dmgTab.bleed = self[typeAttack].DamageBleed
            dmgTab.impulse = self[typeAttack].DamageImpulse
            dmgTab.dontBleedArtery = self[typeAttack].DontBleedArtery

            dmgTab.force = result.Normal * (self[typeAttack].Force or 1)
            dmgTab.forcePhys = dmgTab.force

            if self[typeAttack].ForceRagdoll then
                dmgTab.forcePhysRagdoll = result.Normal * self[typeAttack].ForceRagdoll
            else
                dmgTab.forcePhysRagdoll = dmgTab.force * 10
            end

            DamageTab_ParseBone(dmgTab)

            if self.PreHit then self:PreHit(dmgTab,result,surfaceName) end
            
            entity:TakeDamageTab(dmgTab)

            if self.PostHit then self:PostHit(dmgTab,result,surfaceName) end

            if self.EnableBlooded then
                if util.IsHumanoid(entity) then
                    if not self:GetPVSVar("IsBlooded") then
                        self:SetPVSVar("IsBlooded",true)

                        inventoryGame.SyncItemByEntity(self)
                    end

                    local dir = (dmgTab.pos - result.StartPos):GetNormalized()

                    if self[typeAttack].SoundHitFlesh then
                        gibParticles.bloodHitSlashCreate(dmgTab.pos,dir,entity)
                    else
                        gibParticles.bloodHitCreate(dmgTab.pos,dir,entity)
                    end
                end

                if self.EnableBulletDecal then
                    surfaceWorld.CreateDecalBullet(result.HitPos:Clone(),result.HitNormal:Clone(),result.Entity,surfaceName)
                end
            else
                if self.EnableBulletDecal and not util.IsHumanoid(entity) then surfaceWorld.CreateDecalBullet(result.HitPos,result.HitNormal,result.Entity,surfaceName) end
            end
        else
            if self.EnableBulletDecal then
                surfaceWorld.CreateDecalBullet(result.HitPos,result.HitNormal,result.Entity,surfaceName,self.BulletDecalSizeW,self.BulletDecalSizeH)
            end
        end
    end

    if self.EnableBulletEffect then
        if SERVER then
            surfaceWorld.CreateEffectBullet_Net(result.HitPos,result.HitNormal,result.Entity,surfaceName,1)
            recipientFilter:AddPVS(result.HitPos)
            recipientFilter:RemovePlayer(self:GetOwner())
            net.Send(recipientFilter)
        else
            surfaceWorld.CreateEffectBullet(result.HitPos,result.HitNormal,nil,surfaceName,1)
        end
    end
    
    if self.HitPost then self:HitPost(result,typeAttack,surfaceName) end

    if SERVER and IsValid(entity) and (entity:GetController() or entity):IsPlayer() and IsValid(self:GetOwner()) then
        net.Start("hit_detect")
        net.Send(self:GetOwner())
    end

    if self.EnableMetalVibration and surfaceWorld.TypeIndex[surfaceName] == "metal" then
        self:SetPVSVar("VibrationMetal",CurTime())

        self:EmitLocalSound("homigrad/physics/metal_vibration.ogg",75,1,
            Lerp(
                math.Clamp(
                    (IsValid(result.Entity) and (1 - math.EvalGraph(result.Entity.obbLenghtMetrs / 5,evalVibration)))
                    or 0,
                    0,1
                ),
                50,255
            )
        )
    end

    if SERVER then
        if util.IsButton(result.Entity) then
            result.Entity:Fire("Use",nil,0,self,self:GetOwner())
        end
    end

    return dmgTab
end

SWEP.AnimationInspectList = {
    "inspect"
}

local action = SWEP:CreateAction("inspect")
function action.Start(self,cmd)
    if #self.AnimationInspectList == 0 then return false end

    local animName = self.AnimationInspectList[math.random(1,#self.AnimationInspectList)]
    if not self.AnimationList[animName] then return false end
    
    self:PlayAnimation(animName)
    if SERVER then self:SyncAnimation() end
    
    return true
end