local vecFar = Vector(32000,32000,32000)

concommand.Add("hg_show_64bitmenu",function()
    if IsValid(frame64bitmenu) then vRemove(frame64bitmenu) end

	frame64bitmenu = oop.CreatePanel("v_panel"):setDSize(1,1)
    frame64bitmenu:SetMouseInputEnabled(true)
    gui.EnableScreenClicker(true)

    local snd

    surface.PlaySound("homigrad/baka-cirno.ogg")

    function frame64bitmenu:Draw(w,h)
		surface.SetDrawColor(28,28,28)
		surface.DrawRect(0,0,w,h)

        surface.SetMaterial(MaterialHash("homigrad/crino.png"))
        surface.SetDrawColor(100,100,100,6)
        surface.DrawTexturedRect(0,0,w,h)

        if not snd or not snd:IsPlaying() then
            if not snd then snd = CreateSound(LocalPlayer(),"homigrad/scarletpoliceonghettopatrolin24hours_lowpass.mp3") end
            snd:PlayEx(0.05,100)
        end

        draw.SimpleText("HOMIGRAD.COM","H50",w/2,h * 0.05,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText("32BIT GARRY'S MOD VERSION ON THIS SERVER - IS NOT SUPPORTED!","H50",w/2,h * 0.133,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText("Установите бета версию - x86-64 Chromium + 64-bit binares","H50",w/2,h * 0.133 + 60,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        surface.SetDrawColor(255,255,255)

        local mat = MaterialHash("homigrad/64bit_1.png")
        surface.SetMaterial(mat)
        local ratio = mat:Width() / mat:Height()
        local size = h * 0.6
        surface.DrawTexturedRectRotated(w * 0.3,h * 0.6,size,size / ratio,0)

        local mat = MaterialHash("homigrad/64bit_2.png")
        local ratio = mat:Width() / mat:Height()
        surface.SetMaterial(mat)
        local size = h * 0.7
        surface.DrawTexturedRectRotated(w * 0.7,h * 0.6,size,size / ratio,0)
    end

    event.Add("PreCalcView","frame64bitmenu",function(ply,view)
        view.vec = vecFar
        view.znear = 1
        view.zfar = 1

        return view
    end,-1000)

    event.Add("DSP","frame64bitmenu",function(ply)
        return 14
    end,-1000)

    plyVoice:Event_Add("Volume","frame64bitmenu",function() return false end,-1000)

    frame64bitmenu:Event_Add("Remove","frame64bitmenu",function()
        event.Remove("PreCalcView","frame64bitmenu",-1000)
        event.Remove("DSP","frame64bitmenu",-1000)
        plyVoice:Event_Remove("Volume","frame64bitmenu",-1000)
    end)

    net.LoadScreenTastAdd("donotenter",function() return false,"client version is 32bit, please change on x86-64 Chromium + 64-bit binares" end,-1000)
end)

hook.Add("InitPostEntity","WTF",function()
    if not IS64BIT then RunConsoleCommand("hg_show_64bitmenu") end
end)