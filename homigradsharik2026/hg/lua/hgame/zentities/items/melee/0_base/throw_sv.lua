local SWEP = oop.Get("wep_melee_base")
if not SWEP then return end

-- Authoritative server controller for the multi-stage melee throw. The client
-- still starts animations immediately for responsiveness, but losing any
-- follow-up packet can no longer leave the weapon stuck forever.
local function ServerThrowAction(self,flag)
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:GetActiveWeapon() != self then return false end

    local pos,ang = owner:Eye()
    local cmd = {
        name = "attack_throw",
        flag = flag,
        ply = owner,
        pos = pos,
        ang = ang,
        startTime = UnPredictedCurTime(),
        renderTime = UnPredictedCurTime()
    }

    return self:DoAction(cmd)
end

SWEP:Event_Add("Think","Melee Throw Server",function(self)
    if not self.Secondary or not self.Secondary.Throw then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:Alive() or owner:GetActiveWeapon() != self then
        self.throwState = nil
        return
    end

    if self.throwState == "ready" then
        if not owner:KeyDown(IN_ATTACK2) then
            -- RMB released before LMB: cancel and leave the held pose.
            ServerThrowAction(self,1)
        elseif owner:KeyDown(IN_ATTACK) then
            -- RMB + LMB: begin the actual throw animation.
            ServerThrowAction(self,2)
        end
    elseif self.throwState == "throwing" then
        local sequenceObject = self.sequenceObject

        if not sequenceObject or sequenceObject.name != "attack_throw" then
            -- Recover the server animation if only its state survived.
            if self.AnimationList.attack_throw then
                self:PlayAnimationAction("attack_throw")
                self:SyncAnimation()
                sequenceObject = self.sequenceObject
            else
                self.throwState = nil
                return
            end
        end

        local throwCycle = tonumber(sequenceObject.skip) or 0.3
        if sequenceObject:GetCycle() >= throwCycle then
            ServerThrowAction(self,3)
        end
    end
end,-5)

SWEP:Event_Add("Off","Melee Throw Server Reset",function(self)
    self.throwState = nil
end)

SWEP:Event_Add("Remove","Melee Throw Server Reset",function(self)
    self.throwState = nil
end)
