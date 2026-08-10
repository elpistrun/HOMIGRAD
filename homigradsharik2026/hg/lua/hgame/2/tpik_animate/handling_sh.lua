local SWEP = oop.Get("tpik_animate")
if not SWEP then return end

function SWEP:GetDeployCycle()
    local sequenceInfo,cycle = self:GetSequenceData("start",true)

    return sequenceInfo and sequenceInfo.deploy and cycle or 1
end

function SWEP:GetHolsterCycle()
    local sequenceInfo,cycle = self:GetSequenceData("start",true)

    return sequenceInfo and sequenceInfo.holster and cycle or (self.stateHandling == "holster" and 1 or 0)
end

function SWEP:CanDeployEnd()
    local cycle = self:GetDeployCycle()

    return cycle and cycle >= 1
end

function SWEP:CanHolsterEnd()
    local cycle = self:GetHolsterCycle()

    return cycle and cycle >= 1
end

function SWEP:PlayDeployAnimation()
    self:PlayAnimation({name = "deploy",start = self.stateHandlingStart})
    if SERVER then self:SyncAnimation() end
end

function SWEP:PlayHolsterAnimation()
    self:PlayAnimation({name = "holster",start = self.stateHandlingStart})
    if SERVER then self:SyncAnimation() end
end