keyboard = keyboard or {}

keyboard.settings = keyboard.settings or {}
local settings = keyboard.settings

keyboard.settingsData = JSONToTable(file.Read("homigrad/keyboard2.txt") or "") or {}
local settingsData = keyboard.settingsData
PrintTable(settingsData)

local settingsDefault = {}
keyboard.settingsDefault = settingsDefault

function keyboard.Save()
    for k in pairs(settingsData) do settingsData[k] = nil end

    for name,info in pairs(keyboard.settings) do
        settingsData[name] = {
            code = info.code
        }
    end

    file.Write("homigrad/keyboard2.txt",util.TableToJSON(settingsData))
end

function keyboard.GetBindCode(name)
    return settings[name] and settings[name].code
end

function keyboard.DefaultBindCode(name,code,instant,canFunc)
    settingsDefault[name] = {
        code = code,
        instant = instant,
        canFunc = canFunc
    }

    settings[name] = settings[name] or {}
    util.tableLink(settings[name],settingsDefault[name])
    util.tableLink(settings[name],settingsData[name] or {})
end

local oldActive = {}

hook.Add("CreateMove","HG_BIND",function()
    if gui.IsGameUIVisible() or IsValid(vgui.GetKeyboardFocus()) then return end

    for name,info in pairs(settings) do
        local old = oldActive[name] or false

        local active = input.IsKeyDown(info.code)

        if old ~= active then
            oldActive[name] = active

            if info.canFunc and not info.canFunc() then continue end
                
            if info.instant then
                if active then RunConsoleCommand(name) end--LOOOOOOOOOL EZ
            else
                RunConsoleCommand((active and "+" or "-") .. name)
            end
        end
    end
end)

concommand.Add("hg_bind",function(ply,cmd,args)
    local name,code = tostring(args[1]),tonumber(args[2])
    if not name then return end

    if not code or code <= 0 then
        settings[name].code = nil
        util.tableLink(settings[name],settingsDefault[name])
    else
        settings[name].code = code
    end

    keyboard.Save()
end)

concommand.Add("hg_bind_get",function(ply,cmd,args)
    PrintTable(settings)
end)

hook.Add("Initialize","keyboard.Save()",function()
    keyboard.Save()
end)