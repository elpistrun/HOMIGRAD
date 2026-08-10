LOCALIZE = LOCALIZE or {}

local gmod_language = GetConVar("gmod_language")
local l

LanguageDefault = LanguageDefault or "ru"
function GetLanguage() return ForceLanguageGMOD or gmod_language:GetString() end

function updateL(value)
    l = LOCALIZE[value] or LOCALIZE[LanguageDefault] or {}

    local format = string.format
    
    function L(text,arg1,arg2,arg3)
        if not text then return "niltext" end
        
        if l[text] then
            return format(l[text],arg1 or "",arg2 or "",arg3 or "")
        else
            return text .. " " .. (arg1 and " " .. arg1 or "") .. (arg2 and " " .. arg2 or "") .. (arg3 and " " .. arg3 or "")
        end
    end
    function LFast(text) return (l[text] or text) end
end

hook.Add("Initialize","Localize",function()
    updateL(GetLanguage())
end)

updateL(GetLanguage())

cvars.AddChangeCallback("gmod_language",function(_,old,new)
    timer.Simple(0,function() updateL(GetLanguage()) end)
end,"homigrad")

event.Add("Server Status Write","Localize",function(tbl)
    tbl.lang = GetLanguage()//sh_localize
end)