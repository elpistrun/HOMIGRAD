local SWEP = oop.Get("weapon_hands")
if not SWEP then return end

function SWEP:CanAttack()
    if not self:GetFightState() or self:GetFightBlockState() then return false end

    return true
end

local tr = hitBoxGame.CreateTraceTable()
tr.mask = MASK_SHOT_HULL

local ActionStart = function(self,cmd)
    if not self:CanAttack() then return false,"cantAttack" end
    if self:IsCooldown("Primary",cmd.ply) then return false,"Cooldown Primary" end
    if self:IsTPIKRightInputBusy() or not self:TPIK_CanUseRightHand() then return false,"Some Hand Is Busy" end

    local owner = self:GetOwner()
    owner:SetCooldown("footkick",0.5)

    local staminaDelay = owner:GetMetabolismStaminaDelay() * 4

    self:SetCooldown("Primary",self.Primary.Delay + staminaDelay)

    self:PlayAnimation({name = "attack_right"})
    if SERVER then self:SyncAnimation() end

    if SERVER then
        owner:SetStamina(owner:GetStamina() - 2)
    end

    return true
end

local function ActionConstruct(self,anim)
    anim.Load = function(object,cmd)
        local self = object.parent
        local pos,ang,renderTime
        
        if cmd then
            pos,ang,renderTime = cmd.pos,cmd.ang,cmd.renderTime
        else
            pos,ang = self:GetShootMatrix()
            renderTime = GetRenderTime()
        end

        tr.ClearFilterTrace()
        tr.filterTrace[self:GetOwner():GetDummy()] = true

        tr.start = pos
        tr.endpos = pos + Vector(PlayerDisUse * object.distanceMul,0,0):Rotate(ang)
        tr.mins = object.hitbox[1]
        tr.maxs = object.hitbox[2]
        
        local result = hitBoxGame.LagTraceHull(tr,renderTime,self:GetOwner():GetLagCompresionDebug() > 0)
        if result.Hit then self:HitPrimary(result) end
    end
end

local function ServerTraceHands(owner,typeAttack)
    local pos,ang = owner:Eye()

    tr.ClearFilterTrace()
    tr.filterTrace[owner:GetDummy()] = true

    tr.start = pos
    local dist = PlayerDisUse * (typeAttack == "Primary" and 0.8 or 0.75)
    tr.endpos = pos + Vector(dist,0,0):Rotate(ang)
    tr.mins = typeAttack == "Primary" and -Vector(0,10,1) or -Vector(0,3,1)
    tr.maxs = typeAttack == "Primary" and Vector(0,-1,1) or Vector(0,4,1)

    local nativeTrace = {
        start = tr.start,
        endpos = tr.endpos,
        mins = tr.mins,
        maxs = tr.maxs,
        mask = MASK_SHOT_HULL,
        filter = function(ent)
            return not tr.filterTrace[ent]
        end
    }

    owner:LagCompensation(true)
    local result = util.TraceHull(nativeTrace)
    owner:LagCompensation(false)

    result.start = result.StartPos
    result.endpos = result.HitPos
    return result
end

local function ScheduleServerHandsLoad(self,sequenceObject,cmd,typeAttack)
    if not SERVER or not sequenceObject then return end

    self.handsLoadToken = (self.handsLoadToken or 0) + 1
    local token = self.handsLoadToken
    local delay = math.max((tonumber(sequenceObject.delay) or 0.5) * (tonumber(sequenceObject.load) or 0.5),0.05)

    timer.Simple(delay,function()
        if not IsValid(self) or self.handsLoadToken != token then return end
        if self.sequenceObject != sequenceObject or sequenceObject.m_load then return end
        if not IsValid(self:GetOwner()) or self:GetOwner():GetActiveWeapon() != self then return end

        local result = ServerTraceHands(self:GetOwner(),typeAttack)
        if result.Hit then
            if typeAttack == "Primary" then
                self:HitPrimary(result)
            else
                self:HitSecondary(result)
            end
        end
        sequenceObject.m_load = true
    end)
end

local action = SWEP:ConstructAnimationAction("attack_right",function(self,cmd)
    local result = ActionStart(self,cmd)
    if result then
        local seq = self.sequenceObject
        if seq then ScheduleServerHandsLoad(self,seq,cmd,"Primary") end
    end
    return result
end,ActionConstruct,true)

