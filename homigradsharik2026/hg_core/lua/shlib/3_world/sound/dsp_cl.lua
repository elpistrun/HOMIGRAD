local oldDSP

hook.Add("Think","DSP",function()
    local dsp,instant = event.Call("DSP",GetViewEntity())

    if oldDSP ~= dsp then
        oldDSP = dsp
        
        LocalPlayer():SetDSP(dsp or 0,instant)
    end
end)