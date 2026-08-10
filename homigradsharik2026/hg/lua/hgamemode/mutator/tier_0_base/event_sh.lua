local MUTATOR = Mutator_Get("base")
if not MUTATOR then return end

MUTATOR.EventPlug = {}
MUTATOR.HookPlug = {}

MUTATOR:Event_Add("On","Event",function(self)
    for name,nameFunc in pairs(self.EventPlug) do
        if not nameFunc then continue end
        event.Add(name,"Mutator",function(...) return self[nameFunc](self,...) end)
    end

    for name,nameFunc in pairs(self.HookPlug) do
        if not nameFunc then continue end
        hook.Add(name,"Mutator",function(...) return self[nameFunc](self,...) end)
    end
end,-1)

MUTATOR:Event_Add("Off","Event",function(self)
    for name,nameFunc in pairs(self.EventPlug) do
        if not nameFunc then continue end
        event.Remove(name,"Mutator")
    end

    for name,nameFunc in pairs(self.HookPlug) do
        if not nameFunc then continue end
        hook.Remove(name,"Mutator")
    end
end,1)