local ActionStart = function(self,cmd)
    if not self:CanAttack() then return false,"cantAttack" end
    if self:IsCooldown("Secondary",cmd.ply) then return false,"Cooldown Primary" end
    if self:IsTPIKLeftInputBusy() or not self:TPIK_CanUseLeftHand() then return false,"Some Hand Is Busy" end

    local owner = self:GetOwner()
    owner:SetCooldown("footkick",0.5)

    local staminaDelay = owner:GetMetabolismStaminaDelay() * 2

    self:SetCooldown("Secondary",self.Secondary.Delay + staminaDelay)

    self:PlayAnimation({name = "attack_left"})
    if SERVER then self:SyncAnimation() end

    if SERVER then
        owner:SetStamina(owner:GetStamina() - 2)
    end

    return true
end

local function ActionConstruct(self,anim)
    anim.Load = function(object,cmd)
        local self = object.parent
        local pos,ang
        
        if cmd then
            pos,ang,renderTime = cmd.pos,cmd.ang,cmd.renderTime
        else
            pos,ang = self:GetShootMatrix()
            renderTime = GetRenderTime()
        end

        tr.ClearFilterTrace()
        tr.filterTrace[self:GetOwner():GetDummy()] = true
        
        tr.start = pos
        tr.endpos = pos + Vector(PlayerDisUse * object.distanceMul,0,0):Rotate(ang)
        tr.mins = object.hitbox[1]
        tr.maxs = object.hitbox[2]
        
        local result = hitBoxGame.LagTraceHull(tr,renderTime,self:GetOwner():GetLagCompresionDebug() > 0)
        if result.Hit then self:HitSecondary(result) end
    end
end

local action = SWEP:ConstructAnimationAction("attack_left",function(self,cmd)
    local result = ActionStart(self,cmd)
    if result then
        local seq = self.sequenceObject
        if seq then ScheduleServerHandsLoad(self,seq,cmd,"Secondary") end
    end
    return result
end,ActionConstruct,true)

SWEP:Event_Add("SetupDataTables","Combat",function(self)
    self:NetworkVar("Bool","FightState")
    self:NetworkVarNotify("FightState",function(_,_,old,new)
        if old == new then return end
        self:OnFightStateChange(new)
    end)

    self:NetworkVar("Bool","FightBlockState")
    self:NetworkVarNotify("FightBlockState",function(_,_,old,new)
        if old == new then return end
        self.blockState = new
    end)

    self:NetworkVar("Float","FightBlockStart")
end)

function SWEP:OnFightStateChange(value)
    if value then
        self:PlayAnimation("deploy")
        self:SetStandType(self.HoldTypeCombat)
    else
        self:PlayAnimation("holster")
        self:SetStandType(self.HoldType)
        self:SetFightBlockState(false)
    end
end

function SWEP:SurfaceIsFlesh(surfaceName,hitEntity)
    return surfaceWorld.TypeIndex[surfaceName] == "flesh" or (IsValid(hitEntity) and (hitEntity:IsPlayer() or hitEntity:IsNPC()))
end

