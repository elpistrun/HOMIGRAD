--хочешь так-же? иди нахуй

animationEntity = animationEntity or {}

animationEntity.listClass = animationEntity.listClass or {}
local AnimationList = animationEntity.listClass

function animationEntity.Reg(name,base,isFolder)
    if Initialize then timer.Create("animationEntity.UpdateClass",0,1,function() event.Call("animationEntity.UpdateClass") end) end

    return oop.Reg(name,base,isFolder,0,AnimationList)
end

function animationEntity.RegEx(name,base) return oop.RegEx(name,base,AnimationList) end
function animationEntity.Get(name) return oop.Get(name,AnimationList) end

local hg_dev_animationEntity

if CLIENT then
    cvars.CreateDevOption("hg_dev_animationEntity","0",function(value)
        hg_dev_animationEntity = tonumber(value or 0) > 0
    end,0,1)

    event.Add("animationEntity.PlayAnimationEx","hg_dev_animationEntity",function(self,sequenceData,callType)
        if hg_dev_animationEntity then print("animationEntity.PlayAnimationEx: " .. tostring(self) .. " " .. tostring(sequenceData and sequenceData.name or sequenceData) .. " " .. tostring(callType)) end
    end)

    event.Add("animationEntity.ResetAnimation","hg_dev_animationEntity",function(sequenceData,callType)
        if hg_dev_animationEntity then print("animationEntity.ResetAnimation: " .. tostring(self) .. " " .. tostring(sequenceData and sequenceData.name or sequenceData) .. " " .. tostring(callType)) end
    end)
end

function animationEntity.PlayAnimationEx(self,sequenceData,callType)
    animationEntity.ResetAnimation(self.sequenceObject,callType)

    if not sequenceData then return end
    
    local sequenceName = sequenceData.name
    if not sequenceName then return error("animationEntity.PlayAnimation->" .. tostring(sequenceName) .. "sequenceData is not exists") end--lol

    local sequenceClass = AnimationList[sequenceData.className or sequenceName] or AnimationList.base
    sequenceClass = sequenceClass[1]
    --if not sequenceClass then error("animationEntity.PlayAnimation->" .. tostring(sequenceName) .. " animation not exists") end

    sequenceData.name = sequenceName
    sequenceData.start = sequenceData.start or UnPredictedCurTime()
    sequenceData.parent = self
    
    sequenceData.__index = sequenceClass

    setmetatable(sequenceData,sequenceData)

    event.Call("animationEntity.PlayAnimationEx",self,sequenceData,callType)

    if sequenceClass.OnCreate then sequenceClass:OnCreate() end

    return sequenceData
end

local override = {}

function animationEntity.ResetAnimation(sequenceObject,callType)
    if not sequenceObject then return end

    event.Call("animationEntity.ResetAnimation",sequenceObject,callType)
    
    if not override[sequenceObject] and sequenceObject.Stop then
        override[sequenceObject] = true
        sequenceObject:Stop(callType)
        override[sequenceObject] = nil
    end
end

local Clamp = math.Clamp
local Lerp = Lerp

function animationEntity.GetSequenceCycle(sequenceObject,type)
    if not sequenceObject then return 0 end

    local start = sequenceObject.start
    local delay = (sequenceObject.delay or 1)

    local curTime = UnPredictedCurTime()

    if type == "animation" then
        local cycle = 0

        if sequenceObject.loop then
            cycle = 1 - ((start + delay - curTime) / delay) % 1
        else
            cycle = 1 - Clamp((start + delay - curTime) / delay,0,1)
        end
    
        local startCycle,endCycle = sequenceObject.startCycle or 0,sequenceObject.endCycle or 1

        local inversion = sequenceObject.inversion

        return Lerp(cycle,inversion and endCycle or startCycle,inversion and startCycle or endCycle)
    else
        return 1 - (start + delay - curTime) / delay
    end
end

function animationEntity.GetAnimationMark(sequenceObject,key,timeLine,returnLast,type,inversion)
    if not sequenceObject then return end

    local marks = sequenceObject.marks

    if not marks then
        marks = {}

        sequenceObject.marks = marks
    end

    if timeLine then
        local cycle = animationEntity.GetSequenceCycle(sequenceObject,type)
        if sequenceObject.inversion then inversion = true end--wtf
        
        marks[key] = marks[key] or -1

        local lastResult

        if inversion then cycle = 1 - cycle end

        for timeMark,info in SortedPairs(timeLine) do
            if timeMark > cycle then continue end

            if marks[key] < timeMark then
                marks[key] = timeMark

                lastResult = info
            end
        end

        if lastResult then return lastResult end

        if returnLast then return timeLine[marks[key]] end
    else
        marks[key] = nil
    end
end