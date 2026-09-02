if CLIENT then
    adminPanelWarn = ManagerCreate("warn",{"node"},DataBase)

    adminPanelWarn.list = adminPanelWarn.list or {}

    function adminPanelWarn:InputFull(body)
        adminPanelWarn.list = {}
        
        for steamid64,info in pairs(JSONToTable(body)) do
            adminPanelWarn.list[steamid64] = info
        end

        adminPanelWarn:Event_Call("Update")
    end
end

adminPanel.successRegistry("warn_list",nil,"rights")

adminPanel.commandRegistry("warn",{{type = "steamid64",required = true},{type = "number",name = "Количество",required = true},{type = "string",name = "Причина",required = true}},"async",nil,"admin")
adminPanel.commandRegistry("unwarn",{{type = "steamid64",required = true},{type = "number",name = "Количество",required = true},{type = "string",name = "Причина",required = true}},"async",nil,"admin")
adminPanel.commandRegistry("clearwarn",{{type = "steamid64",required = true},{type = "string",name = "Причина",required = true}},"async",nil,"admin")
adminPanel.commandRegistry("getwarn",{{type = "steamid64",required = true}},"async",nil,"admin")