if CLIENT then
    managerLogBan = ManagerCreate("banLog",{"base_log"})
    adminPanelBan = ManagerCreate("ban",{"node"})

    adminPanelBan.list = adminPanelBan.list or {}

    function adminPanelBan:InputFull(body)
        adminPanelBan.list = JSONToTable(body)

        adminPanelBan:Event_Call("Update")
    end
    
    net.ReceiveMediaToken("ban_message",function(body)
        adminPanelBan.message = body

        adminPanelBan:Event_Call("Update Message")
    end)
end

adminPanel.successRegistry("ban_list",nil,"admin")
adminPanel.commandRegistry("ban_message",{"string"},nil,"project")

local cmd,success = adminPanel.commandRegistry("ban",{
    {type = "steamid64",required = true},
    {type = "string",name = "Время",desc = "Можно указать в конце (h,d,w,m,y) для умножения времени",required = true},
    {type = "string",name = "Причина",required = true}
},"async",nil,"admin")

success.parametrs = {
    {name = "min",type = "string",canParse = function(value)
        if tonumber(value) and tonumber(value) < 0 then return false,"value < 0" end
    end},
    {name = "max",type = "string",canParse = function(value)
        if tonumber(value) and tonumber(value) < 0 then return false,"value < 0" end
    end},
}

adminPanel.commandRegistry("unban",{{type = "steamid64",required = true},{type = "string",required = true}},"async",nil,"admin")
adminPanel.commandRegistry("kick",{{type = "player",required = true},{type = "string",name = "Причина",required = true}},"async",nil,"admin")