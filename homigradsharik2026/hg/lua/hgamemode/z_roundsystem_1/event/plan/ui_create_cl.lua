local DIV = 60 * 60

net.Receive("event_create",function()
    if net.ReadBool() == false then
        chat.AddText(Color(255,125,125),"Your time has not expired yet since the last event")
        
        return
    end

    local servers = net.ReadTable()

    SERVERS = servers
    
    scoreboard:Close()

    if IsValid(EVENTCREATE) then EVENTCREATE:Remove() end

    local widthPage
    EVENTCREATE = oop.CreatePanel("v_frame"):ad(function(self,w,h) widthPage = w self:setSize(widthPage * 3,h) end)
    EVENTCREATE:MakePopup()
    
    local SelectPage,SelectPageSet = 1,1
    local request = {
        friends = {},
        title = L("event_create_example_title"),
        desc = L("event_create_example_desc"),
        period = {
            math.ceil(os.time() / DIV) * DIV,
            math.ceil(os.time() / DIV + 1) * DIV
        }
    }
    
    for i,server in pairs(SERVERS) do
        if server.json.ip == game.GetIPAddress() then request.server = server break end
    end
    
    request.server = request.server or SERVERS[1]
    
    function EVENTCREATE:Draw(w,h)
        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)
    
        surface.SetDrawColor(200,200,200,15)
        local size = h / 2 + h / 4 * math.cos(CurTime())
        draw.GradientDown(0,h - size,w,size + 1)
    
        surface.SetDrawColor(0,0,0,125)
        draw.GradientLeft(0,0,w / 4,h)
    
        surface.SetDrawColor(0,0,0,125)
        draw.GradientRight(w - w / 4 + 1,0,w / 4,h)
    
        SelectPage = LerpFTLess(0.5,SelectPage,SelectPageSet,0.0001)
    
        EVENTCREATE:SetX(-widthPage * (SelectPage - 1))
    end
    
    // SELECT SERVER
    
    local pageSelectServer = oop.CreatePanel("v_panel",EVENTCREATE):ad(function(self,w,h) self:setSize(widthPage,h) end)
    
    local list = oop.CreatePanel("v_scrollpanel",pageSelectServer):ad(function(self,w,h) self:setSize(w * 0.8,h * 0.6):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2) end)
    list:CreateVBar()
    list.scrollY = 75
    list.scrollMul = 3
    
    function list:Draw(w,h)
        DisableClipping(true)
        draw.SimpleText(L("event_create_select_server"),"HS.25",0,-45)
        DisableClipping(false)
    
        surface.SetDrawColor(255,255,255,10)
        surface.DrawRect(0,0,w,1)
        surface.DrawRect(0,h - 1,w,1)
    end
    
    local events = {}
    
    for i,server in pairs(SERVERS) do
        local I = i - 1
        local button = oop.CreatePanel("v_button",list):ad(function(self,w,h) self:setSize(w,75):setPos(0,self:H() * I) end)

        function button:Draw(w,h)
            if self:IsHovered() then surface.SetDrawColor(255,255,255,5) surface.DrawRect(0,0,w,h) end
            if request.server == server then
                surface.SetFigure("triangle")
    
                surface.SetDrawColor(255,255,255,255)
    
                local size = math.floor(h / 2) - 5
    
                draw.Figure(w - h / 2 - h / 2 / 5 * math.cos(CurTime() * 10) ,h / 2,size,size,90)
            end
    
            draw.SimpleText(server.json.origName,"HS.25",h / 2,h / 2,nil,nil,TEXT_ALIGN_CENTER)
            draw.SimpleText(server.json.ip,"HS.12",h / 2,h - (h / 4),nil,nil,TEXT_ALIGN_CENTER)
    
            if server.json.ip == game.GetIPAddress() then
                draw.SimpleText(L("event_create_playing_server"),"HS.12",h / 2,h / 4,nil,nil,TEXT_ALIGN_CENTER)
            end
        end
    
        function button:OnClick()
            SelectPageSet = 2
    
            request.server = server
    
            events = {}
            
            for i,event in pairs(eventManager.listData) do
                if event.server.ip == request.server.json.ip then
                    events[#events + 1] = event
                end
            end
        end
    end
    
    local back = oop.CreatePanel("v_button",pageSelectServer):ad(function(self,w,h) self:setSize(300,50):setPos(60,h - 60 - self:H()) end)
    back:SetupDrawStyle("white"); back.text = "Выйти"; back.font = "HS.25"
    function back:OnClick() EVENTCREATE:Remove() scoreboard:Open() end
    
    // SETTING EVENT INFO AND TEAM
    
    local pageSetupEvent = oop.CreatePanel("v_panel",EVENTCREATE):ad(function(self,w,h) self:setSize(widthPage,h):setPos(self:W(),0) end)
    local panel = oop.CreatePanel("v_panel",pageSetupEvent):ad(function(self,w,h) self:setSize(w * 0.8,h * 0.6):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2) end)
    
    function panel:Draw(w,h)
        DisableClipping(true)
        draw.SimpleText(L("event_create_info"),"HS.25",0,-45)
        draw.SimpleText(L("event_create_team"),"HS.25",w,-45,nil,TEXT_ALIGN_RIGHT )
        DisableClipping(false)
    
        surface.SetDrawColor(255,255,255,10)
        surface.DrawRect(0,0,w,1)
        surface.DrawRect(0,h - 1,w,1)
    end
    
    local eventInfo = oop.CreatePanel("v_panel",panel):ad(function(self,w,h) self:setSize(w / 2,h) end)
    
    local selectServer = oop.CreatePanel("v_panel",eventInfo):ad(function(self,w,h) self:setSize(w,50) end)
    function selectServer:Draw(w,h)
        if not request.server then return end
    
        draw.SimpleText(L("event_create_server") .. ": " .. request.server.json.origName,"HS.25",0,h / 2,nil,nil,TEXT_ALIGN_CENTER)
    end
    
    local title = oop.CreatePanel("v_textentry",eventInfo):ad(function(self,w,h) self:setSize(w,45):setPos(0,selectServer:H()) end)
    title:SetupDrawStyle("white"):SetFont("HS.25"):SetValue(request.title)
    function title:OnChange() request.title = title:GetValue() end
    
    function title:DrawOver(w,h)
        draw.Frame(0,0,w,h,cframe2,cframe1)
    end
    
    local htmlBackground = oop.CreatePanel("v_html",panel):setDSize(1,1)
    htmlBackground:SetZPos(-100)
    
    local backgroundUrl = oop.CreatePanel("v_textentry",eventInfo):ad(function(self,w,h) self:setSize(w,25):setPos(0,h - self:H()) end)
    backgroundUrl:SetupDrawStyle("white")
    backgroundUrl:SetValue("https://i.pinimg.com/originals/9f/7f/e1/9f7fe1e5419d6766c21f7f7873373685.gif")
    function backgroundUrl:DrawOver(w,h) draw.Frame(0,0,w,h,cframe2,cframe1) end
    
    function backgroundUrl:OnChange()
        htmlBackground:SetHTML([[
            <body style="margin: 0; padding: 0;">
                <div style="width: 100%; height: 100%; background-image: url(']] .. self:GetValue() .. [['); background-size: cover; background-position: center;">
            </body>
        ]])
    
        request.backgroundUrl = self:GetValue()
    end
    backgroundUrl:OnChange()
    
    local desc = oop.CreatePanel("v_textentry",eventInfo):ad(function(self,w,h) self:setSize(w,h - title.y - title:H() - backgroundUrl:H()):setPos(0,title.y + title:H()) end)
    desc:SetupDrawStyle("white"):SetFont("HS.25"):SetMultiline(true):SetValue(request.desc)
    function desc:OnChange() request.desc = desc:GetValue() end
    function desc:DrawOver(w,h) draw.Frame(0,0,w,h,cframe2,cframe1) end
    
    local players = oop.CreatePanel("v_players",panel):ad(function(self,w,h) self:setSize(w / 2,h - 60):setPos(w / 2,0) end)
    players:CreateVBar()
    players:Setup(64)
    players:SetHeightSearch(50)
    players:SetupDrawStyle("white")
    players.font = "HS.25"
    
    function players:OnClick(key,info)
        if not request.friends[info.id] then
            request.friends[info.id] = true
        else
            request.friends[info.id] = nil
        end
    end
    
    for i,ply in pairs(player.GetAll()) do
        if ply == LocalPlayer() then continue end
    
        players:AddPlayer(ply)
    end
    
    function players:DrawPanel(w,h,panel,info)
        surface.SetDrawColor(255,255,255,5)
        surface.DrawRect(0,0,w,h)
    
        if panel:IsHovered() then
            surface.SetDrawColor(255,255,255,15)
            surface.DrawRect(0,0,w,h)
        end
    
        if request.friends[info.id] then
            surface.SetDrawColor(255,255,255,64)
            draw.GradientLeft(0,0,w,h)
        end
    
        draw.SimpleText(info.name,self.font,h / 2,h / 2,self.textColor,nil,TEXT_ALIGN_CENTER)
    end
    
    local back = oop.CreatePanel("v_button",pageSetupEvent):ad(function(self,w,h) self:setSize(300,50):setPos(60,h - 60 - self:H()) end)
    back:SetupDrawStyle("white"); back.text = L("back"); back.font = "HS.25"
    function back:OnClick() SelectPageSet = 1 end
    
    local accept = oop.CreatePanel("v_button",pageSetupEvent):ad(function(self,w,h) self:setSize(300,50):setPos(w - self:W() - 60,h - 60 - self:H()) end)
    accept:SetupDrawStyle("white"); accept.text = L("event_create_settime"); accept.font = "HS.25"
    function accept:OnClick() SelectPageSet = 3 end
    
    // SELECT PERIOD
    
    local pagePeriod = oop.CreatePanel("v_panel",EVENTCREATE):ad(function(self,w,h) self:setSize(widthPage,h):setPos(self:W() * 2,0) end)
    local panel = oop.CreatePanel("v_panel",pagePeriod):ad(function(self,w,h) self:setSize(w * 0.8,h * 0.6):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2) end)
    
    local curret = os.time()
    local x,setX
    local oldMouseDown
    local start,endd = request.period[1],request.period[2]
    local colorText = Color(255,255,255)
    
    local function canSelected(time)
        if true then return true end
        if time < os.time() then return false end
    
        for i,event in pairs(events) do
            if time >= event.period[1] and time < event.period[2] then return false,event end
        end
    
        return true
    end
    
    function panel:Draw(w,h)
        DisableClipping(true)
        draw.SimpleText(L("event_create_period"),"HS.25",w / 2,-45,nil,TEXT_ALIGN_CENTER)
        DisableClipping(false)
    
        surface.SetDrawColor(255,255,255,10)
        surface.DrawRect(0,0,w,1)
        surface.DrawRect(0,h - 1,w,1)
    
        if not x then
            setX = 0//-(w/2)
            x = setX
        end
    
        x = LerpFTLess(0.25,x,setX,0.01)
    
        local size = 64
        local pointX = 0
    
        local mousex = panel:GetMousePos()
        local mouseDown = panel.mouse[MOUSE_LEFT]
    
        --[[local limit = Event_PlaningLimit[LocalPlayer():GetUserGroup()]
        local limitHours = limit and limit[1]
    
        if limitHours then
            draw.SimpleText(L("event_create_limit",limitHours),"HS.25",w / 2,25,nil,TEXT_ALIGN_CENTER)
        end]]--
    
        for i = 0,w do
            local time = (math.floor(curret / DIV) + (i + math.floor(x / size))) * DIV
            local aviableTime,eventClaimed = canSelected(time)
    
            local renderX = pointX - x % size
    
            if not aviableTime then
                if eventClaimed then
                    surface.SetDrawColor(255,0,0,75)
                    surface.DrawRect(renderX,h - size,size,size)
                else
                    surface.SetDrawColor(255,255,255,75)
                end
                colorText.a = 75
            else
                surface.SetDrawColor(255,255,255,75)
                colorText.a = 255
            end
    
            surface.DrawRect(renderX,h - size,1,size)
    
            if text == "00" then
                surface.DrawRect(renderX,0,1,h)
                draw.SimpleText(os.date("%d",time),"HS.12",renderX + 5,5,colorText)
            end
    
            if aviableTime and mousex > renderX and mousex < renderX + size then
                surface.DrawRect(renderX,h - size,size,size)
    
                if mouseDown then
                    if oldMouseDown ~= mouseDown or not start then
                        start = time
                        endd = time + DIV
                    else
                        if time ~= start and (not limitHours or (math.max(start,time) - math.min(start,time)) / 60 / 60 <= limitHours) then
                            endd = time
                        end
                    end
                end
            end
    
            if start and endd and ((time >= start and time < endd) or time <= start and time >= endd) then
                surface.SetDrawColor(0,255,0,75)
                surface.DrawRect(renderX,h - size,size,size)
            end
            
            local text = os.date("%H",time)
            draw.SimpleText(text,"HS.12",renderX + 5,h - size,colorText)
    
            pointX = pointX + size
    
            if pointX > w then break end
        end
    
        local renderX = size * ((os.time() - (math.floor(curret / DIV) * DIV)) / DIV) - x
        surface.SetDrawColor(255,255,255,75)
        surface.DrawRect(renderX,0,1,h)
        draw.SimpleText(os.date("%H:%M",os.time()),"HS.12",renderX + 4,4)
    
        oldMouseDown = mouseDown
    
        if start and endd then
            local startRender,endRender = start,endd
            if endRender < startRender then
                startRender = endd
                endRender = start
            end
    
            request.period[1] = startRender
            request.period[2] = endRender
    
            DisableClipping(true)
            draw.SimpleText(L("event_create_period_time",os.date("%H:%M",startRender),os.date("%H:%M",endRender)),"HS.25",w / 2,h + 45,nil,TEXT_ALIGN_CENTER)
            draw.SimpleText(L("event_create_curret_time",os.date("%H:%M",os.time())),"HS.25",w / 2,h + 45 * 2,nil,TEXT_ALIGN_CENTER)
            DisableClipping(false)
        end
    end
    
    function panel:OnWheel(value)
        setX = setX + value * 64
    end
    
    local back = oop.CreatePanel("v_button",pagePeriod):ad(function(self,w,h) self:setSize(300,50):setPos(60,h - 60 - self:H()) end)
    back:SetupDrawStyle("white"); back.text = L("back"); back.font = "HS.25"
    function back:OnClick() SelectPageSet = 2 end
    
    local accept = oop.CreatePanel("v_button",pagePeriod):ad(function(self,w,h) self:setSize(300,50):setPos(w - self:W() - 60,h - 60 - self:H()) end)
    accept:SetupDrawStyle("white"); accept.text = L("event_create"); accept.font = "HS.25"
    function accept:OnClick()
        net.Start("event_create")
        request.ping = true
        net.WriteTable(request)
        net.SendToServer()
    
        EVENTCREATE:Remove()
    
        scoreboard:Open()
    end
    
    local acceptWithOutPing = oop.CreatePanel("v_button",pagePeriod):ad(function(self,w,h) self:setSize(400,50):setPos(accept.x - 60 - self:W(),h - 60 - self:H()) end)
    acceptWithOutPing:SetupDrawStyle("white"); acceptWithOutPing.text = L("event_create_without_ping"); acceptWithOutPing.font = "HS.25"
    function acceptWithOutPing:OnClick()
        net.Start("event_create")
        request.ping = false
        net.WriteTable(request)
        net.SendToServer()
    
        EVENTCREATE:Remove()
    
        scoreboard:Open()
    end
    
    //SelectPageSet = 2
end)
