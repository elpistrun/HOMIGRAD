concommand.Add("footkick",function(ply,cmd,args)
    if not ply:Alive() then return end
    if ply:GetStamina() <= 5 then return end

    local pitch = ply:EyeAngles()[1]

    local moveType = 0

    if pitch > 45 then
        moveType = 1
    end

    local anmName = "anm_kick"

    if moveType == 1 then anmName = "anm_kick_down" end
    
    local sequenceObject = ply:PlayAnimation("foot",{name = anmName})
    if not sequenceObject then return end
    sequenceObject:Start()

    RunConsoleCommand("footkick_native",moveType,GetRenderTime(),UnPredictedCurTime())
end)

keyboard.DefaultBindCode("footkick",KEY_B,true)