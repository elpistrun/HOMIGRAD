outfitManager = ManagerCreate("outfit",{"node","node_network","node_network_user"})

function outfitManager:InputServer()
    local cmd = net.ReadString()

    if cmd == "update" then
        for steamid64,data in pairs(JSONToTable(net.ReadString())) do
            outfitManager.listData[steamid64] = data

            outfitManager:Event_Call("Update",steamid64,data)
        end
    elseif cmd == "error" then
        local steamid64,err = net.ReadString(),net.ReadString()

        outfitManager:Event_Call("Error",steamid64,err)
    end
end