function SWEP:HitPrimaryEffect(result)
    local surfaceName = surfaceWorld.GetSurfaceName(result.SurfaceProps)

    local hitEntity = result.Entity

    if self:SurfaceIsFlesh(surfaceName,hitEntity) then
        self.hitStartRight = RealTime()
        sound.Emit(result.Entity,"physics/body/body_medium_impact_hard" .. math.random(5,6) .. ".wav",75,1,90,result.HitPos)
    else
        self.hitStartRight = RealTime()
        sound.Emit(result.Entity,"physics/flesh/flesh_bloody_impact_hard1.wav",75,1,90,result.HitPos)

        local surfaceInfo = Fast[surfaceName]
        if surfaceInfo then sound.Emit(hitEntity,surfaceInfo.list[math.random(1,#surfaceInfo.list)],75,1,surfaceInfo.pitch,result.HitPos) end
    end
end

if CLIENT then
    local cmd = {name = "attack_right"}

    function SWEP:PrimaryAttack()
        if not IsFirstTimePredicted() then return end

        local pos,ang = self:GetShootMatrix()
        cmd.pos = pos
        cmd.ang = ang
        cmd.renderTime = GetRenderTime()

        self:DoAction(cmd)
    end

    local cmd = {name = "attack_left"}

    function SWEP:SecondaryAttack()
        if not IsFirstTimePredicted() then return end

        local pos,ang = self:GetShootMatrix()
        cmd.pos = pos
        cmd.ang = ang
        cmd.renderTime = GetRenderTime()

        self:DoAction(cmd)
    end

    local Fast = surfaceWorld.Fast.sound.bullet

    function SWEP:HitPrimary(result)
        local surfaceName = surfaceWorld.GetSurfaceName(result.SurfaceProps)

        local hitEntity = result.Entity

        if self:SurfaceIsFlesh(surfaceName,hitEntity) then
            self.hitStartRight = RealTime()
            sound.Emit(result.Entity,"physics/body/body_medium_impact_hard" .. math.random(5,6) .. ".wav",75,1,90,result.HitPos)
        else
            self.hitStartRight = RealTime()
            sound.Emit(result.Entity,"physics/body/body_medium_impact_hard" .. math.random(1,3) .. ".wav",75,1,100,result.HitPos)

            --surfaceWorld.CreateDecalBullet(result.HitPos,result.HitNormal,result.Entity,"flesh")

            local surfaceInfo = Fast[surfaceName]
            if surfaceInfo then sound.Emit(hitEntity,surfaceInfo.list[math.random(1,#surfaceInfo.list)],75,1,surfaceInfo.pitch,result.HitPos) end
        end
    end

    function SWEP:HitSecondary(result)
        local surfaceName = surfaceWorld.GetSurfaceName(result.SurfaceProps)

        local hitEntity = result.Entity

        if self:SurfaceIsFlesh(surfaceName,hitEntity) then
            self.hitStartLeft = RealTime()
            sound.Emit(result.Entity,"physics/body/body_medium_impact_hard" .. math.random(1,3) .. ".wav",75,1,100,result.HitPos)
        else
            self.hitStartLeft = RealTime()
            sound.Emit(result.Entity,"physics/body/body_medium_impact_hard" .. math.random(1,3) .. ".wav",75,1,100,result.HitPos)

            --surfaceWorld.CreateDecalBullet(result.HitPos,result.HitNormal,result.Entity,"flesh")

            local surfaceInfo = Fast[surfaceName]
            if surfaceInfo then sound.Emit(hitEntity,surfaceInfo.list[math.random(1,#surfaceInfo.list)],75,1,surfaceInfo.pitch,result.HitPos) end
        end
    end
end

function SWEP:OnFightBlockThink()
    --[[local owner = self:GetOwner()
    if not self:IsLocal() or not self:GetFightState() or owner:InVehicle() then return end

    if SERVER then
        owner:DropObject()
    else
        if not self:IsCooldown("Block") and not self.sequenceObject then
            local active = not IsValid(GetHUDTarget()) and LocalPlayer():KeyDown(IN_USE)

            if self:GetFightBlockState() != active then
                self:DoAction({name = not self:GetFightBlockState() and "BlockStart" or "BlockEnd"})
            end
        end
    end]]--
end

SWEP:Event_Add("Action","Block",function(self,cmd)
    --[[if not self:GetFightState() or self:GetOwner():InVehicle() or self:IsCooldown("Block") or not self:CanFight(nil,cmd.startTime) then return false end

    if cmd.name == "BlockStart" then
        self:SetFightBlockState(true)
        self.blockState = true
        self:SetCooldown("Block",0.5)

        self:EmitLocalSound("homigrad/player/hand_movement3.wav",75,1,155)

        return true
    elseif cmd.name == "BlockEnd" then
        self:SetFightBlockState(false)
        self.blockState = false
        self:SetCooldown("Block",0.5)

        self:EmitLocalSound("homigrad/player/hand_movement1.wav",75,1,155)

        return true
    end]]--
end)

if CLIENT then
    function SWEP:OnThink()
        self:OnFightBlockThink()
    end
end

if SERVER then
    local function ApplyPunchDamage(self,result,damage)
        local owner = self:GetOwner()
        local target = result.Entity
        if not IsValid(owner) or not IsValid(target) then return end

        local ctrl = target:GetController()
        local entity = IsValid(ctrl) and ctrl or target

        local dmgTab = CreateDamageTab(entity,owner,self,damage,DMG_CLUB)
        dmgTab.isMelee = true
        dmgTab.pos = result.HitPos
        dmgTab.ent = target
        dmgTab.bone = result.HitBone

        local force = owner:GetAimVector() * (damage * 35)
        dmgTab.force = force
        dmgTab.forcePhys = force
        dmgTab.forcePhysRagdoll = force * 10

        DamageTab_ParseBone(dmgTab)

        entity:TakeDamageTab(dmgTab)
    end

    function SWEP:HitPrimary(result)
        ApplyPunchDamage(self,result,12)
    end

    function SWEP:HitSecondary(result)
        ApplyPunchDamage(self,result,9)
    end
end
