local hg_dev_animation_player

cvars.CreateDevOption("hg_dev_animation_player","0",function(value)
    hg_dev_animation_player = tonumber(hg_dev_animation or 0) > 0
end)

net.ReceiveTick("animation_player",function(data)
    local slotName = data.slotName

    local ply = Player(data.userid)

    local result = event.Call("CanPlayerSequenceByServer",ply,data)

    if result == false then
        if hg_dev_animation_player then print(ply,"CanPlayerSequenceByServer block anim",data.name) end

        return
    end

    if result != true and hg_dev_animation_player then print(ply,"animation",data.name) end
    
    if data.name then
        local sequenceObject = ply:PlayAnimation(slotName,data,true)

        if sequenceObject.Start then sequenceObject:Start() end
    else
        ply:ResetAnimation(slotName)
    end
end)

event.Add("CanPlayerSequenceByServer","Predication",function(ply)
    if ply == LocalPlayer() then return false end
end)