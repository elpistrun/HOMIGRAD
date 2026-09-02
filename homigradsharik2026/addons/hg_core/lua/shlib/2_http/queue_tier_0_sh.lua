--https://music.youtube.com/watch?v=0DP70eRfqtg&list=RDAMVM0DP70eRfqtg

queueManager = queueManager or {}
queueManager.thread = queueManager.thread or {}
local threadList = queueManager.thread

--

local example = {}

function example:Name() return self.name or "UNKOWN" end

function example:Send(name)
    self:Remove("thread")
    
    local freeId = 0
    
    for i = 1,1024 do
        if not self.thread.list[i] then freeId = i break end
    end

    self.id = freeId
    self.thread.list[freeId] = self

    self.name = name or self.name

    return freeId
end

function example:SendAndPlay()
    self:Send()

    queueManager:DoTask(self)
end

local err = function(err) ErrorNoHaltWithStack(err) end

function example:Remove(callType)
    if not self.id then return end

    table.remove(self.thread.list,self.id)
    self.id = nil
    
    for id,queue in pairs(self.thread.list) do
        queue.id = id
    end

    if self.OnRemove then xpcall(self.OnRemove,err,self,callType) end
end

function example:IsValid()
    return self.id and self.thread.list[self.id] == self
end

function example:GetPrint()
    return string.sub(tostring(self.id) .. string.rep(" ",3),1,4) .. " - " .. (self.wait and (self.isTransaction and "TASK" or "PROCESS") .. " " .. math.floor((RealTime() - self.wait) * 100) / 100 or "WAIT") .. " " .. self:Name()
end

function example:UpdateLife()
    self.wait = RealTime()
end

--

function queueManager:CreateTask(queue,thread)
    queue = queue or {}
    queue.thread = queue.thread or thread

    for k,v in pairs(example) do queue[k] = v end

    queue.stack = debug.traceback()

    if not queue.name then
        queue.name = string.Split(queue.stack,"\n")
        queue.name = queue.name[4] or queue.name[3] or queue.name[2]
    end

    function queue:Error(err)
        self:Remove()
    end

    return queue
end

function queueManager:CreateSimple(queue,thread,func)
    local queue = queueManager:CreateTask(queue,thread)

    queue.timeout = 6

    function queue.Think()
        if func() == false then return end
        queue:Remove("thread")
    end

    queue:Send()

    return queue
end

function queueManager:CreatePromise(queue,thread)
    local promiseTable = {}

    local promise = queueManager:CreateTask(queue,thread)

    function promise.Think(callback)
        local time = RealTime()

        for name,start in pairs(promiseTable) do
            if start + 5 - time <= 0 then
                promiseTable[name] = nil
            else
                return
            end
        end
    end

    function promise:AddPromise(name)
        promiseTable[name] = RealTime()
    end

    function promise:RemovePromise(name)
        promiseTable[name] = nil
    end

    return promise
end

--

function queueManager.thread.Create(name,temporary)
    local thread = threadList[name]

    thread = thread or {
        name = name,
        temporary = temporary
    }

    thread.list = thread.list or {}

    threadList[name] = thread

    function thread:CreateTask(queue) return queueManager:CreateTask(queue,thread) end

    function thread:CreateSimple(func) return queueManager:CreateSimple(nil,thread,func) end
    function thread:CreatePromise() return queueManager:CreatePromise(nil,thread) end

    function thread:Add(queue)
        if not queue then return end
        
        queue:Remove()

        queue.thread = thread

        queue:Send()

        return queue
    end

    function thread:CreateThread(task)
        task = self:Create(task)
        task.isTransaction = true
        task.list = {}

        function task:CreateTask(queue)
            return queueManager:CreateTask(queue,example)
        end

        function task:Add(queue)
            if not self:IsValid() then
                ErrorNoHalt(self:GetPrint() .. " HAS BEEN DELETED\nWANT ADED: " .. (queue and queue:GetPrint() or "NULL"))
            end

            if not queue then return end

            queue:Remove()

            queue.thread = task

            queue:Send()

            return queue
        end

        local oldHas

        function task.Think()
            local has = queueManager:Think(task.list)

            if has then
                task.wait = nil
            end

            if task.PostThink then task:PostThink(has) end
        end

        return task
    end

    function thread:Remove()
        for i,queue in pairs(self.list) do
            queue:Remove()
        end

        threadList[name] = nil
    end

    function thread:CoroutineWrap(func,callbackFailed)
        local queue

        local err = "unkown"
        local errHandler = function(_err)
            ErrorNoHaltWithStack(_err)

            err = _err .. "\n" .. debug.traceback()
        end
        
        local co = coroutine.create(function()
            local success = xpcall(func,errHandler,queue)
            
            if not success then
                if callbackFailed then callbackFailed(err) end

                queue:Error(err)

                return
            end

            queue:Remove("thread")
        end)

        queue = self:CreateTask({
            func = function()
                local success,err = coroutine.resume(co)

                if not success then
                    if callbackFailed then callbackFailed(err) end

                    queue:Error(err)
                end
            end
        })
        
        queue.name = "Coroutine"

        return queue
    end

    return thread,true
end

local TIMEOUT = 5


function queueManager:DoTask(queue)
    local time = RealTime()
    
    if queue.Think then
        local err
        local success = xpcall(queue.Think,function(_err) err = _err end)

        if not success then
            ErrorNoHalt(err .. "\n" .. queue.stack .. "\n")

            queue:Remove()
        end
    end

    if not queue.wait then
        queue.wait = time

        if queue.func then
            local err
            local success = xpcall(queue.func,function(_err) err = _err end)

            if not success then
                ErrorNoHalt(err .. "\n" .. queue.stack .. "\n")

                queue:Remove()
            end
        end
    elseif queue.wait + (queue.timeout or TIMEOUT) - time <= 0 then
        queue:Error("timeout")
    end
end

function queueManager:Think(list)
    local queue = list[1]
    if not queue then return false end

    queueManager:DoTask(queue)

    return queue
end

hook.Add("Think","queueManager",function()
    if ShutDown or string.sub(game.GetIPAddress(),1,7) == "0.0.0.0" then return end

    for name,thread in pairs(threadList) do
        if TypeID(thread) != TYPE_TABLE then continue end
        if thread.can and not thread:can() then continue end

        local has

        if thread.Think then
            has = thread:Think(thread.list)
        else
            has = queueManager:Think(thread.list)
        end

        if thread.temporary and not has then
            threadList[name] = nil
        end
    end
end)

MainThread = queueManager.thread.Create("main")

--

AsyncThread = queueManager.thread.Create("async")

function AsyncThread:Think(list)
    local iteration = 1

    local has = #list > 0

    for i = 1,#list do
        local queue = list[iteration]
        if not queue then break end

        iteration = iteration + 1

        queueManager:DoTask(queue)
    end

    return has
end

if Initialize then
    for name in pairs(threadList) do
        if TypeID(name) != TYPE_TABLE then continue end

        queueManager.thread.Create(name)
    end
end