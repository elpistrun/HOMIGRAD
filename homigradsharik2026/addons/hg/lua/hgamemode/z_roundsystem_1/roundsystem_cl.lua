if SERVER then return end
net.Receive("roundData",function()
    showRoundInfo = RealTime() + 10
    roundData = net.ReadTable()
    roundTimeStart = net.ReadFloat()
    roundTime = net.ReadFloat()
    LevelCall("Sync",roundData)
end)
net.Receive("roundDataEnd",function()
    showRoundInfo = RealTime() + 10
    roundDataEnd = net.ReadTable()
end)
net.Receive("roundEmit",function()
    showRoundInfo = RealTime() + 10
    system.FlashWindow()
    if roundActive then StartRound() else EndRound() end
end)
function StartRound() RunConsoleCommand("stopsound") event.Run("Start Round") if levelActive and levelActive.Start then levelActive:Start() end end
function EndRound() event.Run("End Round") if levelActive and levelActive.End then levelActive:End() end end