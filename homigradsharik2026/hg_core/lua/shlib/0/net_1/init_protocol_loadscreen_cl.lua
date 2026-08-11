if not InitNET then
    hook.Add("CreateMove","InitProtocol",function(cmd)
        if InitNET then
            hook.Remove("CreateMove","InitProtocol")
            return
        end

        cmd:ClearMovement()
        cmd:ClearButtons()

        return true
    end)

    event.Add("Setup World","RemoveMoveHook",function()
        hook.Remove("CreateMove","InitProtocol")
    end,-11)
end

local start

event.Add("PreCalcView","Load Screen",function(ply,view)
    if InitNET then return end

    view.fov = 90
    view.pos = ply:GetPos()
    view.ang = ply:GetAngles()
    
    return view
end,-10000)

event.Add("DSP","Load Screen",function()
    if InitNET then return end

    return 14,true
end,-100)

local color_red = Color(255,0,0)
local color_white = Color(230,230,245)
local color_black = Color(10,10,10,200)

local function SkipProtocol()
    if InitNET then return end

    InitProtocol = "setupWorld"
    event.Call("Setup World")
    InitProtocol = "ready"
    InitNET = true

    timer.Remove("initProtocol_3")
    gui.EnableScreenClicker(false)
end

local descText = "Если ничего не происходит минуту, возможно что-то произошло с сервером.\nЕсли это так, то сообщите об этом на нашем дискорд сервере (ссылка на дискорд на сайте https://homigrad.com)"

local function ParseDesc()
    local ok,markup = pcall(markup.Parse,"<font=H25>" .. descText .. "</font>")
    if ok then return markup end
end

local descDefault = ParseDesc()

event.Add("Screen Size","initProtocol",function()
    descDefault = ParseDesc()
end)

event.Add("RenderScene","Load Screen",function()
    if InitNET then
        return
    end

    local w,h = ScrW(),ScrH()
    
	cam.Start2D()
		surface.SetDrawColor(25,25,25,255)
		surface.DrawRect(0,0,w,h)

        local preivewImage = GetGlobalString("Map Preview Icon")
        
        local mat = GetHTTPMaterial(preivewImage)

        if not mat[2] then--ПРЯМО КАК В РАСТЭЭ ЫЫЫ
            RunConsoleCommand("stopsound")
        else
            mat = mat[2]
            
            if not start then
                start = RealTime()
            end

            local k = 1 - math.max(start + 0.3 - RealTime(),0) / 0.3

            surface.SetDrawColor(255,255,255,255 * k)

            local matW,matH = mat:Width(),mat:Height()

            local size = (math.max(w,h) / math.max(matW,matH))
            
            matW = matW * size
            matH = matH * size

            surface.SetMaterial(mat)
            surface.DrawTexturedRect(w / 2 - matW / 2,h / 2 - matH / 2,matW,matH)

            surface.SetDrawColor(25,25,25,250)
            surface.DrawRect(0,0,w,h)

            DrawBlur(5,0,0)
        end

        draw.SimpleText(L("loadscreen_welcome"),"H50",w / 2,h * 0.133,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText(tostring(InitProtocol),"H50",w / 2,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        if InitProtocolError then
            InitProtocolError:Draw(w/2,h/1.5,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
 
            draw.SimpleText("Сообщите об этом на нашем дискорд сервере в форуме -> баги","H18",w /2 ,h - h / 12,color_red,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            draw.SimpleText("Ссылка на дискорд сервер есть на сайте https://homigrad.com","H18",w /2 ,h - h / 12 + 18,color_red,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            cam.End2D()

            return true
        elseif initProtocol_3_Title then
            if initProtocol_3_ProgressTitle then
                draw.SimpleText(initProtocol_3_ProgressTitle,"HS20",w/2,h/2 + 50,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end

            if initProtocol_3_Progress then
                if initProtocol_3_ProgressMax then
                    local size = w/2

                    local k = math.Clamp(1 - initProtocol_3_Progress / initProtocol_3_ProgressMax,0,1)

                    draw.RoundedBox(6,w/2 - size/2,h/2 + 80,size,25,color_black)
                    draw.RoundedBox(6,w/2 - size/2,h/2 + 80,size * k,25,color_white)

                    draw.SimpleText(math.floor(k * 100 * 10) / 10 .. "%" .. " / 100%","HS20",w/2,h/2 + 116,nil,TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText(initProtocol_3_Progress,"HS25",w/2,h/2 + 100,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                end
            end
   
            draw.SimpleText(initProtocol_3_Title,"HS30",w/2,h/2 - 50,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
        
        if initProtocol_3_Desc then
            initProtocol_3_Desc:Draw(w/2,h - h / 6,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,25,TEXT_ALIGN_CENTER)
        elseif descDefault then
            descDefault:Draw(w/2,h - h / 6,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,25,TEXT_ALIGN_CENTER)
        end

        DrawLoading(w/2,h - h / 3.5,64,6)
    cam.End2D()

    return true
end)

/*if Initialize and InitNET then
    InitNET = nil

    InitProtocol = "waitSourceReady"
    Start = RealTime()
    
    timer.Simple(1,function()
        InitProtocol = "waitResponseFromServer"
        net.Start("initProtocol")
        net.SendToServer()
    end)

    RunConsoleCommand("init_protocol_restart")
end*/