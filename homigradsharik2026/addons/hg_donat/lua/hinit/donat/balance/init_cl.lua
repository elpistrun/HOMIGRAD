balanceManager = ManagerCreate("balance",{"node","node_network","node_network_user"})

function balanceManager:InputFull(body)
    for steamid64,body in pairs(JSONToTable(body)) do
        balanceManager.listData[steamid64] = body

        balanceManager:Event_Call("Update",body)
    end
end

function balanceManager:InputServer()
    local cmd = net.ReadString()
    
    if cmd == "update" then
        local data = net.ReadTable()
        
        for steamid64,body in pairs(data) do
            balanceManager.listData[steamid64] = body

            balanceManager:Event_Call("Update",body)
        end
    end
end