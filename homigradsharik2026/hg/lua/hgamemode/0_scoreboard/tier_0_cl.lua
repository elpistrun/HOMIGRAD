scoreboard = scoreboard or {}
scoreboard.pages = scoreboard.pages or {}
scoreboard.listPages = {}

function scoreboard:Page_Reg(prio)
    scoreboard.pages[prio] = scoreboard.pages[prio] or {}

    return scoreboard.pages[prio]
end

function scoreboard:ListPagesUpdate()
    local list = {}

    for prio,page in pairs(self.pages) do
        if page.CanOpen and page.CanOpen() == false then continue end
        
        list[#list + 1] = {prio,page}
    end

    table.sort(list,function(a,b) return a[1] < b[1] end)

    self.listPages = list
end

scoreboard.curretPage = scoreboard.curretPage or 1
scoreboard.close = scoreboard.close or 0

local sizeButton = 38
local cornerButton = 16

scoreboard.sizeButton = sizeButton
scoreboard.cornerButton = cornerButton

event.Add("Screen Size","Scoreboard",function(mul)
    local sizeButton = 38 * mul
    local cornerButton = 16 * mul

    scoreboard.sizeButton = sizeButton
    scoreboard.cornerButton = cornerButton
end)

local defaultIconMat = Material("homigrad/vgui/models/circle.png")
local materialGlow = Material("homigrad/vgui/glow.png")
local PI = math.pi * 2

function scoreboard:CreateParticles()
    local particles = particles2D:Create()

    particles.gravity = {ScrW() * 0.5,0}
    particles.friction = 0.1

    particles.SetDrawFunction(function(part,ft,time)
        local col = 65 + math.max(15 * math.cos(part[1] / 64 - time * 3),0) + math.max(15 * math.sin(part[2] / 64 - time * 4),0)

        surface.SetDrawColor(col,col,col + 20,100)
        surface.DrawRect(part[1] - 1,part[2] - 1,2,2)
    end)

    --

    local particlesGlow = particles2D:Create()

    particlesGlow.gravity = {0,0}
    particlesGlow.friction = 0.5

    particlesGlow.SetDrawFunction(function(part,ft,time)
        local k = (part.start + 1 - time) / 1
        if k <= 0 then return false end--delete particle

        local col = 128

        local size = part.size * k

        surface.SetDrawColor(col,col,col,32 * k)
        surface.DrawTexturedRectRotated(part[1],part[2],size * 2,size * 2,0)

        local forceBack = part.forceBack

        part[3] = part[3] - (part[1] - part.setX) * ft * forceBack
        part[4] = part[4] - (part[2] - part.setY) * ft * forceBack
    end)

    return particles,particlesGlow
end

function scoreboard:Open()
    self:Remove()
    if not InitNET then return end

    chat.Close()
    
    self.status = true
    gui.EnableScreenClicker(true)

    local mainFrame = oop.CreatePanel("v_frame"):ad(function(self,w,h) self:setSize(w,h) end)

    self.mainFrame = mainFrame
    mainFrame:SetMouseInputEnabled(true)
    mainFrame:SetKeyBoardInputEnabled(false)
    mainFrame:SetZPos(-10)    

    local particles,particlesGlow = scoreboard:CreateParticles()

    function mainFrame:Draw(w,h)
        particles.Draw(w,h,FrameTime())

        if #particles.list >= 200 then return end
        particles.Add(w,math.random(0,h),-ScrW() * math.Rand(0.9,1.1) * 0.5,ScrH() * math.cos(RealTime() - particles.start) * 0.1)
    end

    local panelButtons = oop.CreatePanel("v_panel",mainFrame):ad(function(self,w,h) self:setSize(sizeButton + cornerButton * 2,h) end)
    panelButtons:SetZPos(256)
    self.panelButtons = panelButtons
    
    scoreboard.panelButtons = panelButtons
    
    function panelButtons:Draw(w,h)
        DisableClipping(true)
        surface.SetMaterial(materialGlow)
        particlesGlow.Draw(w,h,FrameTime())
        DisableClipping(false)
    end

    local panelPages = oop.CreatePanel("v_scrollpage",mainFrame):ad(function(self,w,h) self:setSize(w,h) end)
    self.panelPages = panelPages
    panelPages:SetHorizontal(false)
    panelPages.Lerp = 0.7

    function panelButtons:Update()
        self:Clear()
        
        local listPages = scoreboard.listPages

        local halfHeight = self:H() / 2 - (#listPages * (sizeButton + cornerButton)) / 2 + cornerButton / 2
        local x = 0

        for i = 1,#listPages do
            local info = listPages[i]
            local prioPage,page = info[1],info[2]

            local X = x
            local icon = oop.CreatePanel("v_button",self):ad(function(self,w,h) self:setSize(w,w):setPos(0,X + halfHeight) end)

            local delayParticle = 0
            local delayParticle2 = 0
            local oldActive

            icon.downStart = 0

            function icon:Draw(w,h)
                local isSelected = scoreboard.curretPage == prioPage
                if isSelected then self.hovered = -1.33 end

                if self.downStart > RealTime() then
                    self.hovered = LerpFT(0.5,self.hovered,-3)
                end

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
                        draw.SimpleText(L(page.Name),"HS22",size / 4 -cornerButton * math.max(self.hovered,0),h / 2,Color(255,255,255,255 * k),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
                        DisableClipping(false)
                    end
                end
            end

            function icon:OnClick()
                if scoreboard.curretPage == prioPage then
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

                scoreboard:OpenPage(prioPage)
            end

            x = x + icon:H()
        end

        local cw,ch = self:GetContentSize()

        self:setSize(w,ch)
    end

    function panelPages:Update()
        local change

        local oldList = scoreboard.listPages or {}

        scoreboard:ListPagesUpdate()

        local iteration = 0

        for i = 1,#oldList do
            iteration = iteration + 1

            local prio = oldList[iteration][1]

            if not scoreboard.listPages[iteration] or scoreboard.listPages[iteration][1] ~= prio then
                self:Pop(iteration,true)
                iteration = iteration - 1

                change = true
            end
        end

        for i = 1,#scoreboard.listPages do
            local info = scoreboard.listPages[i]
            local prio = info[1]

            local panel = scoreboard.pages[prio].panel

            if not IsValid(panel) then
                panel = self:Add(i)
                scoreboard.pages[prio].panel = panel
            else
                self:Add(i,panel)
            end
        end

        scoreboard:OpenPage(scoreboard.curretPage)

        return change
    end

    panelPages:Update()
    panelButtons:Update()
    scoreboard:Update()
    
    scoreboard:OpenPage(scoreboard.curretPage,true)
end

function scoreboard:Remove()
    if self.status then gui.EnableScreenClicker(false) end
    
    self.status = false

    local page = self.pages[self.curretPage]
    if page and self:PageIsCreated(self.curretPage) and page.Hovered then page.Hovered(false,true) end

    if IsValid(self.mainFrame) then
        vRemove(self.mainFrame)
        
        for prio,page in pairs(self.pages) do
            if IsValid(page.panel) then vRemove(page.panel) end
        end
    end
end

function scoreboard:Close()
    self.status = false

    gui.EnableScreenClicker(false)
end

function scoreboard:FindIterationByPrio(prio)
    for i = 1,#self.listPages do
        if self.listPages[i][1] == prio then return i end
    end
end

function scoreboard:OpenPage(prio,force)
    local page = self.pages[prio]

    if page.CanOpen and page.CanOpen() == false then
        self:FindFreePage(prio)

        return
    end

    if not force and self.curretPage == prio then return end

    local oldCurretPage = self.curretPage
    if oldCurretPage and self.pages[oldCurretPage].Hovered and self:PageIsCreated(oldCurretPage) then self.pages[oldCurretPage].Hovered(false) end

    self.curretPage = prio

    local panel = self.pages[prio].panel
    if not IsValid(panel) then return end

    local iteration = self:FindIterationByPrio(prio)
    if not iteration then return end

    if not self:PageIsCreated(prio) then
        page.Open(panel)
    end

    if page.Hovered then page.Hovered(true) end
    
    self.panelPages:Set(iteration,force)
end

function scoreboard:PageIsCreated(prio)
    local panel = scoreboard.pages[prio].panel
    if not IsValid(panel) then return false end

    return #panel:GetChildren() > 0
end

function scoreboard:FindFreePage()
    local oldCurretPage = self.curretPage
    if oldCurretPage and self.pages[oldCurretPage].Hovered and self:PageIsCreated(oldCurretPage) then self.pages[oldCurretPage].Hovered(false) end

    self.curretPage = 1
end

function scoreboard:Update()
    self.close = LerpFTLess(0.5,self.close,self.status and 1 or 0,0.05)
    
    if IsValid(self.panelButtons) then
        self.panelButtons:setPos(ScrW() - self.panelButtons:W() * self.close,0)
    end

    if self.status then gui.EnableScreenClicker(true) end
    
    if not self.status and self.close <= 0 then
        self:Remove()

        return
    end

    local page = self.pages[self.curretPage]

    if page.CanOpen and page.CanOpen() == false then
        scoreboard:FindFreePage()
    end
end

hook.Add("Think","Scoreboard",function() scoreboard:Update() end)

hook.Add("ScoreboardShow","HomigradOpenScoreboard",function()
    if scoreboard.status == true then
        if event.Call("Scoreboard Want Close") ~= false then
            scoreboard:Close()
        end
    elseif not scoreboard.status then
	    scoreboard:Open()
    end

	return false
end)

hook.Add("ScoreboardHide","HomigradHideScoreboard",function()
    return false
end)

if Initialize then scoreboard:Open() end

local color = Color(200,200,200,5)

hook.Add("HUDPaintBackground","Scoreboard",function()
    local w,h = ScrW(),ScrH()
    surface.SetDrawColor(15,15,15,230 * scoreboard.close)
    surface.DrawRect(0,0,w,h)

    DrawBlur(2,0,0)

    color.a = 5 * scoreboard.close
    draw.SimpleText("HOMIGRAD.COM","H.45",w/2,h/2,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    if scoreboard.close > 0 then
        showRoundInfo = RealTime() + 3.5
    end
end)

event.Add("Player Death","Scoreboard Close",function(ply)
    if ply == LocalPlayer() then
        scoreboard:Close()
    end
end)