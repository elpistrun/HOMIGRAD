if not adminPanel then return end

hook.Add("HUDPaint","NetTrafic",function()
    if NetCatchTrafic then
        --draw.SimpleText("NET TRAFIC CLIENT","HS.12",0,0)
    end

    if GetGlobalVar("NetTrafic") then
        --draw.SimpleText("NET TRAFIC SERVER","HS.12",0,12)
    end
end)

NetsScreenShoots = NetsScreenShoots or {}
NetsScreenShootsBytes = NetsScreenShootsBytes or {}

local MaxBytes = 0

net.ReceiveMediaToken("net_trafic",function(body)
    local screen = JSONToTable(body)

    local res = {}
    
    for typeChannel,info in pairs(screen) do
        res[typeChannel] = res[typeChannel] or {}

        local Bytes = 0

        for channel,info in pairs(info) do
            res[typeChannel][channel] = res[typeChannel][channel] or {}

            for start,info in pairs(info) do
                for type,bytes in pairs(info) do
                    res[typeChannel][channel][type] = (res[typeChannel][channel][type] or 0) + bytes
                end
            end
        end
    end

    NetsScreenShoots[#NetsScreenShoots + 1] = res

    MaxBytes = 0

    for i,info in pairs(NetsScreenShoots) do
        local Bytes = 0

        for typeChannel,info in pairs(info) do
            for channel,info in pairs(info) do
                for type,bytes in pairs(info) do
                    Bytes = Bytes + bytes
                end
            end
        end

        NetsScreenShootsBytes[i] = Bytes

        if MaxBytes < Bytes then MaxBytes = Bytes end
    end
end)

concommand.Add("hg_dev_net_trafic",function()
    if IsValid(FrameNetTrafic) then FrameNetTrafic:Remove() end

    FrameNetTrafic = oop.CreatePanel("v_frame"):setDSize(1,1)
    FrameNetTrafic:MakePopup()
    
    function FrameNetTrafic:Draw(w,h)
        surface.SetDrawColor(0,0,0)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(25,25,25)
        local size = h * (1 - math.cos(RealTime()) * 0.25)
        draw.GradientDown(0,h - size,w,size)

        draw.SimpleText("NET TRAFIC","H.25",25,25)

        draw.SimpleText("IN KILOBYTES PER SECOND","H.25",25,h - 25,nil,nil,TEXT_ALIGN_BOTTOM)
    end

    local exit = oop.CreatePanel("v_button",FrameNetTrafic):ad(function(self,w,h) self:setSize(150,30):setPos(w - self:W() - 25,25) end)
    exit.text = "Exit"
    function exit:OnClick() FrameNetTrafic:Remove() end

    local curret = 1
    local scroll,zoom = 0,1

    local screenshoot = oop.CreatePanel("v_panel",FrameNetTrafic):ad(function(self,w,h) self:setSize(w * 0.75,50):setPos(w / 2 - self:W() / 2,13) end)
    local screenshootInfo = oop.CreatePanel("v_panel",FrameNetTrafic):ad(function(self,w,h) self:setSize(w * 0.75,h * 0.75):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2) end)
    
    function screenshoot:Draw(w,h)
        surface.SetDrawColor(200,200,200,1)
        surface.DrawRect(0,0,w,h)

        DisableClipping(true)
        draw.SimpleText(curret .. " / " .. #NetsScreenShoots,"H.25",w - 20,h + h / 2,nil,TEXT_ALIGN_RIGHT)
        DisableClipping(false)
        
        local x = scroll
        local wide = 4 / zoom

        local mx,my = self:GetMousePos()

        for i in pairs(NetsScreenShoots) do
            local H = h * (NetsScreenShootsBytes[i] / MaxBytes)

            if mx >= x and mx <= x + wide or curret == i then
                surface.SetDrawColor(200,0,0,255)

                if input.IsMouseDown(MOUSE_LEFT) then
                    curret = i
                end
            else
                surface.SetDrawColor(200,200,200,255)
            end

            surface.DrawRect(x,h - H,wide,H)

            x = x + wide
        end
    end

    function screenshoot:OnWheel(value)
        if input.IsButtonDown(KEY_LSHIFT) then
            zoom = zoom - value / 10
        else
            scroll = scroll + value * 100
        end
    end

    function screenshootInfo:Paint(w,h)
        surface.SetDrawColor(200,200,200,1)
        surface.DrawRect(0,0,w,h)

        local curretScreenShoot = NetsScreenShoots[curret]

        if not curretScreenShoot then
            draw.SimpleText("Select currret screenshoot","H.45",w / 2,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            
            return
        end

        //

        local x,y = 25,25

        draw.SimpleText("unreliable","H.18",x,y)
        y = y + 18

        for channel,info in pairs(curretScreenShoot[true] or {}) do
            draw.SimpleText(channel,"H.12",x,y)
            y = y + 12

            for types,bytes in pairs(info) do
                draw.SimpleText(types .. ": " .. math.floor(bytes / 1024 * 100) / 100,"H.12",x,y)
                y = y + 12
            end
        end

        //

        local x,y = w / 2,25

        draw.SimpleText("reliable","H.18",x,y)
        y = y + 18

        for channel,info in pairs(curretScreenShoot[false] or {}) do
            draw.SimpleText(channel,"H.12",x,y)
            y = y + 12

            for types,bytes in pairs(info) do
                draw.SimpleText(types .. ": " .. math.floor(bytes / 1024 * 100) / 100,"H.12",x,y)
                y = y + 12
            end
        end

        draw.SimpleText("Total: " .. math.floor(NetsScreenShootsBytes[curret] / 1024 * 100) / 100,"H.25",w - 25,h - 25,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)
    end
end)