local Plugin = EventPlugin_Get("base")
if not Plugin then return end

Plugin.EventPlug = {}
Plugin.HookPlug = {}

Plugin:Event_Add("On","Events & Hooks",function(self)
    for name,nameFunc in pairs(self.EventPlug) do
        event.Add(name,"Event Plugin Plug",function(...)
            return self[nameFunc](self,...)
        end,-2)
    end

    for name,nameFunc in pairs(self.HookPlug) do
        hook.Add(name,"Event Plugin Plug",function(...)
            return self[nameFunc](self,...)
        end)
    end
end)

Plugin:Event_Add("Off","Events & Hooks",function(self)
    for name,nameFunc in pairs(self.EventPlug) do
        event.Remove(name,"Event Plugin Plug")
    end

    for name,nameFunc in pairs(self.HookPlug) do
        hook.Remove(name,"Event Plugin Plug")
    end
end)