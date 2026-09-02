local ANM = animationEntity.Reg("anm_kick","base",true)
if not ANM then return INCLUDE_BREAK end

ANM.sequence = "range_melee"
    
ANM.delay = 1
ANM.moveMul = 0.02
ANM.startCycle = 0.1

ANM.dontSprint = true

if CLIENT then
    local Fast_sound_bullet = surfaceWorld.Fast.sound.footkick

    function ANM:EmitSurface(result)
        local surfaceName = surfaceWorld.GetSurfaceName(result.SurfaceProps)

        local surfaceInfo = Fast_sound_bullet[surfaceName]
        if not surfaceInfo then print("anim_kick.EmitSurface-> missing " .. surfaceName) return end

        sound.Emit(result.Entity,surfaceInfo.list[math.random(1,#surfaceInfo.list)],75,1,surfaceInfo.pitch,result.HitPos)
    end
end

function ANM:CanStart()
    return not self.parent:IsCooldown("kick",self.parent) and not self.parent:Crouching() and not self.parent:GetNWBool("Fake") and self.parent:GetStamina() > 5
end

local tr = hitBoxGame.CreateTraceTable()

function ANM:Start()
    local ply = self.parent

    local slotGesture = GESTURE_SLOT_ATTACK_AND_RELOAD
    ply:AddVCDSequenceToGestureSlot(slotGesture,ply:LookupSequence(self.sequence),0,true)
    ply:SetLayerDuration(slotGesture,self.delay)

    tr.ClearFilterTrace()
    tr.filterTrace[ply:GetDummy()] = true
    
    self:StartPost()
end

function ANM:StartPost()
    local ply = self.parent

    ply:SetCooldown("kick",0.5 + ply:GetMetabolismStaminaDelay() * 5)

    if SERVER then
        ply:SetStamina(ply:GetStamina() - 2)
    end

    if CLIENT then
        sound.Emit(ply:EntIndex(),"weapons/melee/matelbat/bat_draw.wav",75,1,90,ply:GetPos() + ply:OBBCenter())
        sound.Emit(ply:EntIndex(),"weapons/melee/matelbat/bat_heavy" .. math.random(1,3) .. ".wav",75,1,90,ply:GetPos() + ply:OBBCenter())
    end
end

function ANM:MoveThink(mv)
    mv:SetMaxSpeed(mv:GetMaxSpeed() * self.moveMul)

    local eyePos,eyeAng = self.parent:Eye()

    if self.parent:IsOnGround() then
        mv:SetVelocity(mv:GetVelocity() + Vector(8,0,0):Rotate(Angle(0,eyeAng[2],0)))--чтоб повернулся пидорас
    end
end

function ANM:Think(cycle)
    if self.renderTime then self.renderTime = self.renderTime + FrameTime() end

    if self.isLocal and cycle >= 0.3 and cycle <= 0.4 then
        local tr = self:ParseTrace(tr)

        local result = hitBoxGame.LagTraceHull(tr,self.renderTime,self.debug)

        local hitEntity = result.Entity
        if IsValid(hitEntity) then tr.filterTrace[hitEntity] = true end

        if SERVER then self:AttackServer(result) end

        if not self.hitWorld and result.Hit then
            self.hitWorld = true

            self:EmitSurface(result)
        end
    end
end

local mins = -Vector(0,12,19)
local maxs = Vector(0,12,19)

function ANM:ParseTrace(tr)
    local eyePos,eyeAng = self.parent:Eye()
    eyeAngYaw = Angle(0,eyeAng[2],0)

    eyeAng[1] = math.Clamp(eyeAng[1],0,0)
    eyePos[3] = eyePos[3] - 30

    tr.start = eyePos
    tr.endpos = eyePos + Vector(PlayerDisUse,0,0):Rotate(eyeAng)

    tr.mins = mins
    tr.maxs = maxs

    return tr
end

if SERVER then
    ANM.Damage = 25
    ANM.Force = 250

    function ANM:AttackServer(result)
        local ply = self.parent
        if not IsValid(ply) then return end

        local hitEntity = result.Entity
        if not IsValid(hitEntity) or hitEntity == ply then return end

        local ctrl = hitEntity:GetController()
        local entity = IsValid(ctrl) and ctrl or hitEntity

        local pos = result.HitPos
        local surfaceName = surfaceWorld.GetSurfaceName(result.SurfaceProps)

        if util.IsHumanoid(entity) then
            sound.EmitNET(hitEntity,"physics/body/body_medium_impact_hard" .. math.random(5,6) .. ".wav",75,1,90,pos)
        else
            sound.EmitNET(hitEntity,"physics/body/body_medium_impact_hard" .. math.random(1,3) .. ".wav",75,1,100,pos)
        end

        local dmgTab = CreateDamageTab(entity,ply,ply:GetActiveWeapon(),self.Damage,DMG_CLUB)
        dmgTab.isMelee = true
        dmgTab.pos = pos
        dmgTab.ent = hitEntity
        dmgTab.bone = result.HitBone

        local force = (result.Normal or Vector(1,0,0)) * self.Force

        dmgTab.force = force
        dmgTab.forcePhys = force
        dmgTab.forcePhysRagdoll = force * 10

        DamageTab_ParseBone(dmgTab)

        entity:TakeDamageTab(dmgTab)
    end

    -- Server-side handler for the footkick command sent by the client.
    -- Replays the animation on the server so other players see it
    -- and the authoritative trace/damage runs inside ANM:Think.
    concommand.Add("footkick_native",function(ply,_,args)
        if not IsValid(ply) or not ply:Alive() then return end
        if ply:GetStamina() <= 5 then return end

        local moveType = tonumber(args[1]) or 0
        local anmName = moveType == 1 and "anm_kick_down" or "anm_kick"

        local sequenceObject = ply:PlayAnimation("foot",{name = anmName})
        if not sequenceObject then return end
        sequenceObject:Start()
    end)
end