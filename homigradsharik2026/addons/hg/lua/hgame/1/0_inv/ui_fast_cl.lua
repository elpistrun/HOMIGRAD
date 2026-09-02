inventoryGame.DelayFast = 0

inventoryGame.QueueFastMove = {}
local QueueFastMove = inventoryGame.QueueFastMove

function inventoryGame.QueueMove(cmd)
    if inventoryGame.DelayFast < RealTime() then inventoryGame.DelayFast = RealTime() + inventoryGame.DelayFastMove end

    QueueFastMove[#QueueFastMove + 1] = cmd

    local slot = cmd[1]

    if #QueueFastMove == 1 and IsValid(slot) then
        slot.wait = RealTime()
    else
        slot.wait = true
    end
end

hook.Add("Think","Inv Queue Move",function()
    local Time = RealTime()
    if inventoryGame.DelayFast >= Time then return end

    for _ = 1,#QueueFastMove do
        local cmd = QueueFastMove[1]
        if not cmd then break end

        table.remove(QueueFastMove,1)

        local slot = cmd[1]
        
        if IsValid(slot) then
            slot.wait = 0
            
            inventoryGame.DelayFast = RealTime() + inventoryGame.DelayFastMove

            inventoryGame.PlaySoundDecay(slot.list[1],"InvMoveSnd",0,-0.2)
            RunConsoleCommand(cmd[2],cmd[3],cmd[4],cmd[5],cmd[6])
        else

        end
        
        local cmdNext = QueueFastMove[1]
        if cmdNext and IsValid(cmdNext[1]) then cmdNext[1].wait = RealTime() end
        
        break
    end
end)