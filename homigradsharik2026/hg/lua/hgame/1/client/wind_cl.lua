local k = 0

event.Add("Wind","Main",function(tbl)
    local ent = LocalPlayer():GetDummy()

    if not LocalPlayer():Alive() or (ent == LocalPlayer() and LocalPlayer():GetNoDraw()) then
        return false
    end
end,-100)

hook.Add("Think","Wind",function()
    local ent = LocalPlayer():GetDummy()

    if not WindSound then
        WindSound = CreateSound(LocalPlayer(),"homigrad/wind/woosh0.wav")
    end

    if not WindSound2 then
        WindSound2 = CreateSound(LocalPlayer(),"homigrad/wind/woosh1.wav")
    end

    k = math.min(ent:GetVelocity():Length() / (ent ~= LocalPlayer() and 1750 or 3000),1)
    k = math.max(k - 0.2,0) / 0.8

    local tbl = {
        [1] = k,
        dsp = 0
    }

    if event.Call("Wind",tbl) == false then
        k = 0

        if WindSound:IsPlaying() then WindSound:ChangeVolume(0,0.05) end
        if WindSound2:IsPlaying() then WindSound2:ChangeVolume(0,0.05) end

        return
    end 

    WindSound:SetDSP(tbl.dsp)
    WindSound2:SetDSP(tbl.dsp)

    k = tbl[1] or k

    if k <= 0 then
        if WindSound:IsPlaying() then WindSound:ChangeVolume(0,0.05) end
        if WindSound2:IsPlaying() then WindSound2:ChangeVolume(0,0.05) end
    end

    local dot = ent:GetVelocity():GetNormalized()
    dot.z = 0

    local dir = Vector(1,0,0):Rotate(EyeAngles())
    dir.z = 0

    dot = 1 - math.abs(dot:Dot(dir))
    
    local volume = 1 * k
    local pitch = 75 + 45 * k

    if not WindSound:IsPlaying() then
        WindSound:PlayEx(volume,pitch)
    end

    local volume2 = volume * math.abs(dot)

    if not WindSound2:IsPlaying() then
        WindSound2:PlayEx(volume2,pitch)
    end

    WindSound:ChangeVolume(volume - volume2 * 0.6,0.25)
    WindSound:ChangePitch(pitch,0.25)
    
    WindSound2:ChangeVolume(volume2,0.25)
    WindSound2:ChangePitch(pitch,0.25)
end)

event.Add("PreCalcView","Wind",function(ply,view)
    if k <= 0 then return end

    local mul = 15 + 25 * k

    //view.ang = view.ang + Angle(math.cos(CurTime() * mul),math.sin(CurTime() * mul),math.cos(CurTime() * mul/5)/5):Mul(15 * k)
    view.fov = math.min(view.fov + 25 * k,120)

    if ply:InVehicle() then return end
    
    view.vec:Add(VectorRand(-k,k):Mul(0.5))
end)