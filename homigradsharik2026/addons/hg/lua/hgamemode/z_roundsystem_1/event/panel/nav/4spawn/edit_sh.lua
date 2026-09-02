EventGroupEdits = EventGroupEdits or {EventGroupEdits}
EventGroupEditsClient = EventGroupEditsClient or {}

local function addEdit(name,title,func,category,desc)
    EventGroupEdits[name] = func

    EventGroupEditsClient[category] = EventGroupEditsClient[category] or {}
    EventGroupEditsClient[category][name] = {
        title = title,
        desc = desc
    }
end

if SERVER then
    event.Add("Event Group Create","Edit",function(group)
        for name,func in pairs(EventGroupEdits) do group[name] = func(nil) end
    end)

    function EventSpawnEditCMD(cmd,group,groupID,args)
        if EventGroupEdits[cmd] then
            group[cmd] = EventGroupEdits[cmd](args[1])
        end
    end
end

//

addEdit("spawnTime","event_spawn_spawnTime",function(value) return tonumber(value or -1) or -1 end,"event_spawn_category_general")
addEdit("health","event_spawn_health",function(value) return tonumber(value or 100) or 100 end,"event_spawn_category_general")

/*addEdit("mulHungry",function(value) return tonumber(value or 1) or 1 end,"general")
addEdit("mulStamina",function(value) return tonumber(value or 1) or 1 end,"general")

addEdit("stopStamina",function(value) return (tonumber(value or 0) or 0) > 0 end,"general")
addEdit("stopImpulse",function(value) return (tonumber(value or 0) or 0) > 0 end,"general")
addEdit("stopPain",function(value) return (tonumber(value or 0) or 0) > 0 end,"general")
addEdit("stopBleed",function(value) return (tonumber(value or 0) or 0) > 0 end,"general")

addEdit("speed_walk",function(value) return tonumber(value or DEFAULT_SPEED) or DEFAULT_SPEED end,"movement")
addEdit("speed_run",function(value) return tonumber(value or DEFAULT_RUNSPEED) or DEFAULT_RUNSPEED end,"movement")
addEdit("speed_slow",function(value) return tonumber(value or DEFAULT_SLOWWALK) or DEFAULT_SLOWWALK end,"movement")
addEdit("jump_power",function(value) return tonumber(value or DEFAULT_JUMPPOWER) or DEFAULT_JUMPPOWER end,"movement")*/
