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
	
	if roundActive then
		StartRound()
	else
		EndRound()
	end
end)

function StartRound()
	RunConsoleCommand("stopsound")
	
	event.Run("Start Round")
	
    levelActive:Start()
end

function EndRound()
	event.Run("End Round")

    levelActive:End()
end