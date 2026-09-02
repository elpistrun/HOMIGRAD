--бесплатно?
--https://music.youtube.com/watch?v=Gy4ER1fmnRI&si=7lUG8laUJ-k8iviN

GameUIRepeat = GameUIRepeat or {}

local GameUISettings = {}

local old = false

local function removeAll()
    old = nil

    for name,panel in pairs(GameUIRepeat) do
        if IsValid(panel) then panel:Remove() end
        GameUIRepeat[name] = nil
    end
end

removeAll()

local hg_serverbrowser_disable
cvars.CreateOption("hg_serverbrowser_disable","0",function(value)
    hg_serverbrowser_disable = (tonumber(value or 0) or 0) > 0

    removeAll()
end)

local function parse()
    local Size

    if ScrH() > 1024 then
        Size = 27

        GameUISettings.newGame = 294
        GameUISettings.findMultiPlayerGame = 322

        GameUISettings.addons = 378
        GameUISettings.dupes = 406
        GameUISettings.saves = 434
        GameUISettings.demos = 462
    else
        Size = 17

        GameUISettings.newGame = 258
        GameUISettings.findMultiPlayerGame = 277

        GameUISettings.addons = 315
        GameUISettings.dupes = 334
        GameUISettings.saves = 353
        GameUISettings.demos = 372
    end

    surface.CreateFont("GameUITitle",{
        font = "DermaDefaultBold",
        size = Size,
        weight = 600,
    })
end

event.Add("Screen Size","GameUITitle",function()
    parse()
    removeAll()

    timer.Simple(0,function()
        parse()
        removeAll()
    end)
end)

parse()

local function clickThink(self,w,h,delay,phrase)
    --surface.SetDrawColor(255,0,0,125)
    --surface.DrawRect(0,0,w,h)

    local x,y = self:GetMousePos()

    if x >= 0 and y >= 0 and x < w and y < h then
        --surface.SetDrawColor(0,255,0,125)
        --surface.DrawRect(0,0,w,h)

        local active = input.IsMouseDown(MOUSE_LEFT)

        if self.old ~= active then
            self.old = active
            
            if active then
                timer.Simple(delay or 1 / 10,function()
                    if not IsValid(self) then return end

                    self:OnMouse(MOUSE_LEFT,active)
                end)
            end
        end
    end

    if not phrase then return end

    --draw.SimpleText(language.GetPhrase(phrase),"GameUITitle",0,0,Color(0,0,0,200))
end

local function createTitle(phrase)
    local title = oop.CreatePanel("v_panel"):ad(function(self,w,h)
        surface.SetFont("GameUITitle")
        local tw,th = HGetTextSize(language.GetPhrase(phrase))
        self:setSize(tw,th)
    end)

    title:MakePopup()
    title:SetMouseInputEnabled(false)

    local old = false

    function title:Draw(w,h)
        clickThink(self,w,h,nil,phrase)
    end

    return title
end

local function createLabel(text,panel)
    local label = oop.CreatePanel("v_textentry",panel)
    label:SetFont("HS.18")
    label:SetValue(text)
    label:SetDisabled(true)
    function label:Draw(w,h) self:DrawTextEntry(w,h) end

    return label
end

local crino = Material("homigrad/crino.png")

