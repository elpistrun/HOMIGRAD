inputBuffer = inputBuffer or {}

local metatable = {}

function metatable:Add(id,func,timeout)
    if self.list[id] then return end--ez

    local task = {
        start = RealTime(),
        timeout = timeout or 1,
        func = func,
    }

    self.list[id] = task

    return task
end

function metatable:Think()
    local list = self.list
    local time = RealTime()

    for id,task in pairs(list) do
        if task.start + task.timeout < time then list[id] = nil continue end

        local func = task.func
        list[id] = nil--чтоб не вызывать xpcall
        if func(task) == true then continue end
        list[id] = task
    end
end

metatable.__index = metatable

function inputBuffer.Create()
    local buffer = {
        list = {}
    }

    setmetatable(buffer,metatable)
    
    return buffer
end