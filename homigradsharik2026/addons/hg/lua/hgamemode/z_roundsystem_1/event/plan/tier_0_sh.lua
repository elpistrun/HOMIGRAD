if CLIENT then
    eventManager = ManagerCreate("eventManager",{"node"})
    
    function eventManager:InputFull(body)
        eventManager.listData = JSONToTable(body)

        eventManager:Event_Call("Update")
    end
end

adminPanel.commandRegistry("discord_event",{{type = "string",name = "ChannelId"},{type = "string",name = "roleId"}},"async",nil,"project")