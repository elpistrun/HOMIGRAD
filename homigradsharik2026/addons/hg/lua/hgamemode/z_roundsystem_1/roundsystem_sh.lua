-- Shared roundsystem for event (level_event) - mirrors z_roundsystem_0 tier_0_level_sh
Levels = Levels or {}
level = level or {}
if roundActiveName == nil then roundActiveName = "homicide" roundActiveNameNext = "homicide" end
function TableLevel(name) return Levels[name or roundActiveName] or {} end
function LevelCall(event,...)
    if not levelActive then return end
    local func = levelActive[event]
    if func then return xpcall(func, function(err) ErrorNoHaltWithStack(err) end, levelActive, ...) end
end