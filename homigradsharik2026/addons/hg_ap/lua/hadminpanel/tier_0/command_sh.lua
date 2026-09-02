adminPanel.commands = adminPanel.commands or {}
adminPanel.commandsCategory = adminPanel.commandsCategory or {}

local commands,commandsCategory = adminPanel.commands,adminPanel.commandsCategory

local example = {}

function example:SetArgsType(argsType)
    local list = {}

    for i,argType in pairs(argsType) do
        if TypeID(argType) == TYPE_STRING then
            argType = {
                type = argType,
                desc = ""
            }
        end

        list[i] = argType
    end

    self.argsType = list
end

function example:SetType(value) self.typeCommand = value return self end
function example:SetDesc(value)
    self.desc = value
    commandsCategory[self.category][self.name] = self.desc

    adminPanel.successRegistry("command_" .. self.name,self.desc,self.category)

    return self
end

function example:SetCategory(value)
    if self.category != nil and commandsCategory[self.category] then
        commandsCategory[self.category][self.name] = nil
    end

    self.category = value

    commandsCategory[value] = commandsCategory[value] or {}
    commandsCategory[value][self.name] = self.desc

    adminPanel.successRegistry("command_" .. self.name,self.desc,self.category)

    return self
end

function example:SetDontShowGUI(value) self.dontShowGUI = value return self end

function adminPanel.commandRegistry(cmdName,argsType,typeCommand,desc,category)
    local cmd = commands[cmdName] or {}
    commands[cmdName] = cmd

    cmd.name = cmdName

    for k,v in pairs(example) do cmd[k] = v end

    if argsType then cmd:SetArgsType(argsType) end
    if typeCommand then cmd:SetType(typeCommand) end

    cmd:SetCategory(category or cmd.category or "other")
    cmd:SetDesc(desc or cmd.desc or "no desc")

    local success = adminPanel.successRegistry("command_" .. cmdName,cmd.desc,cmd.category)
    
    return cmd,success
end

function adminPanel.commandCreate(cmdName,func,typeCommand,desc,category)
    local cmd,success = adminPanel.commandRegistry(cmdName,nil,typeCommand,desc,category)
    cmd.func = func

    return cmd,success
end

if SERVER then
    util.AddNetworkString("adminpanel_command")

    local nextCommand = {}

    net.Receive("adminpanel_command",function(_,ply)
        if not IsValid(ply) then return end
        if (nextCommand[ply] or 0) > CurTime() then return end
        nextCommand[ply] = CurTime() + 0.1

        local cmdName = net.ReadString()
        local args = net.ReadTable()
        local cmd = commands[cmdName]

        if #cmdName > 64 or TypeID(args) != TYPE_TABLE or table.Count(args) > 32 then return end
        if not cmd then
            ply:ChatPrint("[HG admin] Неизвестная команда: " .. tostring(cmdName))
            return
        end

        if not ply:HasSuccess("command_" .. cmdName) then
            ply:ChatPrint("[HG admin] Недостаточно прав для команды " .. tostring(cmdName))
            return
        end

        for key,value in pairs(args) do
            if TypeID(key) != TYPE_NUMBER then return end
            local valueType = TypeID(value)
            if valueType == TYPE_TABLE then
                for _,v in pairs(value) do
                    if TypeID(v) != TYPE_STRING and TypeID(v) != TYPE_NUMBER then return end
                end
            elseif valueType != TYPE_STRING and valueType != TYPE_NUMBER and valueType != TYPE_BOOL then return end
            if valueType == TYPE_STRING and #value > 512 then return end
        end

        if cmd.func then
            local success,err = xpcall(cmd.func,debug.traceback,ply,unpack(args))
            if not success then
                ErrorNoHalt("[HG admin] " .. tostring(cmdName) .. ": " .. tostring(err) .. "\n")
                ply:ChatPrint("[HG admin] Ошибка выполнения команды; подробности в серверной консоли.")
            end
            return
        end

        local external = concommand.GetTable()["ulx_cmd"]
        if external then
            local externalArgs = {cmdName}
            for i,value in ipairs(args) do externalArgs[#externalArgs + 1] = tostring(value) end
            external(ply,"ulx_cmd",externalArgs,table.concat(externalArgs," "))
        else
            ply:ChatPrint("[HG admin] Серверный обработчик команды " .. tostring(cmdName) .. " отсутствует.")
        end
    end)

    -- Several legacy hg_ap pages still submit through `ulx_cmd`. This addon
    -- snapshot has no ULX backend, so route it into the same local registry.
    concommand.Add("ulx_cmd",function(ply,_,args)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        if (nextCommand[ply] or 0) > CurTime() then return end
        nextCommand[ply] = CurTime() + 0.1

        local cmdName = tostring(args[1] or "")
        table.remove(args,1)

        local cmd = commands[cmdName]
        if not cmd or not cmd.func then
            ply:ChatPrint("[HG admin] Серверный обработчик команды " .. cmdName .. " отсутствует.")
            return
        end

        if not ply:HasSuccess("command_" .. cmdName) then
            ply:ChatPrint("[HG admin] Недостаточно прав для команды " .. cmdName)
            return
        end

        local success,err = xpcall(cmd.func,debug.traceback,ply,unpack(args))
        if not success then
            ErrorNoHalt("[HG admin] " .. cmdName .. ": " .. tostring(err) .. "\n")
            ply:ChatPrint("[HG admin] Ошибка выполнения; подробности в серверной консоли.")
        end
    end)

    hook.Add("PlayerDisconnected","HG Admin Command Cleanup",function(ply)
        nextCommand[ply] = nil
    end)

    return
end

hook.Add("OnPlayerChat","AdminPanel",function(ply,text)
    if ply != LocalPlayer() or string.sub(text,1,1) != "!" then return end

    local args = adminPanel.GetArgsFromText(string.sub(text,2,#text)," ")
    local cmdName = args[1]
    table.remove(args,1)

    local cmd = commands[cmdName]
    if not cmd then return end

    if not ply:HasSuccess("command_" .. cmdName) then return end

    if cmd.func then
        cmd.func(unpack(args))
    end

    adminPanel.commandSendToServer(cmdName,args)
end)

concommand.Add("ulx",function(cmd,ply,args,line)
    local cmd = commands[args[1]]

    if cmd.func then
        table.remove(args,1)
        cmd.func(unpack(args))
    else
        RunConsoleCommand("ulx_cmd",unpack(args))
    end
end)

function adminPanel.commandSendToServer(cmdName,args)
    local cmd = commands[cmdName]

    if cmd and cmd.func then
        cmd.func(unpack(args))
    else
        net.Start("adminpanel_command")
        net.WriteString(cmdName)
        net.WriteTable(args)
        net.SendToServer()
    end
end
