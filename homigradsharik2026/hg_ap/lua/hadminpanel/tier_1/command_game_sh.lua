adminPanel.commandRegistry("help",{{type = "string",name = "Имя команды"}})
adminPanel.commandRegistry("noclip",{"players^"},"game",nil,"admin_operator")
adminPanel.commandRegistry("tp",{"players"},"game",nil,"admin_operator")
adminPanel.commandRegistry("goto",{"players"},"game",nil,"admin_operator")
adminPanel.commandRegistry("bring",{"players"},"game",nil,"admin_operator")
adminPanel.commandRegistry("god",{"players^"},"game",nil,"admin_operator")
adminPanel.commandRegistry("ungod",{"players^"},"game",nil,"admin_operator")
adminPanel.commandRegistry("strip",{"players^"},"game",nil,"admin_operator")

adminPanel.commandRegistry("slay",{"players"},"game",nil,"admin_operator")
adminPanel.commandRegistry("hp",{"players","number"},"game",nil,"admin_operator")

adminPanel.commandRegistry("respawn",{"players^"},"game",nil,"admin_operator")
adminPanel.commandRegistry("setmodel",{"players","string"},"game",nil,"admin_operator")
adminPanel.commandRegistry("give",{"players","string"},"game",nil,"admin_operator")
adminPanel.commandRegistry("setmaterial",{"players","string"},"game",nil,"admin_operator")
adminPanel.commandRegistry("setcolor",{"players","number","number","number"},"game",nil,"admin_operator")
adminPanel.commandRegistry("setactiveweapon",{"players","string"},"game",nil,"admin_operator")
adminPanel.commandRegistry("teamforce",{"players","number"},"game",nil,"admin_operator")

adminPanel.commandRegistry("SuppressEngineLighting",{"bool"},"game")

adminPanel.commandRegistry("bot",{"number"},nil,nil,"rcon")
adminPanel.commandRegistry("botzombie",{"bool"},nil,nil,"rcon")

adminPanel.commandRegistry("setpos",{"number","number","number"},"game")

if SERVER then
    adminPanel.commandCreate("setpos",function(ply,x,y,z)
        ply:SetPos(Vector(x,y,z))
    end,"game")
end

if SERVER then return end

local SuppressEngineLighting

adminPanel.commandCreate("SuppressEngineLighting",function(bool)
    SuppressEngineLighting = bool

    if not bool then
        render.SuppressEngineLighting(false)
        render.SetLightingMode(0)
    end
end)

event.Add("PreRenderScene","SuppressEngineLighting",function()
    if SuppressEngineLighting then
        if vgui.CursorVisible() then
                render.SuppressEngineLighting(false)
                render.SetLightingMode(0)
            return
        end

        render.SuppressEngineLighting(true)
        render.SetLightingMode(1)
    end
end,20)

event.Add("PreRenderHUD","SuppressEngineLighting",function()
    if SuppressEngineLighting then
        render.SuppressEngineLighting(false)
        render.SetLightingMode(0)
    end
end,20)

