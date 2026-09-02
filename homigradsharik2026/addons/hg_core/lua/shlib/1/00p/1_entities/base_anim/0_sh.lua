local ENT = oop.Reg("base_anim","lib_event",true)
if not ENT then return INCLUDE_BREAK end

ENT.AnimationList = {}

ENT:Event_Add("Construct","Animation",function(class)
    for name,info in pairs(class[1].AnimationList) do info.name = name end
end)

ENT:Event_Add("Construct Object","Animation",function(self,class)
    for name,info in pairs(self.AnimationList) do
        for k in pairs(info) do info[k] = nil end
    end

    for name,info in pairs(class[1].AnimationList) do
        self.AnimationList[info.name] = self.AnimationList[info.name] or {}
        
        for k,v in pairs(info) do self.AnimationList[info.name][k] = v end
    end
end)

ENT:Event_Add("Init","Animation",function(self)
    self:UseClientSideAnimation()
    self.SetAutomaticFrameAdvance = false
end,-10)

function ENT:PlayAnimation(sequenceObject,callType)
    if not sequenceObject then error(tostring(self) .. ":PlayAnimation(sequenceObject == null)") end

    if TypeID(sequenceObject) == TYPE_STRING then sequenceObject = {name = sequenceObject} end
    
    local oldSequenceObject = self.sequenceObject

    self:Event_Call("PreSequenceStart",sequenceObject,oldSequenceObject,callType)
    
    local sequenceEntityData = self.AnimationList[sequenceObject.name]
    if not sequenceEntityData then error(tostring(self) .. ".AnimationList[" .. tostring(sequenceObject.name) .. "] == null") end

    util.tableLink(sequenceObject,sequenceEntityData)

    -- Visual-only sequences reuse model indices/sounds/graphs but must not run
    -- gameplay callbacks belonging to inventory reload actions.
    if sequenceObject.visualOnly then
        sequenceObject.className = "base"
        sequenceObject.Start = nil
        sequenceObject.Think = nil
        sequenceObject.Step = nil
        sequenceObject.Load = nil
        sequenceObject.Skip = nil
        sequenceObject.Stop = nil
        sequenceObject.SendLoad = nil
        sequenceObject.DoNetLoad = nil
        sequenceObject.NetData = nil
    end

    animationEntity.PlayAnimationEx(self,sequenceObject,callType)

    self.sequenceObject = sequenceObject
    
    if sequenceObject.Start then sequenceObject:Start() end

    self:Event_Call("SequenceStart",sequenceObject,oldSequenceObject,callType)

    return sequenceObject
end

ENT:Event_Add("Off","Animation",function(self) self:ResetAnimation() end)

function ENT:ResetAnimation(callType)
    local sequenceObject = self.sequenceObject
    self.sequenceObject = nil

    self:Event_Call("PreResetSequence",sequenceObject,callType)
    
    animationEntity.ResetAnimation(sequenceObject,callType)
    
    self:Event_Call("ResetSequence",sequenceObject,callType)
end

function ENT:OnGetSequenceIndex(sequenceInfo) end

function ENT:GetSequenceIndex(sequenceObject,...)
    local index,cycle = self:OnGetSequenceIndex(sequenceObject,...)
    if index then return index,cycle end

    if not sequenceObject then
        local index,cycle = self:GetSequenceIdleIndex()

        return index,(cycle or 1)
    else
        if sequenceObject.GetIndex then
            return sequenceObject:GetIndex()
        else
            return sequenceObject.index,sequenceObject:GetCycle("animation")
        end
    end
end

ENT.IdleSequenceIndex = 0

function ENT:GetSequenceIdleIndex() return self.IdleSequenceIndex end

function ENT:GetSequenceData()
    local sequenceObject = self.sequenceObject
    if not sequenceObject then return nil,0 end

    return sequenceObject,sequenceObject:GetCycle()
end

function ENT:IsSequencePlaying(name)
    local sequenceObject = self.sequenceObject
    if not sequenceObject or sequenceObject.name != name then return false end

    return sequenceObject:GetCycle()
end

function ENT:AnimationEmitSound(info)
    local entIndex = self:EntIndex()
    local owner = self:GetOwner()

    if IsValid(owner) then
        entIndex = owner:EntIndex()
    end

    local pos = self:GetPos()

    if SERVER then
        local filter = RecipientFilter()
        filter:AddAllPlayers()
        filter:RemovePVS(pos)

        for i,sndInfo in pairs(info) do
            sound.EmitNET(entIndex,TypeID(sndInfo[1]) == TYPE_TABLE and sndInfo[1][math.random(1,#sndInfo[1])] or sndInfo[1],sndInfo[2] or 75,sndInfo[3] or 1,sndInfo[4] or 100,pos)
            net.Send(filter)
        end
    else
        for i,sndInfo in pairs(info) do
            sound.Emit(entIndex,TypeID(sndInfo[1]) == TYPE_TABLE and sndInfo[1][math.random(1,#sndInfo[1])] or sndInfo[1],sndInfo[2] or 75,sndInfo[3] or 1,sndInfo[4] or 100,pos)
        end
    end
end

function ENT:AnimationThink()
    local sequenceObject,cycle = self:GetSequenceData()
    if not sequenceObject then return end

    local info = sequenceObject:GetMarkEmit("sound")
    if info then self:AnimationEmitSound(info) end

    if sequenceObject.Think then sequenceObject:Think(cycle) end

    local sequenceObject,cycle = self:GetSequenceData()--вдруг мы сменили анимацию в sequenceObject.Think
    if not sequenceObject then return end

    if sequenceObject and not sequenceObject.endless and cycle >=1 then
        self:ResetAnimation()
    end
end
