hook.Add("InitPostEntity","AccountSteamID64",function()
    AccountSteamID64 = LocalPlayer():SteamID64()
end)

local Page = scoreboard:Page_Reg(101)
Page.list = Page.list or {}
Page.Name = "account"
Page.Icon = Material("homigrad/vgui/icons/user.png")

donatPanel = donatPanel or {}
donatPanel.pages = donatPanel.pages or {}
donatPanel.listPages = donatPanel.listPages or {}
donatPanel.curretPage = donatPanel.curretPage or 1

function donatPanel:Page_Reg(id)
    donatPanel.pages[id] = donatPanel.pages[id] or {}

    return donatPanel.pages[id]
end

function donatPanel:ListPagesUpdate()
    local list = {}

    for prio,page in pairs(self.pages) do
        if page.CanOpen and page.CanOpen() == false then continue end
        
        list[#list + 1] = {prio,page}
    end

    table.sort(list,function(a,b) return a[1] < b[1] end)

    self.listPages = list
end

local defaultIconMat = Material("homigrad/vgui/models/circle.png")
local materialGlow = Material("homigrad/vgui/glow.png")
local PI = math.pi * 2

donatPanel.color_gold = Color(255,255,125)

function Page.Open(frame)
    AccountSteamID64 = LocalPlayer():GetAccountID()
    
    local color_gold = donatPanel.color_gold

    local sizeButton,cornerButton = scoreboard.sizeButton,scoreboard.cornerButton

    local panelButtons = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(sizeButton + cornerButton * 2,self:H()):setPos(0,h / 2 - self:H() / 2 + cornerButton) end)
    panelButtons:setSize(panelButtons:W(),(sizeButton + cornerButton * 2) * #donatPanel.listPages)
    panelButtons:SetZPos(100)

    local particles,particlesGlow = scoreboard:CreateParticles()
    particles.gravity = {-ScrW() * 0.5,0}

    function panelButtons:Draw(w,h)
        DisableClipping(true)
        surface.SetMaterial(materialGlow)
        particlesGlow.Draw(w,h,FrameTime())
        DisableClipping(false)
    end

    local panelPages = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h) self:setSize(w - scoreboard.sizeButton * 4 - scoreboard.cornerButton * 2,h * 0.8):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2) end)
    donatPanel.panelPages = panelPages
    panelPages:SetHorizontal(false)

    local button = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(32,32) end)
    button:SetupDrawStyle("white"); button.text = "+"; button.font = "HS.25"

    function frame:Draw(w,h)
        particles.Draw(w,h,FrameTime())

        local data = balanceManager.listData[AccountSteamID64] or {}

        local balance = data.balance and donatPanel.XPToText(data.balance) or "loading" .. string.rep(".",RealTime() % 4)
        draw.SimpleText("Balance: " .. balance,"HS.25",panelPages.x,panelPages.y + panelPages:H() + (h - (panelPages.y + panelPages:H())) / 2 - 15,nil,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

        local balance = data.balance_donat and donatPanel.XPToText(data.balance_donat) or "loading" .. string.rep(".",RealTime() % 4)

        local text = "Balane donat: " .. balance
        local x,y = panelPages.x,panelPages.y + panelPages:H() + (h - (panelPages.y + panelPages:H())) / 2 + 15
        draw.SimpleText(text,"HS.25",x,y,color_gold,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

        local tw,th = surface.GetTextSize(text)
        button:setPos(x + tw + th / 2,y - th / 2)

        if #particles.list >= 200 then return end
        particles.Add(0,math.random(0,h),ScrW() * math.Rand(0.9,1.1) * 0.5,ScrH() * math.cos(RealTime() - particles.start) * 0.1)
    end

    function button:OnClick() gui.OpenURL("https://kopigrad.com/shop") end

    --

    donatPanel:ListPagesUpdate()
    
    for i = 1,#donatPanel.listPages do
        local prioPage,page = donatPanel.listPages[i][1],donatPanel.listPages[i][2]

        local icon = oop.CreatePanel("v_button",panelButtons):ad(function(self,w,h) self:setSize(w,w):setPos(0,self:H() * (i - 1)) end)

        local delayParticle = 0

        function icon:Draw(w,h)
            local isSelected = donatPanel.curretPage == prioPage
            if isSelected then self.hovered = -1.33 end

            self.hoveredMouse = LerpFT(0.5,self.hoveredMouse or 0,self:IsHovered() and 1 or 0)
            
            if page.DrawIcon then
                page.DrawIcon(w,h)
            else
                local size = sizeButton + cornerButton * 0.6 * self.hovered

                surface.SetMaterial(materialGlow)

                if isSelected then
                    surface.SetDrawColor(125,125,125,64)
                else
                    surface.SetDrawColor(125,125,125,16)
                end

                surface.DrawTexturedRectRotated(w/2,h/2,sizeButton + cornerButton * 2,sizeButton + cornerButton * 2,0)

                surface.SetMaterial(page.Icon or defaultIconMat)
                surface.SetDrawColor(255,255,255)
                surface.DrawTexturedRectRotated(w/2,h/2,size,size,0)

                if self:IsHovered() then
                    if delayParticle < RealTime() then
                        delayParticle = RealTime() + 1 / 10

                        local x,y = self.x + w/2,self.y + h/2

                        local part = particlesGlow.Add(x,y,math.cos(math.Rand(-PI,PI)) * 64,math.sin(math.Rand(-PI,PI)) * 64)
                        part.setX = x
                        part.setY = y
                        part.size = math.random(sizeButton,sizeButton)
                        part.start = particlesGlow.Time()
                        part.forceBack = 64
                    end
                end

                local k = math.max(self.hovered,self.hoveredMouse)

                if k > 0 then
                    DisableClipping(true)
                    draw.SimpleText(L(page.Name),"HS.18",size + cornerButton * 2,h / 2,Color(255,255,255,255 * k),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
                    DisableClipping(false)
                end
            end
        end

        function icon:OnClick()
            if donatPanel.curretPage == prioPage then
                sound.EmitScreen("homigrad/vgui/buttonrollover.wav",0.2,100)
            else
                sound.EmitScreen("homigrad/vgui/csgo_ui_contract_type4.wav",0.2,100)

                self.downStart = RealTime() + 1 / 10
            end

            local x,y = self.x + self:W()/2,self.y + self:H()/2

            for i = 1,math.random(8,16) do
                local part = particlesGlow.Add(x,y,math.cos(math.Rand(-PI,PI)) * 256,math.sin(math.Rand(-PI,PI)) * 256)
                part.setX = x
                part.setY = y
                part.size = math.random(4,6)
                part.start = particlesGlow.Time()
                part.forceBack = 16
            end

            donatPanel:OpenPage(prioPage)
        end

        page.panel = panelPages:Add()
    end

    donatPanel:OpenPage(donatPanel.curretPage,true)
end

function Page.Hovered(value)
    if not value then
        donatPanel:Remove()
    else
        inventoryNotificationManager:ShowNotification()
    end
end

function donatPanel:Remove()
    for prio,page in pairs(self.pages) do
        if IsValid(page) then page:Remove() end--облегчаем работу мусорщика
    end
end

function donatPanel:FindIterationByPrio(prio)
    for i = 1,#self.listPages do
        if self.listPages[i][1] == prio then return i end
    end
end

function donatPanel:PageIsCreated(prio)
    local panel = self.pages[prio] and self.pages[prio].panel
    if not IsValid(panel) then return false end

    return #panel:GetChildren() > 0
end

function donatPanel:OpenPage(prio,fast)
    self.curretPage = prio

    local panel = self.pages[prio].panel
    if not IsValid(panel) then return end

    local iteration = self:FindIterationByPrio(prio)
    if not iteration then return end

    if not IsValid(donatPanel.panelPages) then return end

    donatPanel.panelPages:Set(iteration,fast)

    if not self:PageIsCreated(prio) then
        self.pages[prio].Open(panel)
    end
end

if Initialize then scoreboard:Open() end