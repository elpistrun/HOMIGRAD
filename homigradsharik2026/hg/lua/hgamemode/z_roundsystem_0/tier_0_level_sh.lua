Levels = Levels or {}

local xpcall = xpcall
local err = function(err) ErrorNoHaltWithStack(err) end
local empty = {}

function TableLevel(name) return Levels[name or roundActiveName] or empty end

function LevelCall(event,...)
    //local result = level:Event_Call(event,...)
    //if result ~= nil then return result end

    if not levelActive then return end
    
    local func = levelActive[event]
    if func then return xpcall(func,err,levelActive,...) end
end