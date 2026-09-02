local MANAGER = ManagerRegistry("notification",{"node","node_network","node_network_user"})
if not MANAGER then return end

function MANAGER:Read(list)
    if #list == 0 then return end
    
    self:NetUserRequest(list)
end

function MANAGER:InputFull(body)
    local data = JSONToTable(body)
    local list = {}

    for _,content in pairs(data) do
        local success = self:Event_Call("Get",content)

        if content.id != 0 and (success == true or success ~= nil) then
            list[#list + 1] = content.id
        end
    end
end

function MANAGER:InputServer()
    manager:Event_Call("Get",tonumber(net.ReadString()),net.ReadTable())
end