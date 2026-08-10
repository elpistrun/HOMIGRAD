local Plugin = EventPlugin_Reg("base",nil,true)
if not Plugin then return INCLUDE_BREAK end

util.tableLink(Plugin,oop.listClass.lib_event[1])

Plugin.ClassName = "base"

function Plugin:Sync(data) end

Plugin:Event_Add("Construct","EventPluginsClasses",function(self)
    if not EventPluginsClasses[self.ClassName] then
        EventPluginsClasses[self.ClassName] = {}
    end

    util.tableLink(EventPluginsClasses[self.ClassName],self[1])
end)

if SERVER then return end

function Plugin:InputData(data)
    if self.enabled ~= data.enabled then
        if data.enabled then
            self:Event_Call("On")
        else
            self:Event_Call("Off")
        end
    end

    self.enabled = data.enabled
    
    self:Sync(data)
end

function Plugin:SendCMD(cmdName,args)
    net.Start("event_plugin_cmd")
    net.WriteString(self.ClassName)
    net.WriteString(cmdName)
    net.WriteTable(args)
    net.SendToServer()
end

net.Receive("event_plugin",function()
    local plugin = EventPluginsClasses[net.ReadString()]

    plugin:InputData(net.ReadTable())
    event.Call("Event Plugin Sync",plugin)
end)
