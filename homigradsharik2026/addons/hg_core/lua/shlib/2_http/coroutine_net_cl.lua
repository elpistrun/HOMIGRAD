coroutine_net_wait = coroutine_net_wait or {}

function net.CoroutineResume(netName,sessionId,...)
    local threadList = coroutine_net_wait[netName]
    if not threadList then return end

    local thread = threadList[sessionId]
    if not thread then return end

    threadList[sessionId] = nil
    coroutine.resume(thread,...)

    return true
end

local count = 0

function net.CoroutineStart(netName)
    net.Start(netName)

    local thread = coroutine.running()

    coroutine_net_wait[netName] = coroutine_net_wait[netName] or {}
    coroutine_net_wait[netName][count] = thread

    net.WriteInt(count,7)

    count = (count + 1) % 10
end

function net.CoroutineSend(name)
    if not name then error("name is nil or false") end

    net.SendToServer()

    return coroutine.yield()
end

concommand.Add("hg_coroutine_clear_cl",function()
    for k,v in pairs(coroutine_net_wait) do
        print(k,table.Count(v))
        coroutine_net_wait[k] = nil
    end
    print("cleared.")
end)

concommand.Add("hg_coroutine_show",function()
    for k,v in pairs(coroutine_net_wait) do
        for sessionId,thread in pairs(v) do
            print(k,sessionId)
        end
    end
    print("cleared.")
end)

net.ReceiveCoroutine = function(netName)
    net.Receive(netName,function(len)
        net.CoroutineResume(netName,net.ReadInt(7),len)
    end)
end