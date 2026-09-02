if CLIENT then
    managerLogGag = ManagerCreate("gagLog",{"base_log"})
    adminPanelGag = ManagerCreate("gag",{"node"})

    adminPanelGag.list = adminPanelGag.list or {}

    function adminPanelGag:InputFull(body)
        adminPanelGag.list = JSONToTable(body)

        adminPanelGag:Event_Call("Update")
    end
end

local cmd,success = adminPanel.commandRegistry("gag",{{type = "steamid64",required = true},{type = "string",name = "Время",required = true},{type = "string",name = "Причина",required = true}},"async",nil,"admin")
success.parametrs = {
    {name = "min",type = "string",canParse = function(value)
        if tonumber(value) and tonumber(value) < 0 then return false,"value < 0" end
    end},
    {name = "max",type = "string",canParse = function(value)
        if tonumber(value) and tonumber(value) < 0 then return false,"value < 0" end
    end},
}

adminPanel.commandRegistry("ungag",{{type = "steamid64",required = true},{type = "string",required = true}},"async",nil,"admin")
