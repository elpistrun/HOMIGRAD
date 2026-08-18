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

    adminPanel.commandCreate("noclip",function(ply,targets)
        if not istable(targets) then return end
        for _,steamid64 in ipairs(targets) do
            local target = player.GetBySteamID64(tostring(steamid64))
            if IsValid(target) then
                target:SetMoveType(target:GetMoveType() == MOVETYPE_NOCLIP and MOVETYPE_WALK or MOVETYPE_NOCLIP)
            end
        end
    end,"game",nil,"admin_operator")

    adminPanel.commandCreate("teamforce",function(ply,targets,teamId)
        teamId = tonumber(teamId)
        if not teamId then return end

        if istable(targets) then
            for _,sid in ipairs(targets) do
                local target = player.GetBySteamID64(tostring(sid))
                if IsValid(target) then target:SetTeam(teamId) end
            end
        elseif isstring(targets) then
            local target
            if string.sub(targets,1,6) == "STEAM_" then
                target = player.GetBySteamID(targets)
            else
                target = player.GetBySteamID64(targets)
            end
            if IsValid(target) then target:SetTeam(teamId) end
        end
    end,"game",nil,"admin_operator")

    adminPanel.commandCreate("map",function(ply,mapName)
        if not isstring(mapName) or mapName == "" then return end
        game.ChangeLevel(mapName)
    end)

    -- Map block sync
    util.AddNetworkString("map_block_sync")
    serverBlockedMaps = serverBlockedMaps or {}

    local function SyncBlockedMaps()
        local json = util.TableToJSON(serverBlockedMaps)
        for _,p in ipairs(player.GetAll()) do
            net.Start("map_block_sync")
            net.WriteString(json)
            net.Send(p)
        end
    end

    adminPanel.commandCreate("map_block",function(ply,mapName,block)
        if not isstring(mapName) or mapName == "" then return end
        serverBlockedMaps[mapName] = tobool(block)
        SyncBlockedMaps()
    end)
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

