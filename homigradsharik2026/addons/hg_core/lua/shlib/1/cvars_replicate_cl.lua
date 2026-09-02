cvars.replicates = cvars.replicates or {}

function cvars.SendValue(name,value)
    local ok = pcall(net.Start,"cvars_replicate")
    if not ok then return end

    net.WriteString(name)
    net.WriteString(value)
    pcall(net.SendToServer)
end

function cvars.CreateReplicateOption(name,def,change,min,max,typeRep)
    cvars.replicates[name] = typeRep and 1 or 0

    cvars.CreateOption(name,def,function(value,first)
        if first then return end

        cvars.SendValue(name,value)
    end,min,max)
end

function cvars.CreateServerOption(name,def,change,min,max,typeRep)
    cvars.CreateOption(name,def,change,min,max,SERVER)
end

event.Add("Send Data","cvars_replicate",function()
    for name,typeRep in pairs(cvars.replicates) do
        if typeRep == 1 then continue end

        cvars.SendValue(name,GetConVar(name):GetString())
    end
end)

net.Receive("cvars_replicate",function()
    local cvarName,value = net.ReadString(),net.ReadString()
    
    RunConsoleCommand(cvarName,value)
end)