net.ReceiversTick = net.ReceiversTick or {}

function net.ReceiveTick(name,func)
    net.ReceiversTick[name] = func
end

net.Receive("tickNet",function(len)
    local bytesCount = net.ReadUInt(16)
    local data = net.ReadData(bytesCount)
    data = util.JSONToTable(util.Decompress(data),true,true)

    --local data = net.ReadTable()

    for i = 1,#data do
        local pkg = data[i]
        
        local func = net.ReceiversTick[pkg[1]]
        if not func then ErrorNoHalt("net.ReceiversTick[" .. tostring(pkg[1]) .. "] is not exists\n") continue end
        
        func(pkg[2])
    end
end)