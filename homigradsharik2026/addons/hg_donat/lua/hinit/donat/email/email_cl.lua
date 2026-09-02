emailManager = ManagerCreate("email",{"node","node_network","node_network_user"})

function emailManager:InputFull(body)
    for steamid64,info in pairs(JSONToTable(body)) do
        emailManager.listData[steamid64] = info

        emailManager:Event_Call("Update",info)
    end
end

function emailManager:InputServer()
    local cmd = net.ReadString()
    
    if cmd == "update" then
        local info = JSONToTable(net.ReadString())

        if not emailManager.listData[info.steamid64] then
            emailManager.listData[info.steamid64] = {}
        end

        emailManager.listData[info.steamid64][info.id] = info

        emailManager:Event_Call("Update",info)
    elseif cmd == "delete" then
        local steamid64,id = net.ReadString(),net.ReadString()
        if not emailManager.listData[steamid64] then return end
        
        emailManager.listData[steamid64][id] = nil

        emailManager:Event_Call("Remove",steamid64,id)
    end
end