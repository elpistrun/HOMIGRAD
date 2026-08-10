local function SafeIncludeDir(path)
    if IncludeDir then
        local ok,err = pcall(IncludeDir,path)

        if not ok then ErrorNoHalt(path .. "\n" .. tostring(err) .. "\n") end
    end
end

print("\thomigrad start.")
    SafeIncludeDir("hgame/")
print("\thomigrad end")

print("\thomigrad gamemode start.")
    SafeIncludeDir("hgamemode/")
print("\thomigrad gamemode end.")

local Run = function()
    print("\thomigrad init start.")
        SafeIncludeDir("hinit/")
    print("\thomigrad init end.")
end

if event and event.Add then
    event.Add("Initialize","Homigrad Out",Run)
else
    hook.Add("Initialize","Homigrad Out",Run)
end

if Initialize then Run() end