cvars.CreateOption("hg_lua_garbage","1",function(value)
    if tonumber(value or 0) > 0 then
        collectgarbage("setpause",200) -- def 200
        collectgarbage("setstepmul",200) -- def 200
        
        timer.Create("garbagecollector",60,0,function()
            collectgarbage("setpause",200) -- def 200
            collectgarbage("setstepmul",200) -- def 200
        end)
    else
        hook.Remove("Think","GarbageCollectSmooth")

        collectgarbage("setpause",200) -- def 200
        collectgarbage("setstepmul",200) -- def 200
    end
end)

concommand.Add("hg_lua_gc",function()
    local count1 = collectgarbage("count")
    print("Memory: " .. math.floor(count1 / 1024 * 10) / 10 .. ".kByte")
    collectgarbage("collect")
    local count2 = collectgarbage("count")
    print("Memory Free: " .. math.floor((count1 - count2) / 1024 * 10) / 10 .. ".kByte")
    
    print("Memory After: " .. math.floor(count2 / 1024 * 10) / 10 .. ".kByte")
end)

concommand.Add("hg_lua_gc_toggle",function()
    if collectgarbage("isrunning") then
        collectgarbage("stop")
        print("stop")

        GC_STOP = true
    else
        collectgarbage("restart")
        print("start")

        GC_STOP = nil
    end
end)

local allocs = {}

local function StartAllocDebug()
    StartLuaGarbageDev = true

    debug.sethook(function(event)
        local info = debug.getinfo(2, "Sl")
        if not info then return end

        local source = info.short_src .. ":" .. info.currentline
        allocs[source] = (allocs[source] or 0) + 1
    end,"c")
end

local function StopAllocDebug()
    StartLuaGarbageDev = nil

    debug.sethook()

    local list = {}

    for src, count in pairs(allocs) do
        list[#list+1] = {src,count}
    end

    table.sort(list,function(a,b) return a[2] > b[2] end)

    for i = 1,#list do
        local info = list[i]
        
        print(info[2],info[1])
    end
end

concommand.Add("hg_dev_luagarbage",function()
    if not StartLuaGarbageDev then
        StartAllocDebug()
        print("start")
    else
        StopAllocDebug()
        print("stop")
    end
end)

