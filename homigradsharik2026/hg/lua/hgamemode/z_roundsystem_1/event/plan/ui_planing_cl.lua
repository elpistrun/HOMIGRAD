local Panel = scoreboard:Page_Reg(6)
Panel.Name = "event"
Panel.Icon = Material("homigrad/vgui/icons/events.png")

local DIV = 60 * 60

CreateClientConVar("hg_rpc_event","0",true,true)

function EventPlaning_UICreate(PANEL1)
    local eventPage = oop.CreatePanel("v_panel",PANEL1):ad(function(self,w,h) self:setSize(w,h * 0.5) end)
    local eventPanel = oop.CreatePanel("v_panel",eventPage):ad(function(self,w,h) self:setSize(w - 60,h - 60):setPos(30,30) end)
    local backgroundHtml = oop.CreatePanel("v_html",eventPage):setDSize(1,1)
    backgroundHtml:SetZPos(-100)
    local descScrollPanel = oop.CreatePanel("v_scrollpanel",eventPanel):ad(function(self,w,h) self:setSize(w * 0.5,h - 64):setPos(16,64) end)
    descScrollPanel.scrolling = 64

    local H = 0
    local desc = oop.CreatePanel("v_textentry",descScrollPanel):ad(function(self,w,h) self:setSize(w,H) end)
    desc:SetupDrawStyle("white"):SetMultiline(true):SetFont("HS.25")
    
    function descScrollPanel:DrawOver(w,h)
        surface.SetDrawColor(125,125,125,125)
        draw.GradientLeft(0,1,w,1)
        draw.GradientLeft(0,h - 1,w,1)
    end

    function eventPage:Draw(w,h)
        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)
    end

    local iconSize = 64

    local playersList = oop.CreatePanel("v_scrollpanel",eventPanel):ad(function(self,w,h) self:setSize(w * 0.4,h - 64):setPos(w - self:W() - 2,64) end)
    playersList:CreateVBar()
    playersList.scrolling = iconSize

    local avatarList = oop.CreatePanel("v_avatarlist",playersList)

    avatarList:Setup(iconSize)
    avatarList:SetScrollPanel(playersList)

    function playersList:Draw(w,h)
        surface.SetDrawColor(125,125,125,125)
        draw.GradientRight(0,1,w,1)
        draw.GradientRight(0,h - 1,w,1)
    end

    local nextPage = oop.CreatePanel("v_button",eventPage):ad(function(self,w,h) self:setSize(200,50):setPos(w / 2 - self:W(),30) end)
    nextPage:SetupDrawStyle("white_gradient"); nextPage.gradientSide = "left"; nextPage.text = "EVENT PANEL"; nextPage.font = "HS.25"
    function nextPage:OnClick() Panel.SetPage(2) end

    local finishEvent = oop.CreatePanel("v_button",eventPage):ad(function(self,w,h) self:setSize(200,50):setPos(w / 2,30) end)
    finishEvent:SetupDrawStyle("white_gradient"); finishEvent.gradientSide = "right"; finishEvent.text = "FINISH EVENT"; finishEvent.font = "HS.25"
    function finishEvent:OnClick()
        VParametrEdit(L("event_finish_desc"),"",function(value)
            if (tonumber(value or 0) or 0) > 0 then RunConsoleCommand("hg_event_finish") end
        end,L("event_finish_title"))
    end

    local commentPage = oop.CreatePanel("v_button",eventPage):ad(function(self,w,h) self:setSize(200,50):setPos(w / 2 - self:W(),h - self:H() - 30) end)
    commentPage:SetupDrawStyle("white_gradient"); commentPage.gradientSide = "left"; commentPage.text = "COMMENT"; commentPage.font = "HS.25"
    function commentPage:OnClick() Panel.SetPage(3) end

    local playesTimePage = oop.CreatePanel("v_button",eventPage):ad(function(self,w,h) self:setSize(200,50):setPos(w / 2,h - self:H() - 30) end)
    playesTimePage:SetupDrawStyle("white_gradient"); playesTimePage.gradientSide = "right"; playesTimePage.text = "PLAYERS"; playesTimePage.font = "HS.25"
    function playesTimePage:OnClick() Panel.SetPage(4) end

    local function setSelectEvent(event)
        Panel.SelectEvent = event
        
        nextPage:SetVisible(false)
        commentPage:SetVisible(false)
        playesTimePage:SetVisible(false)
        finishEvent:SetVisible(false)
        
        if not event or not event.moderate then
            backgroundHtml:SetHTML([[]])
        else
            backgroundHtml:SetHTML([[
                <body style="margin: 0; padding: 0;">
                    <div style="opacity: 1; width: 100%; height: 100%; background-image: url(']] .. event.backgroundUrl .. [['); background-size: cover; background-position: center;">
                </body>
            ]])

            if Event_Claimed and event.id == Event_ClaimedID and Event_CanAccess(LocalPlayer()) then
                nextPage:SetVisible(true)
                finishEvent:SetVisible(true)
            end

            //commentPage:SetVisible(true)
            //playesTimePage:SetVisible(true)
        end

        function avatarList.OnReady()
            playersList:Clear()
            avatarList:Clear()

            if not event then return end

            local function addPlayer(steamid,name,avatar,avatarFrame,isOwner)
                local panel = avatarList:AddPanel(steamid,name,avatar,avatarFrame)

                function panel:Draw(w,h)
                    surface.SetDrawColor(0,0,0,100)
                    surface.DrawRect(0,0,w,h)
                    draw.Frame(0,0,w,h,cframe1,cframe2)

                    if isOwner then draw.SimpleText("owner","HS.12",w / 2,12,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
                end
            end

            local profile = Profiles[event.owner.steamid64 or ""] or {}

            addPlayer(event.owner.steamid64 or "",profile.name,profile.avatar,profile.avatarFrame,true)

            for steamid64,ply in pairs(event.friends) do
                local profile = Profiles[steamid64] or {}

                addPlayer(steamid64,profile.name,profile.avatar,profile.avatarFrame)
            end
        end
        
        if avatarList.Ready then avatarList.OnReady() end
    end

    setSelectEvent(Panel.SelectEvent)

    local oldMouseLeft

    function eventPanel:Draw(w,h)
        local event = Panel.SelectEvent

        if not event then
            draw.SimpleText(L("event_planing_select_event"),"HS.45",w / 2,0,nil,TEXT_ALIGN_CENTER)
            desc:SetValue("")

            return
        end

        draw.SimpleText(event.id,"HS.12",w/2,0,nil,TEXT_ALIGN_CENTER)

        if event.moderate then
            if desc:GetValue() != event.desc then
                desc:SetValue(event.desc)
            end

            surface.SetFont(desc:GetFont())
            local textW,textH = surface.GetTextSize(desc:GetValue())
            H = math.max(h,textH)

            surface.SetDrawColor(200,200,200,255)
            surface.DrawRect(0,0,2,h)
            surface.SetDrawColor(100,100,100,64)
            draw.GradientLeft(0,0,w * 0.3,h)
            draw.SimpleText(event.title,"HS.25",16,32,nil,nil,TEXT_ALIGN_CENTER)
        else
            surface.SetDrawColor(200,200,200,255)
            surface.DrawRect(0,0,2,h)
            surface.SetDrawColor(100,100,100,64)
            draw.GradientLeft(0,0,w * 0.3,h)
            draw.SimpleText("Ивент ждёт проверку от модераторов.","HS.25",16,32,nil,nil,TEXT_ALIGN_CENTER)
        end
        
        surface.SetDrawColor(200,200,200,255)
        surface.DrawRect(w - 2,0,2,h)
        surface.SetDrawColor(100,100,100,64)
        draw.GradientRight(w - w * 0.3,0,w * 0.3,h)
        draw.SimpleText(event.server.name,"HS.25",w - 16,32,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

        surface.SetFont("HS.12")
        
        local textW,textH = surface.GetTextSize(event.server.ip)
        local mx,my = self:GetMousePos()

        if mx >= w - 16 - textW and mx <= w - 16 and my >= 52 - textH / 2 and my <= 52 + textH / 2 then//ETO PIZDA BLAD
            surface.SetDrawColor(255,255,255,25)
            surface.DrawRect(w - 16 - textW,52 - textH / 2,textW,textH)
            
            local active = eventPanel.mouse[MOUSE_LEFT]

            if active ~= oldMouseLeft then
                oldMouseLeft = active

                if active then
                    chat.AddText("Copy server ip: " .. event.server.ip)
                end
            end
        end
        
        draw.SimpleText(event.server.ip,"HS.12",w - 16,52,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
    end

    // EVENT PLANING

    local eventsPlaning = oop.CreatePanel("v_panel",PANEL1):ad(function(self,w,h) self:setSize(w,h - eventPage:H()):setPos(0,eventPage:H()) end)

    local size,sizeH,sizeEventH = 256,32,90

    local timePanel = oop.CreatePanel("v_panel",eventsPlaning):ad(function(self,w,h) self:setSize(w,sizeH) end)
    local list = oop.CreatePanel("v_scrollpanel",eventsPlaning):ad(function(self,w,h) self:setSize(w,h - timePanel:H()):setPos(0,timePanel:H()) end)
    list:CreateVBar()

    function list.canvasPanel:OnMouse(key)
        if key == MOUSE_LEFT then setSelectEvent() end
    end

    local text = Color(255,255,255)

    local setX = -(list:W() / 2)
    local x = setX

    function list:OnWheel(value)
        if input.IsButtonDown(KEY_LSHIFT) then return end
            
        setX = setX + value * size

        return false
    end

    local curret = os.time()

    function list:Draw(w,h)
        x = LerpFTLess(0.25,x,setX,0.75)

        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)
    end

    function timePanel:Draw(w,h)
        local pointX = 0

        for i = 0,w do
            local renderX = pointX - x % size
            local time = (math.floor(curret / DIV) + 1 * i + math.floor(x / size)) * DIV

            local aviable = time > os.time()

            surface.SetDrawColor(255,255,255,aviable and 25 or 5)
            text.a = aviable and 255 or 25

            surface.DrawRect(renderX,0,1,sizeH)
            draw.SimpleText(os.date("%H:%M",time),os.date("%M",time) == "00" and "HS.18" or "HS.12",renderX + sizeH/3,sizeH/2,text,nil,TEXT_ALIGN_CENTER)

            if pointX > w then break end
            pointX = pointX + size
        end
        
        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(255,255,255,15)
        surface.DrawRect(0,0,w,1)

        surface.SetDrawColor(0,0,0,2555)
        surface.DrawRect(0,1,w,1)

        surface.SetDrawColor(255,255,255,15)
        surface.DrawRect(0,h - 1,w,1)
    end

    function list.canvasPanel:Draw(w,h)
        local pointX = 0

        for i = 0,w do
            local renderX = pointX - x % size
            local time = (math.floor(curret / DIV) + 1 * i + math.floor(x / size)) * DIV

            local aviable = time > os.time()

            surface.SetDrawColor(255,255,255,aviable and 25 or 5)
            text.a = aviable and 255 or 25

            if os.date("%H%M",time) == "0000" then
                surface.DrawRect(renderX,0,1,h)
                draw.SimpleText(os.date("%d",time),"HS.18",renderX + sizeH/3,sizeH/2,text,nil,TEXT_ALIGN_CENTER)
            end

            for i,event in pairs(eventManager.listData) do
                local panel = event.panel
                local renderX = (event.period[1] - math.floor(curret / DIV) * DIV) / DIV * size - x
                
                panel:setPos(renderX,panel.y)
            end

            if pointX > w then break end
            pointX = pointX + size
        end

        local osTime = os.time()

        local renderX = (osTime - (math.floor(curret / DIV) * DIV)) / DIV * size - x
        surface.SetDrawColor(255,255,255,15)
        surface.DrawRect(renderX,0,1,h)
        draw.GradientLeft(renderX + 2,0,16,h)
        draw.SimpleText(os.date("%H:%M",osTime),"HS.18",renderX + sizeH/2,h - sizeH/2,nil,nil,TEXT_ALIGN_BOTTOM)
        DisableClipping(true)
        surface.SetFigure("triangle")
        surface.SetDrawColor(255,255,255)
        draw.Figure(renderX,h + sizeH / 2,sizeH / 2,sizeH / 2,0)
        DisableClipping(false)
    end

    function list:Update()
        list:Clear()

        for id,event in pairs(eventManager.listData) do
            event.id = id

            local sizeEventH = sizeEventH - 4
            local lenght = (event.period[2] - event.period[1]) / DIV

            local panelEvent = oop.CreatePanel("v_panel",list):ad(function(self,w,h)
                self:setSize(size * lenght,sizeEventH)
            end)

            panelEvent:setPos((event.period[1] - math.floor(curret / DIV) * DIV) / DIV * size - x,0)

            if event.moderate then
                local y = 0

                local htmlBackground = oop.CreatePanel("v_html",panelEvent):setDSize(1,1)
                htmlBackground:SetHTML([[
                    <body style="margin: 0; padding: 0;">
                        <div style="opacity: 1; width: 100%; height: 100%; background-image: url(']] .. event.backgroundUrl .. [['); background-size: cover; background-position: center;">
                    </body>
                ]])

                function htmlBackground:DrawOver(w,h)
                    surface.SetFont("HS.25")
                    local textW = surface.GetTextSize(event.title)

                    local x = w / 2
                    local pos = list:W() - panelEvent.x
                    if pos - textW - 16 < x then
                        x = pos - textW - 16
                    end

                    pos = panelEvent.x + w / 2 - textW

                    if pos <= 0 then
                        x = w / 2 - pos
                    end

                    draw.SimpleText(event.title,"HS.25",x,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                    draw.SimpleText(event.server.name,"HS.12",x,h - 8,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

                    if Panel.SelectEvent == event or panelEvent:IsHovered() then
                        surface.SetDrawColor(255,255,255,15)
                        surface.DrawRect(0,0,w,h)

                        surface.SetDrawColor(255,255,255,75)
                        surface.DrawRect(0,h - 2,w,2)

                        draw.GradientDown(0,h - 16 - 2,w,16)
                    end
                end
                htmlBackground:SetMouseInputEnabled(false)
            else
                function panelEvent:DrawOver(w,h)
                    surface.SetDrawColor(0,0,0,125)
                    surface.DrawRect(0,0,w,h)

                    surface.SetDrawColor(255,0,0,64)
                    surface.DrawRect(0,h - 2,w,2)

                    draw.GradientLeft(0,0,w,h)

                    local title = "На модерации"
                    surface.SetFont("HS.25")
                    local textW = surface.GetTextSize(title)

                    local x = w / 2
                    local pos = list:W() - panelEvent.x
                    if pos - textW - 16 < x then
                        x = pos - textW - 16
                    end

                    pos = panelEvent.x + w / 2 - textW

                    if pos <= 0 then
                        x = w / 2 - pos
                    end

                    draw.SimpleText(title,"HS.25",x,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

                    if Panel.SelectEvent == event or panelEvent:IsHovered() then
                        surface.SetDrawColor(255,255,255,15)
                        surface.DrawRect(0,0,w,h)

                        surface.SetDrawColor(255,255,255,75)
                        surface.DrawRect(0,h - 2,w,2)

                        draw.GradientDown(0,h - 16 - 2,w,16)
                    end
                end
            end

            function panelEvent:OnMouse(key,value)
                if not value then return end

                if key == MOUSE_LEFT then setSelectEvent(event) end
                if key == MOUSE_RIGHT then
                    local menu = DermaMenu()

                    menu:AddOption("Удалить",function()
                        RunConsoleCommand("hg_event_remove",id)
                    end)

                    menu:Open()
                end
            end

            if Panel.SelectEvent == event then setSelectEvent(event) end

            event.panel = panelEvent
        end

        local ladder = {}

        for i,event1 in pairs(eventManager.listData) do
            local panel1 = event1.panel
            local y = 0

            for i,event2 in pairs(eventManager.listData) do
                if event1 == event2 then continue end
                local panel2 = event2.panel
                
                if panel1.x + panel1:W() > panel2.x and panel1.x < panel2.x + panel2:W() and panel1.y == panel2.y then
                    panel2:setPos(panel2.x,panel2.y + panel2:H())
                end
            end
        end

        if Panel.SelectEvent and not eventManager.listData[Panel.SelectEvent.id] then setSelectEvent() end
    end

    list:Update()

    eventManager:Event_Add("Update","TAB",function()
        if IsValid(list) then list:Update() end
    end)

    if LocalPlayer():HasSuccess("eventplaning_access") then
        local eventCreate = oop.CreatePanel("v_button",eventsPlaning):ad(function(self,w,h) self:setSize(200,50):setPos(w - self:W() - 20,h - self:H() - 10) end)
        eventCreate:SetupDrawStyle("white_gradient"); eventCreate.gradientSide = "right"; eventCreate.text = "EVENT CREATE"; eventCreate.font = "HS.25"
        function eventCreate:OnClick()
            Homigrad_RulesPublishContent("hg_rpc_event",function()
                RunConsoleCommand("hg_event_create")
            end)
        end
    end
end