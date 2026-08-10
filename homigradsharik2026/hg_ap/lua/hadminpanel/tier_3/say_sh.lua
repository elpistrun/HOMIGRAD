adminPanel.commandRegistry("csay",{"line"})
adminPanel.commandRegistry("tsay",{"line"})

if CLIENT then
    local list = {}
    local delay = 5

    net.Receive("csay",function()
        list[#list+1] = {
            start = RealTime() + delay,
            text = net.ReadString()
        }
    end)
    
    hook.Add("HUDPaintBackground","CSay",function()
        local i = 0
        local w,h = ScrW(),ScrH()

        ::again::

        i = i + 1

        local id = #list - i + 1
        local text = list[id]

        if not text then
            surface.SetAlphaMultiplier(1)

            return
        end

        local k = (text.start - RealTime()) / delay
        surface.SetAlphaMultiplier(k)

        if k <= 0 then table.remove(list,id) i = i - 1 goto again end

        draw.SimpleText(text.text,"HS30",w/2,h*0.2 + (i - 1) * 25,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        goto again
    end)
else
    adminPanel.commandCreate("tsay",function(callerSteamID64,text)
        local profile = Profiles[callerSteamID64]
        
        if profile then
            text = profile.name .. "(" .. callerSteamID64 .. "): " .. text
        else
            text = "(" .. callerSteamID64 .. "): " .. text
        end

        for i,ply in pairs(player.GetAll()) do
            ply:ChatAddText(Color(255,255,255),text)
        end
    end)

    util.AddNetworkString("csay")
    
    adminPanel.commandCreate("csay",function(callerSteamID64,text)
        net.Start("csay")
        net.WriteString(text)
        net.Broadcast()
    end)
end