hook.Add("Think","Show server",function()
    if hg_serverbrowser_disable then return end

    local active = gui.IsGameUIVisible()

    if active then
        if IsValid(GameUIRepeat.browser) then
            GameUIRepeat.browser:SetVisible(not gui.IsConsoleVisible())
        end
    end

    if active ~= old then
        old = active

        if active then
            for name,panel in pairs(GameUIRepeat) do
                if IsValid(panel) then return end
            end
            
            removeAll()

            local k = ScrH() / 1980
            
            if not GameUIState then
                GameUIRepeat.newGame = createTitle("new_game"):ad(function(self,w,h) self:setPos(86,GameUISettings.newGame) end)
                GameUIRepeat.newGame.OnMouse = function() GameUIState = "MENU" removeAll() end

                GameUIRepeat.findMultiPlayerGame = createTitle("find_mp_game"):ad(function(self,w,h) self:setPos(86,GameUISettings.findMultiPlayerGame) end)
                GameUIRepeat.findMultiPlayerGame.OnMouse = function() GameUIState = "MENU" removeAll()  end

                --

                GameUIRepeat.addons = createTitle("addons"):ad(function(self,w,h) self:setPos(86,GameUISettings.addons) end)
                GameUIRepeat.addons.OnMouse = function() GameUIState = "MENU" removeAll() end

                GameUIRepeat.dupes = createTitle("dupes"):ad(function(self,w,h) self:setPos(86,GameUISettings.dupes) end)
                GameUIRepeat.dupes.OnMouse = function() GameUIState = "MENU" removeAll() end

                GameUIRepeat.saves = createTitle("saves"):ad(function(self,w,h) self:setPos(86,GameUISettings.saves) end)
                GameUIRepeat.saves.OnMouse = function() GameUIState = "MENU" removeAll() end
                
                GameUIRepeat.demos = createTitle("demos"):ad(function(self,w,h) self:setPos(86,GameUISettings.demos) end)
                GameUIRepeat.demos.OnMouse = function() GameUIState = "MENU" removeAll() end

                --

                local browser = oop.CreatePanel("v_frame"):ad(function(self,w,h) self:setPos(w - self:W() - 50,350) end)
                GameUIRepeat.browser = browser
                browser:MakePopup()

                local heightTitle = 45

                function browser:Draw(w,h)
                    draw.SimpleText("НАШИ СЕРВЕРА","HS.25",w/2,heightTitle/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

                    surface.SetDrawColor(255,255,255)

                    draw.GradientRight(0,heightTitle,w / 2,1)
                    draw.GradientLeft(w/2,heightTitle,w / 2,1)

                    draw.GradientRight(0,h - 1,w / 2,1)
                    draw.GradientLeft(w/2,h - 1,w / 2,1)

                    surface.SetDrawColor(20,20,20,200)

                    draw.GradientDown(0,heightTitle,w,h - heightTitle)
                end

                local width = 516

                function browser:Step()
                    local h = ScrH()

                    if GameUIGameContentOpen then
                        self:setSize(width,h - self.y - 64 - 300)
                    elseif GameUILanguageOpen then
                        self:setSize(width,h - self.y - 64 - 150)
                    else
                        self:setSize(width,h - self.y - 64)
                    end
                end

                local scrollpanel = oop.CreatePanel("v_scrollpanel",browser):ad(function(self,w,h) self:setPos(0,heightTitle):setSize(w,h - self.y) end)
                scrollpanel:CreateVBar()
                scrollpanel.scrolling = 120

                function browser:Request(callback)
                    HTTP({
                        url = "https://kopigrad.com/status/count",
                        method = "GET",
                        success = function(code,body,headers)
                            HomigradServerWait = nil
                            HomigradServerError = nil

                            body = JSONToTable(body)

                            local sort = {}

                            for ip,server in pairs(body) do
                                sort[#sort + 1] = server
                            end

                            table.sort(sort,function(a,b) return a.origName < b.origName end)

                            HomigradServers = sort
                            HomigradServersTime = RealTime()

                            callback()
                        end,
                        failed = function(err)
                            HomigradServerWait = nil
                            HomigradServerError = err

                            callback()
                        end
                    })
                end

                function browser:Update()
                    scrollpanel:Clear()

                    local panel = oop.CreatePanel("v_panel",scrollpanel):ad(function(self,w,h) self:setSize(w,h) end)

                    function panel:Draw(w,h)
                        DrawLoading(w/2,h/2,h/3,2)
                        if HomigradServerError then draw.SimpleText(HomigradServerError,"H.12",w/2,h/2,Color(255,0,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
                    end

                    if not HomigradServers or (HomigradServersTime or 0) + 60 < RealTime() then
                        if not HomigradServerWait then
                            HomigradServerWait = true

                            self:Request(function() if IsValid(self) then self:Update() end end)
                        end

                        return
                    end

                    panel:Remove()

                    local y = 0
                    local corner = 4

                    for i,server in pairs(HomigradServers) do
                        local Y = y
                        y = y + 64 + corner

                        local panel = oop.CreatePanel("v_panel",scrollpanel):ad(function(self,w,h) self:setSize(w - corner * 2,64):setPos(corner,Y) end)
                        
                        local isCurret = server.ip == game.GetIPAddress()

                        local butt

                        local materialGamemode = Material("homigrad/gamemodes/" .. string.sub(server.gameName,7,#server.gameName) .. ".png")

                        function panel:Draw(w,h)
                            surface.SetMaterial(materialGamemode)
                            surface.SetDrawColor(125,125,125,255)

                            if not materialGamemode:IsError() then
                                local hMat = materialGamemode:Height() / (materialGamemode:Width() / w)
                                surface.DrawTexturedRect(0,-hMat/3.5,w,hMat)
                            else
                                surface.SetDrawColor(255,255,255,255)
                                DrawBlurByPanel(3,self)
                            end

                            surface.SetDrawColor(0,0,0,100)
                            surface.DrawRect(0,0,w,h)

                            if isCurret then
                                surface.SetDrawColor(255,255,255,5)
                                surface.DrawRect(0,0,w,h)
                            end

                            draw.SimpleText(#server.players .. " / " .. server.maxPlayers,"HS.18",w - butt:W() - 9,9,nil,TEXT_ALIGN_RIGHT)
                        end

                        butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(h,h):setPos(w - h,0) end)
                        butt:SetupDrawStyle("white") butt.text = isCurret and "#" or "ЗАЙТИ" butt.font = "H.14"
                        butt:SetLock(isCurret)
                        function butt:OnClick() permissions.AskToConnect(server.ip) end

                        local label = createLabel(server.name,panel):ad(function(self,w,h) self:setPos(8,8):setSize(w/2-4,25) end)
                        local label = createLabel(server.ip,panel):ad(function(self,w,h) self:setPos(8,8 + 17):setSize(w/2-4,25) end)
                        label:SetFont("HS.12")
                    end
                end

                browser:Update()
            elseif GameUIState == "MENU" then
                local back = oop.CreatePanel("v_panel"):ad(function(self,w,h)
                    self:setPos(5,h - 45)
                    self:setSize(185,40)
                end)
                GameUIRepeat.back = back

                function back:Draw(w,h)
                    clickThink(self,w,h,1 / 10)
                end

                function back:OnMouse(key,value)
                    GameUIState = nil

                    removeAll()
                end

                back:MakePopup()
                back:SetMouseInputEnabled(false)
            end

            local changeGamemode = oop.CreatePanel("v_panel"):ad(function(self,w,h)
                self:setSize(145,50):setPos(w - self:W(),h - self:H())
            end)
            GameUIRepeat.changeGamemode = changeGamemode

            changeGamemode:MakePopup()

            local listKinematicObject = {}

            function changeGamemode:OnMouse(key,value)
                if not value then return end

                LocalPlayer():StopSound("homigrad/baka-cirno.ogg")
                LocalPlayer():EmitSound("homigrad/baka-cirno.ogg",75,100,1)

                listKinematicObject[#listKinematicObject + 1] = {
                    x = gui.MouseX(),
                    y = gui.MouseY(),

                    velX = math.Rand(-200,32),
                    velY = -math.Rand(200,300)
                }
            end

            hook.Add("DrawOverlay","Crino",function()
                local i = 1

                local dt = FrameTime()

                for iteration = 1,#listKinematicObject do
                    local object = listKinematicObject[i]
                    if not object then break end

                    object.x = object.x + object.velX * dt
                    object.y = object.y + object.velY * dt

                    object.velY = object.velY + 300 * dt

                    surface.SetMaterial(crino)
                    surface.SetDrawColor(255,255,255)
                    surface.DrawTexturedRectRotated(object.x,object.y,64,64,math.cos(RealTime() * 16 + i * 32) * 32)

                    if object.y - 64 > ScrH() then
                        table.remove(listKinematicObject,i)

                        continue
                    end

                    i = i + 1
                end
            end)

            local changeLanguage = oop.CreatePanel("v_panel"):ad(function(self,w,h)
                self:setSize(41,40):setPos(w - self:W() - changeGamemode:W() - 2,h - 45)
            end)
            changeLanguage:MakePopup()
            changeLanguage:SetMouseInputEnabled(false)
            GameUIRepeat.changeLanguage = changeLanguage

            function changeLanguage:Draw(w,h)
                clickThink(self,w,h)
            end
            function changeLanguage:OnMouse()
                GameUILanguageOpen = not GameUILanguageOpen
                GameUIGameContentOpen = false
            end

            local gameContent = oop.CreatePanel("v_panel"):ad(function(self,w,h)
                self:setSize(75,40):setPos(changeLanguage.x - self:W() - 2,h - 45)
            end)
            gameContent:MakePopup()
            gameContent:SetMouseInputEnabled(false)
            GameUIRepeat.gameContent = gameContent

            function gameContent:Draw(w,h)
                clickThink(self,w,h)
            end
            function gameContent:OnMouse()
                GameUIGameContentOpen = not GameUIGameContentOpen
                GameUILanguageOpen = false
            end
        else
            removeAll()

            hook.Remove("DrawOverlay","Crino")
        end
    end
end)

--language.GetPhrase("new_game")