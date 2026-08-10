garbageTaskSlot = garbageTaskSlot or {}

function GarbageLock(name)
    garbageTaskSlot[name] = true

    collectgarbage("restart")
end

function GarbageFree(name)
    garbageTaskSlot[name] = nil

    local skip = true
    for key in pairs(garbageTaskSlot) do skip = false break end
    
    if skip then collectgarbage("restart") end
end