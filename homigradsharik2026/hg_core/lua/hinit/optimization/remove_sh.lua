function widgets.PlayerTick() end
function player_manager.RunClass() end

if timer.Exists("HostnameThink") then timer.Remove("HostnameThink") end
if timer.Exists("CheckHookTimes") then timer.Remove("CheckHookTimes") end

hook.Remove("PlayerTick","TickWidgets")

gmod.GetGamemode().MouthMoveAnimation = function() end
gmod.GetGamemode().GrabEarAnimation = function() end