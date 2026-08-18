local SWEP = oop.Get("wep_melee_base")
if not SWEP then return end

function SWEP:ThrowMelee(cmd,typeAttack)
    local pos,ang
    
    if cmd and cmd.pos then
        pos,ang = cmd.pos,cmd.ang    
    else
        pos,ang = self:GetShootMatrix()
    end
    
    pos:Add(self.ThrowOffset:Clone():Rotate(ang))
    
    local throwSpeed = 1200
    local throwDir = Vector(throwSpeed,0,0):Rotate(ang)
    
    -- Create the damage projectile (invisible, handles hit detection)
    local bullet = customEnts.Create("bullet_entity")
    bullet.pos = pos:Clone()
    bullet:SetClassBullet(self[typeAttack].Throw)

    bullet:SetDir(throwDir:Clone())
    bullet.ang = bullet.dir:Angle()

    bullet.attacker = self
    bullet.weapon = self

    bullet.startTime = cmd and cmd.startTime or UnPredictedCurTime()
    bullet.lagCompresion = cmd

    function bullet.AttackEntity(_,traceResult)
        if IsValid(traceResult.Entity) and traceResult.Entity:IsPlayer() then
            FakeDown(traceResult.Entity)
        end
        
        local dmgResult = self:Hit(traceResult,typeAttack)
        
        -- Stick the weapon in the surface on the server
        if SERVER and IsValid(self) then
            self:StickInWall(traceResult)
        end
        
        return dmgResult
    end

    local filterEnt = self:GetOwner():GetDummy()
    bullet.filterTrace = {[filterEnt] = true,[self] = true}

    timer.Simple(0.2,function() bullet.filterTrace[filterEnt] = nil end)
    
    bullet.UseNetworkLikeItem = true

    if CLIENT and bullet.SetWaitCustomEntityTag then
        bullet:SetWaitCustomEntityTag(self:EntIndex() .. (cmd and cmd.renderTime or GetRenderTime()))
    end
    
    if SERVER then
        local owner = self:GetOwner()
        if IsValid(owner) then
            owner:DropWeapon(self)
        end

        -- Make the weapon entity physical and throw it
        self:SetSolid(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetNoDraw(false)
        self:SetNotSolid(false)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:SetVelocity(throwDir)
            phys:AddAngleVelocity(VectorRand() * 200)
        end
        
        self:SetOwner(owner)
        
        -- Start a think hook to stick the weapon when the bullet hits
        self.throwStuck = false
        self:Event_Add("Think","Throw Stick Check",function(self)
            if self.throwStuck then return end
            
            -- Check if the bullet has already hit something
            if not IsValid(bullet) then
                -- Bullet is gone, stick the weapon at its current position
                local phys = self:GetPhysicsObject()
                if IsValid(phys) then
                    phys:SetVelocity(Vector(0,0,0))
                    phys:SetAngleVelocity(Vector(0,0,0))
                    phys:Sleep()
                end
                self.throwStuck = true
                self:Event_Remove("Think","Throw Stick Check")
            end
        end,-5)
        
        -- Safety timeout: stick the weapon after 3 seconds regardless
        timer.Simple(3,function()
            if not IsValid(self) or self.throwStuck then return end
            local phys = self:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(Vector(0,0,0))
                phys:SetAngleVelocity(Vector(0,0,0))
                phys:Sleep()
            end
            self.throwStuck = true
            self:Event_Remove("Think","Throw Stick Check")
        end)
    end

    if CLIENT and bullet.SetServerNetworker then bullet:SetServerNetworker(self) end
    bullet:Spawn()

    if SERVER and bullet.PlayersConnectByPVS then
        bullet:PlayersConnectByPVS()
    end
    
    return true
end

function SWEP:StickInWall(traceResult)
    if not traceResult or not traceResult.Hit then return end
    
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return end
    
    -- Stop all movement
    phys:SetVelocity(Vector(0,0,0))
    phys:SetAngleVelocity(Vector(0,0,0))
    
    -- Position the weapon at the hit point, oriented along the hit normal
    local hitPos = traceResult.HitPos
    local hitNormal = traceResult.HitNormal
    
    -- Orient the weapon pointing into the surface
    local up = hitNormal
    local fwd = -hitNormal
    local right = fwd:Cross(Vector(0,0,1))
    if right:LengthSqr() < 0.01 then
        right = fwd:Cross(Vector(1,0,0))
    end
    right:Normalize()
    local newUp = right:Cross(fwd)
    
    local ang = Angle(0,0,0)
    ang:SetVectors(fwd,right,newUp)
    
    -- Push the weapon slightly into the surface
    local stickPos = hitPos + hitNormal * 2
    
    self:SetPos(stickPos)
    self:SetAngles(ang)
    
    phys:Sleep()
    self.throwStuck = true
    self:Event_Remove("Think","Throw Stick Check")
end

if SERVER then
    timer.Create("standtestmelee",1,0,function()
        --[[local wep = ents.Create("wep_melee_voodoo")
        wep:SetPos(Vector(41.464176, -128.178558, 200))
        wep:Spawn()
        wep:ThrowMelee({pos = Vector(332.607269 ,-107.286987, 272.304382),ang = Angle(),renderTime = UnPredictedCurTime(),startTime = UnPredictedCurTime()},"Secondary")]]--
    end)
end

SWEP.ThrowOffset = Vector()

local action = SWEP:CreateAction("attack_throw")

function action:netWrite(cmd)
    net.WriteInt(cmd.flag or -1,3)

    local pos,ang = self:GetOwner():Eye()

    pos:Add(self.ThrowOffset:Clone():Rotate(ang))

    net.WriteEyeAttack(pos,ang)

    net.WriteDouble(GetRenderTime())
end

function action:netRead(cmd)
    cmd.flag = net.ReadInt(3)

    local pos,ang = self:GetOwner():Eye()

    pos:Add(self.ThrowOffset:Clone():Rotate(ang))

    pos,ang = net.ReadEyeAttack(pos,ang)
    
    cmd.pos = pos
    cmd.ang = ang

    cmd.renderTime = net.ReadDouble()
end

function action:CanStart(cmd)
    if not self.Secondary.Throw then return false,"cant use throw" end

    local flag = cmd.flag or -1
    if flag == -1 then
        if self.throwState then return false,"throw already active" end
    elseif flag == 2 then
        if self.throwState != "ready" and not self:IsSequencePlaying("attack_throw_start") then return false,"throw is not ready" end
    elseif flag == 3 then
        if self.throwState != "throwing" and not self:IsSequencePlaying("attack_throw") then return false,"throw animation is not active" end
    elseif flag != 1 then
        return false,"unknown throw flag"
    end
end

function action:Start(cmd)
    if cmd.flag == 1 then
        self.throwState = nil
        if self.AnimationList.attack_throw_stop then
            self:PlayAnimationAction("attack_throw_stop")
        else
            self:ResetAnimation("throw_cancel")
        end
    elseif cmd.flag == 2 then
        self.throwState = "throwing"
        self:PlayAnimationAction("attack_throw")
    elseif cmd.flag == 3 then
        self.throwState = nil
        self:SetCooldown("attack",1)
        
        self:ResetAnimation()
        self:ThrowMelee(cmd,"Secondary")
    else
        self.throwState = "ready"
        self:PlayAnimationAction("attack_throw_start")
    end

    if SERVER then self:SyncAnimation() end

    return true
end

function action.Error(self)
    self.throwState = nil
    self:ResetAnimation("throw_server_rejected")
end

SWEP:WaitConstructAnimation("attack_throw_start",function(_,anm)
    anm.Think = function(object)
        if not object.isLocal then return end

        local self = object.parent

        if CLIENT then
            if LocalPlayer():KeyDown(IN_ATTACK) then self:DoAction({name = "attack_throw",flag = 2}) return end--DoAction будет возвращать false потому-что анимация не закончена 
            if not LocalPlayer():KeyDown(IN_ATTACK2) then self:DoAction({name = "attack_throw",flag = 1}) return end
        end
    end
end)

SWEP:WaitConstructAnimation("attack_throw",function(_,anm)
    anm.Think = function(object)
        if not object.isLocal then return end

        if CLIENT and object:GetCycle() > object.skip then
            object.parent:DoAction({name = "attack_throw",flag = 3})
        end
    end
end)
