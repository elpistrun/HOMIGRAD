local SWEP = oop.Get("tpik_animate")
if not SWEP then return end

function SWEP:CanFootKick() return self:GetOwner():IsSprinting() end
function SWEP:IsSprinting() return IsValid(self:GetOwner()) and not self:GetOwner():InFake() and self:GetOwner():IsSprinting() end

function SWEP:CanAttack() return true end

function SWEP:CanFightGeneral(callType,startTime)
    if self:GetOwner():InFakeDeath() then return false,"Owner InFakeDeath" end
    if callType == "scope" and self:IsSprinting() then return false end
    if not self:CanAttack() then return false,"cantAttack" end

    return true
end

function SWEP:CanFight(callType,startTime)
    local success,err = self:CanFightGeneral(callType)

    if not success then return false,err or "fightGeneral" end 

    local result,err = self:CanFightSequence(callType,startTime)
    if result == false then return false,err or "sequence" end

    return true
end

SWEP:Event_Add("PreAction","Fight",function(self,cmd)
    if cmd.sendLoad then
        if CLIENT then
            return true
        else
            if not self.sequenceObject then return false,"sequenceObject is null" end
            if not self.sequenceObject.DoNetLoad then return false,"sequenceObject DoNetLoad is null" end

            return true
        end
    end
    
    local result,err = self:CanFight(nil,cmd.startTime)
    if not result then return false,"CanFight: " .. tostring(err) end
end,1)

if SERVER then return end

function SWEP:GetSequenceEndCycle(sequenceObject)
    return math.max(sequenceObject.load or 1,sequenceObject.canSkip or 1)
end

function SWEP:CanFightSequence(callType)
    local sequenceObject,cycle = self:GetSequenceData()

    if sequenceObject then
        if callType == "scope" and sequenceObject.canScope then return true end
        if callType == "attack" and sequenceObject.cantAttack then return false end
        if sequenceObject.canFight then return true end

        return sequenceObject:IsEnd()
    end

    return true
end

SWEP:Event_Add("Action","CanFight",function(self,cmd)
    if not self:CanFightGeneral() then return false,"cantFightGeneral" end

    if cmd.sendLoad then return end

    local result,diffTime = self:CanFightSequence(nil,cmd.startTime)
    if not result then return false,"cantFightSequence: " .. tostring(diffTime) end

    local result,diffTime = self:CanAttack(nil,cmd.startTime)
    if not result then return false,"cantAttack: " .. tostring(diffTime) end
end,-1)