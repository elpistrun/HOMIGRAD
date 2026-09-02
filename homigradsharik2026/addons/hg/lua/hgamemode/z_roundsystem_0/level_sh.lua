Levels = Levels or {}

local empty = {}

function TableLevel(name) return Levels[name or roundActiveName] or empty end

if roundActiveName == nil then
    roundActiveName = "homicide"
    roundActiveNameNext = "homicide"
end

level = level or {}

function level.HookCall(nameLevelFunc,...)
    if levelActive[nameLevelFunc] then return levelActive[nameLevelFunc](levelActive,...) end
end
