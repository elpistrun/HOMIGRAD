local INV = oop.Get("inv_base")
if not INV then return end

INV:Event_Add("Create","Queue",function(self)
    self.queueCommand = {}
end)

function INV:GetPlayerThread()
    return queueManager.thread.Create("inv",true)
end

function INV:SendCommand(func,funcFailed,ply,delay)
    local thread = self:GetPlayerThread(ply)

    local queue = thread:CoroutineWrap(function(queue)
        if not IsValid(self) then if funcFailed then funcFailed() end return end

        func()
    end)

    queue.funcFailed = funcFailed
    queue:Send("Move")

    self.queueCommand[queue] = true

    queue.OnRemove = function(_,callType)
        self.queueCommand[queue] = nil

        if callType != "thread" and funcFailed then funcFailed() end
    end
end

INV:Event_Add("Remove","Queue",function(self)
    for queue in pairs(self.queueCommand) do
        if queue.funcFailed then queue.funcFailed() end
        queue:Remove()
    end

    for inv,panel in pairs(inventoryGame.panels) do
        if inv.queueCommand then
            for queue in pairs(inv.queueCommand) do
                queue:Remove()
            end
        end
    end
end)