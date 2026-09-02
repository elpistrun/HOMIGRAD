local SWEP = oop.Get("tpik_animate")
if not SWEP then return end

function SWEP:CanFootKick() return self:GetOwner():IsSprinting() end
function SWEP:IsSprinting() return IsValid(self:GetOwner()) and not self:GetOwner():InFake() and self:GetOwner():GetMoveType() ~= MOVETYPE_NOCLIP and self:GetOwner():IsSprinting() end

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
            -- The marker can arrive one network tick after AnimationThink has
            -- removed the visual sequence. ConstructAnimationAction restores
            -- it server-side before applying the authoritative Load callback.
            if not self.sequenceObject and self.AnimationList and self.AnimationList[cmd.name] then return true end
            if not self.sequenceObject then return false,"sequenceObject is null" end
            if not self.sequenceObject.DoNetLoad then return false,"sequenceObject DoNetLoad is null" end

            return true
        end
    end

    -- Reload actions are animation transitions themselves. Treating chamber as
    -- a normal combat action made the server reject it while the preceding
    -- magazine sequence was still winding down.
    if cmd.name == "chamber" or cmd.name == "chamber_out"
        or cmd.name == "load_magazine" or cmd.name == "load_magazine_chamber"
        or cmd.name == "unload_magazine" or cmd.name == "unload_magazine_empty"
        or cmd.name == "reload_fallback" or cmd.name == "attack_throw" then
        return
    end

    if string.StartWith(tostring(cmd.name),"mr43_reload")
        or string.StartWith(tostring(cmd.name),"pomp_") then return end

    -- A previous shot may still exist for a fraction of a tick on the server.
    -- It must not reject the next shot in automatic or rapid semi-auto fire.
    if cmd.name == "attack" and self.sequenceObject then
        local sequenceName = tostring(self.sequenceObject.name or "")
        if self.sequenceObject.fire or string.StartWith(sequenceName,"fire") then return end
    end
    
    local result,err = self:CanFight(nil,cmd.startTime)
    if not result then return false,"CanFight: " .. tostring(err) end
end,1)

function SWEP:GetSequenceEndCycle(sequenceObject)
    return math.max(sequenceObject.load or 1,sequenceObject.canSkip or 1)
end

function SWEP:CanFightSequence(callType)
    local sequenceObject,cycle = self:GetSequenceData()

    if sequenceObject then
        local sequenceName = tostring(sequenceObject.name or "")

        -- Fire animations are deliberately non-blocking. Check the name too,
        -- because hot-loaded/server instances may not yet carry parsed flags.
        if sequenceObject.fire or string.StartWith(sequenceName,"fire") then return true end
        if callType == "scope" and (sequenceObject.canScope or sequenceObject.fire) then return true end
        if callType == "attack" and sequenceObject.cantAttack then return false end
        if sequenceObject.canFight then return true end

        return sequenceObject:IsEnd()
    end

    return true
end

if SERVER then return end

SWEP:Event_Add("Action","CanFight",function(self,cmd)
    if not self:CanFightGeneral() then return false,"cantFightGeneral" end

    if cmd.sendLoad then return end

    local result,diffTime = self:CanFightSequence(nil,cmd.startTime)
    if not result then return false,"cantFightSequence: " .. tostring(diffTime) end

    local result,diffTime = self:CanAttack(nil,cmd.startTime)
    if not result then return false,"cantAttack: " .. tostring(diffTime) end
end,-1)
