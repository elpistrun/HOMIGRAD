local err = function(err) ErrorNoHaltWithStack(err) end

local func = function(data)
    local ent = EntityCoroutine(data[1])
    local state = data[2]

    event.Call("PVS Entity State",ent,state)
end

net.ReceiveTick("pvsInclude",function(data)
    coroutine.wrap(function()
        xpcall(func,err,data)
    end)()
end)