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
    
    local bullet = customEnts.Create("bullet_entity")
    bullet.pos = pos:Clone()
    bullet:SetClassBullet(self[typeAttack].Throw)

    bullet:SetDir(Vector(bullet:GetAmmoClassBullet().bulletInfo.Speed,0,0):Rotate(ang))
    bullet.ang = bullet.dir:Angle()

    bullet.attacker = self
    bullet.weapon = self

    bullet.startTime = cmd and cmd.startTime or UnPredictedCurTime()
    bullet.lagCompresion = cmd

    function bullet.AttackEntity(_,traceResult)
        if IsValid(traceResult.Entity) and traceResult.Entity:IsPlayer() then
            FakeDown(traceResult.Entity)
        end
        
        return self:Hit(traceResult,typeAttack)
    end

    local filterEnt = self:GetOwner():GetDummy()
    bullet.filterTrace = {[filterEnt] = true,[self] = true}

    timer.Simple(0.2,function() bullet.filterTrace[filterEnt] = nil end)
    
    bullet.UseNetworkLikeItem = true

    bullet:SetWaitCustomEntityTag(self:EntIndex() .. (cmd and cmd.renderTime or GetRenderTime()))
    
    if SERVER then
        if IsValid(self:GetOwner()) then
            self:GetOwner():DropWeapon(self)
        end

        self:SetSolid(SOLID_NONE)
    end

    bullet:SetServerNetworker(self)
    bullet:Spawn()

    if SERVER then
        bullet:PlayersConnectByPVS()
    end
    
    return true
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

    if (cmd.flag or -1) != -1 then
        if not self:IsSequencePlaying("attack_throw_start") and not self:IsSequencePlaying("attack_throw") then return false,"flag" .. tostring(cmd.flag) .. " " .. tostring(self.sequenceObject and self.sequenceObject.name) end
    elseif self:IsSequencePlaying("attack_throw_start")  then return false,"flag " .. tostring(self.sequenceObject and self.sequenceObject.name) end
end

function action:Start(cmd)
    if cmd.flag == 1 then
        if not self.sequenceObject or self.sequenceObject.name != "attack_throw_start" then return false,"error sequenceObject" end

        self:PlayAnimationAction("attack_throw_stop")
    elseif cmd.flag == 2 then
        self:PlayAnimationAction("attack_throw")
    elseif cmd.flag == 3 then
        self:SetCooldown("attack",1)
        
        self:ResetAnimation()
        self:ThrowMelee(cmd,"Secondary")
    else
        self:PlayAnimationAction("attack_throw_start")
    end

    if SERVER then self:SyncAnimation() end

    return true
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