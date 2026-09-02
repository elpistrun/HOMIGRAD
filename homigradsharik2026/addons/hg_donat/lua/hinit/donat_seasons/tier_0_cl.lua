local Page = scoreboard:Page_Reg(102)
Page.Name = "События"
Page.Icon = Material("homigrad/vgui/icons/season.png")

donatPanel.seasons = donatPanel.seasons or {}
donatPanel.curretSeasonPage = donatPanel.curretSeasonPage or nil

function donatPanel:SeasonPage_Reg(prio)
    donatPanel.seasons[prio] = donatPanel.seasons[prio] or {}

    return donatPanel.seasons[prio]
end

function donatPanel:SeasonListPagesUpdate()
    local list = {}

    for prio,page in pairs(self.seasons) do
        if page.CanOpen and page.CanOpen() == false then continue end
        
        list[#list + 1] = {prio,page}
    end

    table.sort(list,function(a,b) return a[1] < b[1] end)

    self.listSeasons = list
end

local back = Material("homigrad/vgui/icons/back.png","smooth")

local colorBlack = Color(0,0,0,100)

function Page.Open(frame)
    donatPanel:SeasonListPagesUpdate()

    local alphaPage = oop.CreatePanel("v_alphapage",frame):ad(function(self,w,h) self:setSize(w - scoreboard.sizeButton * 4 - scoreboard.cornerButton * 2,h * 0.8):setPos(w/2-self:W()/2,h/2-self:H()/2) end)
    
    local mainPage = alphaPage:Add("Main Page")

    mainPage:ad(function()
        mainPage:setSize(mainPage:W() * 0.8,mainPage:H() * 0.8)
    end)

    local buttonBack = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(64,64):setPos(alphaPage.x / 2 - self:W() / 2,alphaPage.y / 2 - self:H() / 2) end)

    function buttonBack:Draw(w,h)
        surface.SetMaterial(back)

        local size = h * 0.8 + h * 0.1 * self.hovered

        surface.SetDrawColor(0,0,0,200)
        surface.DrawTexturedRectRotated(w/2 + 6,h/2 + 6,size,size,0)

        surface.SetDrawColor(255,255,255)
        surface.DrawTexturedRectRotated(w/2,h/2,size,size,0)
    end

    function buttonBack:OnClick()
        donatPanel.curretSeasonPage = "Main Page"
        alphaPage:Set("Main Page")
    end

    function frame:Step()
        buttonBack:SetAlpha(255 - mainPage:GetAlpha())

        buttonBack:SetVisible(buttonBack:GetAlpha() > 0)
    end
    
    local max = #donatPanel.listSeasons
    local cornerWidth = 64
    local width = math.floor((math.floor(mainPage:W() - cornerWidth * (max - 1)) / max))

    local x = 0

    for i = 1,max do
        local info = donatPanel.listSeasons[i]
        local prio,page = info[1],info[2]

        local panel = alphaPage:Add(prio)

        local X = x

        local banner = oop.CreatePanel("v_button",mainPage):ad(function(self,w,h) self:setSize(width,h):setPos(X,0) end)
        
        function banner:Draw(w,h)
            page.Draw(w,h)
        end
        
        function banner:DrawOver(w,h)
            draw.SimpleText(page.Name,"H.25",w/2,h - 40,page.ColorText,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

            draw.SimpleText(page.Description,"H.14",w/2,h - 16,page.ColorText,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
        end

        function banner:OnClick()
            alphaPage:Set(prio)
            donatPanel.curretSeasonPage = prio
        end

        x = x + banner:W() + cornerWidth

        page.Open(panel,banner)
    end

    mainPage:ad(function(self,w,h)
        self:setSize(x - cornerWidth,mainPage:H())
        self:setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2)
    end)
    
    --

    alphaPage:Set(donatPanel.curretSeasonPage or "Main Page",true)

    local color_gold = donatPanel.color_gold

    local button = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(32,32) end)
    button:SetupDrawStyle("white"); button.text = "+"; button.font = "HS.25"

    function frame:Draw(w,h)
        render.SuppressEngineLighting(true)

        local data = balanceManager.listData[AccountSteamID64] or {}

        local balance = data.balance and donatPanel.XPToText(data.balance) or "loading" .. string.rep(".",RealTime() % 4)
        draw.SimpleText("Balance: " .. balance,"HS.25",alphaPage.x,alphaPage.y + alphaPage:H() + (h - (alphaPage.y + alphaPage:H())) / 2 - 15,nil,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

        local balance = data.balance_donat and donatPanel.XPToText(data.balance_donat) or "loading" .. string.rep(".",RealTime() % 4)
        
        local text = "Balane donat: " .. balance
        local x,y = alphaPage.x,alphaPage.y + alphaPage:H() + (h - (alphaPage.y + alphaPage:H())) / 2 + 15
        draw.SimpleText(text,"HS.25",x,y,color_gold,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
        
        local tw,th = surface.GetTextSize(text)
        button:setPos(x + tw + th / 2,y - th / 2)
    end

    function frame:DrawOver()
        render.SuppressEngineLighting(false)
    end
    
    function button:OnClick() gui.OpenURL("https://kopigrad.com/shop") end
end

function Page.Hovered(value)
    if value then inventoryNotificationManager:ShowNotification() end
end

donatPanel.Create3DParticles = function(banner,randomModels,mul)
    mul = mul or 1

    local particles = particles2D:Create()
    particles.friction = 0.1

    local container = CSM.GetContainer(tostring(banner))

    particles.SetDrawFunction(function(part)
        local time = particles.Time() / 3 + part.add

        local mdl = container.GetByID(randomModels[math.random(1,#randomModels)],tostring(particles) .. tostring(part))
        mdl:SetNoDraw(true)
        mdl:SetRenderOrigin(Vector((200 - part[1]) * mul,0,(400 - part[2]) * mul))
        mdl:SetRenderAngles(Angle(math.cos(part[2] / 300 + time) * 180,math.cos(part[2] / 300 + time) * 180,math.sin(part[2] / 300 + time) * 180))
        mdl:SetSkin(part.add % 2)
        mdl:DrawModel()
    end)

    function banner:Draw(w,h)
        PAGE.Draw(w,h)
    end

    local w,h = banner:W(),banner:H()

    for i = 1,25 do
        local part = particles.Add(math.random(0,w),math.random(0,h),math.random(-5,5),math.random(100,200))
        part.add = math.random(0,360)
    end

    banner:Event_Add("Remove","Remove3DParticles" .. tostring(container),function()
        container.Delete()
    end)

    return function(self,w,h)
        local x,y = self:LocalToScreen(0,0)
        cam.Start3D(Vector(0,500,0),(-Vector(0,100,0)):Angle(),40 * mul,x,y,w,h)
        particles.Draw(w,h,FrameTime())
        cam.End3D()

        if #particles.list < 25 then
            local part = particles.Add(math.random(0,w),0,math.random(-5,5),math.random(100,200))
            part.add = math.random(0,360)
        end
    end
end

--[[local PAGE = donatPanel:SeasonPage_Reg(100)
PAGE.Name = "Обычные предметы"
PAGE.Description = "Всегда доступны"

local color = Color(76,252,255)

function PAGE.Draw(w,h)
    surface.SetDrawColor(color.r / 2.5,color.g / 2.5,color.b / 2.5,125)
    surface.DrawRect(0,0,w,h)
    
    surface.SetDrawColor(color.r / 2,color.g / 2,color.b / 2,190)
    surface.SetBG("romb_d")
    draw.BG2(2,2,w - 4,h - 4)

    local size = h + h * math.max(math.cos(RealTime())) / 6

    surface.SetDrawColor(color.r,color.g,color.b,200)
    draw.GradientDown(0,h - size + 1,w,size)
end
]]--

--

--[[local PAGE = donatPanel:SeasonPage_Reg(1)
PAGE.Name = "Halloween"
PAGE.Description = "Обменяйте найденые конфеты, на дорогие костюмы!"

local color = Color(255,123,32)

function PAGE.Draw(w,h)
    surface.SetDrawColor(color.r / 2.5,color.g / 2.5,color.b / 2.5,125)
    surface.DrawRect(0,0,w,h)
    
    surface.SetDrawColor(color.r / 2,color.g / 2,color.b / 2,190)
    surface.SetBG("pletanka")
    draw.BG2(2,2,w - 4,h - 4)

    local size = h + h * math.max(math.cos(RealTime())) / 6

    surface.SetDrawColor(color.r,color.g,color.b,200)
    draw.GradientDown(0,h - size + 1,w,size)

    draw.Frame(0,0,w,h,cframe1,cframe2)
end

function PAGE.Open(frame,banner)
    local drawParticles = donatPanel.Create3DParticles(banner,randomModels)

    function banner:Draw(w,h)
        PAGE.Draw(w,h)
        drawParticles(self,w,h)

        local x,y = self:LocalToScreen(0,0)

        DrawBlur(3,x,y)

        cam.Start3D(Vector(0,500,0),(-Vector(0,100,0)):Angle(),6,x,y,w,h)
            local mdl = CSM.GetByID("models/pumpkin_1/pumpkin_1.mdl",tostring(self) .. "main")
            mdl:SetPos(Vector(4,100 + self.hovered * 5,-10))
            mdl:SetAngles(Angle(0,20,-20))
            mdl:DrawModel()
        cam.End3D()
    end

    local panel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w,h) end)
    
    function panel:Draw(w,h)
        surface.SetDrawColor(255,255,255,55)
        surface.DrawRect(0,0,w,h)
    end
end]]--

if Initialize then scoreboard:Open() end