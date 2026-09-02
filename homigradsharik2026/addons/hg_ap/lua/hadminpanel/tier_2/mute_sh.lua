if CLIENT then
    managerLogMute = ManagerCreate("muteLog",{"base_log"})
    adminPanelMute = ManagerCreate("mute",{"node"})

    adminPanelMute.list = adminPanelMute.list or {}

    function adminPanelMute:InputFull(body)
        adminPanelMute.list = JSONToTable(body)

        adminPanelMute:Event_Call("Update")
    end
end

local cmd,success = adminPanel.commandRegistry("mute",{
    {type = "steamid64",required = true},
    {type = "string",name = "Время",required = true},
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

adminPanel.commandRegistry("unmute",{{type = "steamid64",required = true},{type = "string",required = true}},"async",nil,"admin")
