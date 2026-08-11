if UO then return end
UO = true

local function SafeIncludeDir(path)
    if IncludeDir then
        local ok,err = pcall(IncludeDir,path)

        if not ok then ErrorNoHalt(path .. "\n" .. tostring(err) .. "\n") end
    end
end

print("\tshlib start.")
    local ok,err = pcall(include,"shlib/loader.lua")
    if not ok then ErrorNoHalt(tostring(err) .. "\n") end
    SafeIncludeDir("shlib/")
print("\tslib end")

SafeIncludeDir("hlocalize/")

SafeIncludeDir("addons/hg/lua/hlocalize/")

print("\thomigrad admin panel start.")
    SafeIncludeDir("hadminpanel/")
print("\thomigrad admin panel end.")
