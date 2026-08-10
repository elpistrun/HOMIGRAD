local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

SWEP.HolsterTime = 0.25
SWEP.DeployTime = 0.5

SWEP.HoldType = "pistol"
SWEP.HoldTypeHolster = "normal"

SWEP:Event_Add("Init","StandType",function(self)
    self:ProxyPVSVar("StandType",function(_,old,new)
        self:SetStandType(new)
    end)

    self:SetStandType("normal")
    
    local passLocal

    self.stateHandling = nil
    self:ProxyPVSVar("HandlingState",function(_,old,new)--try fix state
        if self.stateHandling != new then
            self.stateHandling = new

            if self:IsLocal() then
                passLocal = true
            end
        end
    end)

    self.stateHandlingStart = 0
    self:ProxyPVSVar("HandlingStateStart",function(_,old,new)--try fix state
        if self:IsLocal() then
            if passLocal then self.stateHandlingStart = new end
        else
            self.stateHandlingStart = new
        end
    end)
end)

function SWEP:SetStandType(value)
    self.standType = value

    self:SetupStandType()

    self:SetPVSVar("StandType",value)
end

function SWEP:SetupStandType()
    self:SetWeaponHoldType((not self.standType or self.standType == "") and "normal" or self.standType)
end

--

function SWEP:SetStateHandling(value)
    self.stateHandling = value
    if SERVER then self:SetPVSVar("HandlingState",value) end
end

function SWEP:SetStateHandlingStart(value)
    self.stateHandlingStart = value
    if SERVER then self:SetPVSVar("HandlingStateStart",value) end
end

function SWEP:Deploy(isLua)
    if self.stateHandling == "deploy" then return end
    
    self:HolsterStop()

    self:SetStateHandling("deploy")
    self:SetStateHandlingStart(UnPredictedCurTime() - (SERVER and Ping(self:GetOwner()) or 0))

    if self.HoldType then self:SetStandType(self.HoldType) end

    if self.OnDeploy then self:OnDeploy() end
    self:Event_Call("Deploy",self:GetOwner())
end

function SWEP:DeployEnd()
    if self.stateHandling != "deploy" then return end
    self:SetStateHandling()

    if self.OnDeployEnd then self:OnDeployEnd() end

    self:Event_Call("DeployEnd",self:GetOwner())
end

function SWEP:DeployStop()
    self:SetStateHandling()
end

function SWEP:Holster(isLua)
    if not self:IsLocal() then return end--УЕБАН НА ДВИМЖКЕ БЛЯДЬ
    
    if self.stateHandling == "holster" then return self:TryHolsterSolution() end

    self:DeployStop()
    
    self:SetStateHandling("holster")
    self:SetStateHandlingStart(UnPredictedCurTime() - (SERVER and Ping(self:GetOwner()) or 0))
    self.holsterSolution = false--при попытке убрать оружие возвращаем false

    if self.HoldTypeHolster then self:SetStandType(self.HoldTypeHolster) end

    if self.OnHolster then self:OnHolster() end

    self:Event_Call("Holster",self:GetOwner())

    return self:TryHolsterSolution()
end

function SWEP:HolsterEnd()
    if self.holsterSolution == true or self.stateHandling != "holster" then return end
    self.holsterSolution = true

    if self.OnHolsterEnd then self:OnHolsterEnd() end

    self:Event_Call("HolsterEnd",self:GetOwner())
end

function SWEP:TryHolsterSolution()
    if self.holsterSolution == nil then return end

    if self:CanHolsterEnd() then
        self:HolsterEnd()

        return self.holsterSolution
    else
        return false
    end
end

function SWEP:HolsterStop()
    self:SetStateHandling()
    self.holsterSolution = nil
end

SWEP:Event_Add("Off","Handling",function(self,callType)
    if callType == "hold" then return end
    
    self:DeployStop()
    self:HolsterStop()
end)

function SWEP:CanDeployEnd()
    return self.stateHandling == "deploy" and self.stateHandlingStart + self.DeployTime < CurTime()
end

function SWEP:CanHolsterEnd()
    return self.stateHandling == "holster" and self.stateHandlingStart + self.HolsterTime < CurTime()
end

SWEP:Event_Add("Think","Handling",function(self)
    if self.stateHandling == nil then return end

    if self.stateHandling == "holster" then
        if self:CanHolsterEnd() then
            self:HolsterEnd()
        end
    else
         if self:CanDeployEnd() then
            self:DeployEnd()
        end
    end
end)

function SWEP:GetDeployCycle() return self.stateHandling == "deploy" and math.Clamp((self.stateHandlingStart + self.DeployTime - CurTime()) / self.DeployTime,0,1) or 0 end
function SWEP:GetHolsterCycle() return self.stateHandling == "holster" and math.Clamp((self.stateHandlingStart + self.HolsterTime - CurTime()) / self.HolsterTime,0,1) or 0 end

function SWEP:GetStandAnimK()
    local k = 1

    if self.stateHandling == "deploy" then
        k = self:GetDeployCycle()
    elseif self.stateHandling == "holster" then
        k = 1 - self:GetHolsterCycle()
    end

    return k
end

function SWEP:WeaponIsReady()
    return self:GetHolsterCycle() != 1
end

SWEP:Event_Add("Holster","Snd",function(self,owner)
    self:EmitLocalSound("homigrad/player/holster" .. math.random(1,3) .. ".wav",self:IsGhostWalk() and 45 or 75,0.5,100 + math.random(-1,1))

    if self.HolsterSound then self:EmitLocalSound(self.HolsterSound,self:IsGhostWalk() and 45 or 75,0.5,self.HolsterSoundPitch or 100) end
end)

SWEP:Event_Add("Deploy","Snd",function(self,owner)
    self:EmitLocalSound("homigrad/player/deploy" .. math.random(1,3) .. ".wav",self:IsGhostWalk() and 45 or 75,1,100 + math.random(-1,1))

    if self.DeploySound then self:EmitLocalSound(self.DeploySound,self:IsGhostWalk() and 45 or 75,0.5,self.DeploySoundPitch or 100) end
end)