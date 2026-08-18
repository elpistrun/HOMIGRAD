local swepGetProcessedValue = SWEP.GetProcessedValue

function SWEP:ThinkCycle()
    if !swepGetProcessedValue(self, "ManualAction", true) or self:StillWaiting() then return end

    local swepDt = self.dt

    local ct = CurTime()

    if swepDt.NeedsCycle and swepDt.CycleFinishTime != 0 and swepDt.CycleFinishTime <= ct then
        self:SetNeedsCycle(false)
        self:SetCycleFinishTime(0)
    end

    local owner = self:GetOwner()

    -- local manual = self:ShouldManualCycle()
    local manual = owner:GetInfoNum("arc9_manualbolt", 0) >= 1

    local cycling = manual and owner:KeyDown(IN_RELOAD) or !owner:KeyDown(IN_ATTACK)

    if swepDt.NeedsCycle and (cycling or swepGetProcessedValue(self, "SlamFire", true)) then
        local iftp = IsFirstTimePredicted()

        if self.MalfunctionCycle and (iftp and self:RollJam()) then return end

        local ejectdelay = swepGetProcessedValue(self, "EjectDelay", true)

        local t = self:PlayAnimation("cycle", swepGetProcessedValue(self, "CycleTime", true), false)

        t = t * ((self:GetAnimationEntry(self:TranslateAnimation("cycle")) or {}).MinProgress or 1)

        self:SetCycleFinishTime(ct + t)

        if iftp and !swepGetProcessedValue(self, "NoShellEjectManualAction", true) then
            if ejectdelay == 0 then
                self:DoEject()
            else
                self:SetTimer(ejectdelay, function() self:DoEject() end)
            end
        end
    end
end

function SWEP:ShouldManualCycle()
    return self:GetOwner():GetInfoNum("arc9_manualbolt", 0) >= 1
end