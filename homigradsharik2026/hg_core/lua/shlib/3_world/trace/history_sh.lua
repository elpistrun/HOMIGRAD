historyBuffer = historyBuffer or {}

local metatable = {}

function metatable:Add()
    local entry = self.list[self.ptr]
    entry.time = UnPredictedCurTime()
    entry.ptr = self.ptr

    self.ptr = (self.ptr % self.max) + 1

    return entry
end

local abs = math.abs

function metatable:Get(startTime)
    startTime = math.min(startTime,UnPredictedCurTime())

    local ptr,max,list = self.ptr,self.max,self.list

    for i = 1, max do
        local index = (ptr + i - 1) % max + 1

        local entry = list[index]

        if entry.time >= startTime then return entry end
    end

    return list[ptr]
end

function metatable:GetExact(startTime)
    startTime = math.min(startTime,UnPredictedCurTime())

    local bestEntry = nil
    local minDiff = math.huge
    
    for i = 1, self.max do
        local entry = self.list[i]
        if entry.time == 0 then continue end
        
        local diff = abs(entry.time - startTime)

        if diff < minDiff then
            minDiff = diff
            bestEntry = entry
        end
    end
    
    return bestEntry, minDiff
end

function metatable:GetInterpolated(startTime)
    startTime = math.min(startTime,UnPredictedCurTime())

    local ptr, max, list = self.ptr, self.max, self.list
    local prevEntry = nil

    for i = 1, max do
        local index = (ptr + i - 1) % max + 1--идём от самого низкого к самому старшему в
        local entry = list[index]

        if not entry or entry.time == 0 then continue end

        if entry.time > startTime then
            local nextEntry = entry

            if not prevEntry then
                return nextEntry, nextEntry, 0
            end

            if nextEntry.time == prevEntry.time then
                return prevEntry, nextEntry, 0
            end

            local fraction = (startTime - prevEntry.time) / (nextEntry.time - prevEntry.time)

            return prevEntry, nextEntry, fraction
        end

        prevEntry = entry
    end

    return prevEntry, prevEntry, 0
end

metatable.__index = metatable

function historyBuffer.Create(max)
    local history = setmetatable({},metatable)
    history.max = max or (math.ceil(1 / TickInterval()) + 5)
    history.ptr = 1

    local list = {}

    for i = 0,history.max do list[i] = {time = 0} end

    history.list = list

    setmetatable(history,metatable)

    return history
end