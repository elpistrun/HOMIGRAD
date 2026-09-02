if UO then return end
UO = true

HG_ERRLOG = HG_ERRLOG or { list = {}, sync = {} }
if not HG_ERRLOG.Add then
    function HG_ERRLOG:Add(cat,path,text,realm)
        path = tostring(path or "")
        text = tostring(text or "")
        realm = realm or (SERVER and "SV" or "CL")

        for i = 1,#self.list do
            local entry = self.list[i]
            if entry.cat == cat and entry.path == path and entry.text == text then
                entry.count = (entry.count or 1) + 1
                entry.time = os.time()
                return entry
            end
        end

        local entry = { cat = cat, path = path, text = text, realm = realm, time = os.time(), count = 1 }
        self.list[#self.list + 1] = entry
        if #self.list > 500 then table.remove(self.list,1) end
        return entry
    end
end

local function SafeIncludeDir(path)
    if IncludeDir then
        local ok,err = pcall(IncludeDir,path)

        if not ok then
            ErrorNoHalt(path .. "\n" .. tostring(err) .. "\n")
            if HG_ERRLOG and HG_ERRLOG.Add then HG_ERRLOG:Add("autorun",path,err) end
        end
    end
end

print("\tshlib start.")
    local ok,err = pcall(include,"shlib/loader.lua")
    if not ok then
        ErrorNoHalt(tostring(err) .. "\n")
        if HG_ERRLOG and HG_ERRLOG.Add then HG_ERRLOG:Add("autorun","shlib/loader.lua",err) end
    end
    SafeIncludeDir("shlib/")
print("\tslib end")

SafeIncludeDir("hlocalize/")

SafeIncludeDir("addons/hg/lua/hlocalize/")

print("\thomigrad admin panel start.")
    SafeIncludeDir("hadminpanel/")
print("\thomigrad admin panel end.")
