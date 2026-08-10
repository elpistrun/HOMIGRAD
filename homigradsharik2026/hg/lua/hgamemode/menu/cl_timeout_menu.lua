local oldShutDown

hook.Add("Think","!!!!GetTimeoutInfo",function()
    if not InitNET then return end

    local shutdown,number = GetTimeoutInfo()

    if oldShutDown ~= shutdown then
        oldShutDown = shutdown
        
        if shutdown then
            if not IsValid(TimeOutMenuFrame) then RunConsoleCommand("hg_show_timeout_menu") end
        else
            if IsValid(TimeOutMenuFrame) then TimeOutMenuFrame:Remove() end
        end
    end
end)

local descColor = Color(2225,2225,2225,190)
local yellow = Color(255,255,125)
local red = Color(255,125,125)
local green = Color(125,255,125)

local HTTTP_TIMEOUT = 3
local HTTTP_TIMEOUT_ERROR = 5

local function drawBar(k,color)
    local w = 600
    
    surface.SetDrawColor(0,0,0,125)
    surface.DrawRect(75,180 + 45 * ScreenSize,w,12)

    surface.SetDrawColor(color)
    surface.DrawRect(75,180 + 45 * ScreenSize,w * k,12)
end

concommand.Add("hg_show_timeout_menu",function()//len delat norm 3aproc, зато видно админов
    if IsValid(TimeOutMenuFrame) then TimeOutMenuFrame:Remove() end
    
    TimeOutMenuFrame = oop.CreatePanel("v_panel"):setDSize(1,1)
    
    gui.EnableScreenClicker(false)

    local timeOpen = RealTime()
    local delay = 0
    
    local status,text,start,delay = "waitShutdown","",0,0

    function TimeOutMenuFrame:Draw(w,h)
        local time = RealTime()

        local k = 1 - math.max(timeOpen - time + 0.5,0) / 0.5

        surface.SetAlphaMultiplier(k)

        surface.SetDrawColor(15,15,15,125)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(0,0,0,190)
        draw.GradientUp(0,0,w,250)

        local changemap = GetGlobalVar("ChangeMap")
        
        draw.SimpleText("Timeout Menu","HS.45",w / 2,100,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText(changemap and L("timeoutmenu_changemap") or L("timeoutmenu_timeout"),"HS.18",w / 2,100 + 45,descColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    
        local Text,TextColor = "",yellow
        local TextDesc = ""
        local kBar = 0

        local shutdown,number = GetTimeoutInfo()

        if not shutdown then TimeOutMenuFrame:Remove() return end

        if status == "waitShutdown" then
            if changemap then
                status = "wait"
                delay = RealTime() + 1
            else
                Text = L("timeoutmenu_timeout_title",math.floor(number))
                TextColor = yellow
                TextDesc = L("timeoutmenu_timeout_desc")

                if number > 15 then status = "wait" end
            end
        end

        if status == "wait" then
            if delay <= time then
                status = "send"
                start = time

                HTTP({
                    url = "https://homigrad.com/status/" .. string.gsub(game.GetIPAddress(),":","_"),
                    method = "GET",
                    success = function(code,body,headers)
                        print(body)
                        if code ~= 200 and body ~= "nothing" then
                            status = "error"
                            reason = body

                            delay = RealTime() + HTTTP_TIMEOUT_ERROR

                            return
                        end

                        body = util.JSONToTable(body)

                        body = body.json
                        
                        if not body or body.nextmap or os.time() - body.time > 10 then
                            status = "error"
                            reason = L("timeoutmenu_servernotonline")
                            delay = time + HTTTP_TIMEOUT_ERROR
                        else
                            status = "live"
                        end
                    end,
                    failed = function(err)
                        status = "error"
                        reason = err

                        delay = RealTime() + HTTTP_TIMEOUT_ERROR
                    end,
                    timeout = HTTTP_TIMEOUT
                })
            end
        end

        if status == "send" then
            Text = L("timeoutmenu_send_title") .. (string.rep(".",time % 4))
            TextColor = yellow
            TextDesc = L("timeoutmenu_send_desc")

            kBar = 1 - math.max(start - time + HTTTP_TIMEOUT_ERROR,0) / HTTTP_TIMEOUT_ERROR
        end

        if status == "error" then
            Text = reason and reason or "Unkown reason......"

            local t = math.max(delay - time,0)
            TextDesc = L("timeoutmenu_error_desc",math.Round(t))

            TextColor = red

            kBar = 1 - t / HTTTP_TIMEOUT_ERROR

            if kBar == 1 then status = "wait" end
        end
        
        if status == "live" then
            Text = L("timeoutmenu_serveralive_title")
            TextColor = green
            TextDesc = ""

            RunConsoleCommand("retry")
        end

        if kBar > 0 then
            surface.SetDrawColor(0,0,0,255)
            surface.DrawRect(75,180 + 45 * ScreenSize,600,12)

            drawBar(kBar,TextColor)
        else
            surface.SetDrawColor(TextColor.r,TextColor.g,TextColor.b,255)
            surface.DrawRect(75,180 + 45 * ScreenSize,600,12)
        end

        surface.SetDrawColor(TextColor.r,TextColor.g,TextColor.b,255 / 10)
        draw.GradientDown(75,180,600,45)
        
        draw.SimpleText(Text,"HS.45",80,180,TextColor)
        draw.SimpleText(TextDesc,"HS.12",80,180 + 60 * ScreenSize,descColor)
    end
end)

net.Receive("show timeout menu",function()
    RunConsoleCommand("hg_show_timeout_menu")
end)