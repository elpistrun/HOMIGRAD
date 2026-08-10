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

if SERVER then return end

hook.Add("OnPlayerChat","AdminPanel",function(ply,text)
    if ply != LocalPlayer() or string.sub(text,1,1) != "!" then return end

    local args = adminPanel.GetArgsFromText(string.sub(text,2,#text)," ")
    local cmdName = args[1]
    table.remove(args,1)

    local cmd = commands[cmdName]
    if not cmd or not cmd.func then return end

    if not ply:HasSuccess("command_" .. cmdName) then return end

    cmd.func(unpack(args))
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