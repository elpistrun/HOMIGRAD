if CLIENT then
    local suppressionSound = nil
    local suppressionRadius = 10
   
    local suppressionVolume = CreateClientConVar("suppression_volume", "0.1", true, false, "Set the volume of suppression sound")

    local K = 0
    local addTime = 0

    event.Add("PreCalcView","Supperes",function(ply,view)
        local ang = view.ang

        ang[1] = ang[1] + K * 4
        ang[2] = ang[2] + math.cos(CurTime() * 0.015 + addTime) * K * 2
    end)

    local function PlaySuppressionSound(k)
        k = event.Call("Suppress",k) or k
        if not k then return end

        K = math.max(K,k)
    end

    event.Add("DSP","Suppress",function()
        if K > 0.75 or suppressionSound then return 14,false end
    end)

    local suppressionSoundTime = 0

    local min,max,Rand = math.min,math.max,math.Rand

    hook.Add("RenderScreenspaceEffects","SuppressionEffects",function()
        if not LocalPlayer():Alive() then
            K = 0

            if suppressionSound then
                suppressionSound:Stop()
                suppressionSound = nil
            end

            return
        end

        local time = CurTime()

        if K >= 0.9 then
            if not suppressionSound then
                suppressionSound = CreateSound(LocalPlayer(),"homigrad/earring.mp3")
                suppressionSound:Play()
            end

            suppressionSoundTime = time + Rand(2,3)

            LocalPlayer():SetDSP(31,false)
        else
            if (suppressionSoundTime or 0) < time and suppressionSound then
                suppressionSound:Stop()
                suppressionSound = nil
            end
        end

        if suppressionSound then
            suppressionSound:ChangeVolume(suppressionVolume:GetFloat() * max(suppressionSoundTime - time,0),0.1)

            K = max(K - 1 * FrameTime() / 10,0)
        else
            K = max(K - 1 * FrameTime(),0)
        end

        local k = min(K + max(suppressionSoundTime - time,0) / 3,1)

        DrawColorModify({
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = -0.2 * k,
            ["$pp_colour_contrast"] = 1 + -0.3 * k,
            ["$pp_colour_colour"] = 1,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        })
    
        DrawMotionBlur(0.3,k / 1000,0.01)
    end)

    event.Add("Bullet Crack","CheckSuppression",function(k)
        if not LocalPlayer():Alive() or LocalPlayer():HasGodMode() then return end

        if k < 0.3 then return end

        PlaySuppressionSound(k)

        local angles = Angle()

        angles[1] = angles[1] + math.sin(CurTime() * 0.019 + addTime) * K
        angles[2] = angles[2] + math.cos(CurTime() * 0.019 + addTime) * K

        LocalPlayer():ViewPunch(angles)

        addTime = math.Rand(0,10)
    end,1)
end
