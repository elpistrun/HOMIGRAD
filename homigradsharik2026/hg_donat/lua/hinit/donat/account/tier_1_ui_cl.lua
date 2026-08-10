local Page = donatPanel:Page_Reg(1)
Page.Name = "Account"
Page.Icon = Material("homigrad/vgui/icons/user.png")

Page.pages = Page.pages or {}
Page.curretPage = Page.curretPage or 1

function Page.Reg_Page(id)
    Page.pages[id] = Page.pages[id] or {}
    
    return Page.pages[id]
end

function Page.Open(frame)
    local avatarFrame = oop.CreatePanel("v_panel",frame)
    avatarFrame:ad(function(self,w,h) avatarFrame:setSize(w * 0.3,h * 0.9):setPos(0,h / 2 - self:H() / 2)  end)

    local iconSize = 48

    local avatarHTML = oop.CreatePanel("v_avatarlist",avatarFrame):ad(function(self,w,h) self:setSize(w,iconSize + iconSize * 0.5) end)
    avatarHTML.fontSize = scoreboard.playerFontSize
    avatarHTML:Setup(iconSize)
    Page.avatarHTML = avatarHTML

    function avatarHTML:Update()
        avatarHTML:Clear()

        local panelHTML,avatar = avatarHTML:AddPlayer(LocalPlayer())

        function panelHTML:Draw(w,h)
            scoreboard.DrawPlayer(LocalPlayer(),w,h,{dontDrawTeam = true,dontDrawAlive = true},self)
        end

        function avatar:Draw(w,h)
            local profile = Profiles[AccountSteamID64] or {}
            local col = profile.color or Color(255,255,255)
            col = Color(col.r,col.g,col.b,64)

            surface.SetDrawColor(col)
            surface.SetFigure("circle")
            local force = 1

            --DisableClipping(true)
            draw.Figure(w/2,h/2,w * force,h * force)
            --DisableClipping(false)
        end
    end

    avatarHTML:Update()

    local avatarModel = oop.CreatePanel("v_playermodel",avatarFrame):ad(function(self,w,h) self:setSize(w,h - avatarHTML:H()):setPos(0,avatarHTML:H()) end)
    avatarModel.fakePly:SetModel(LocalPlayer():GetModel())
    avatarModel.mdl = avatarModel.fakePly:GetCSM()

    avatarModel.fovMax = 25
    avatarModel.cameraFOV = avatarModel.fovMax
    Page.avatarModel = avatarModel

    function avatarModel:DrawOver(w,h)
        surface.SetDrawColor(255,255,255,25)
        draw.GradientRight(0,0,w / 2,1)
        surface.SetDrawColor(55,55,55,25)
        draw.GradientLeft(0,0,w / 2,1)
        
        surface.SetDrawColor(255,255,255,25)
        draw.GradientLeft(w / 2,0,w / 2,1)
        surface.SetDrawColor(55,55,55,25)
        draw.GradientRight(w / 2,0,w / 2,1)

        surface.SetDrawColor(255,255,255,25)
        draw.GradientRight(0,h - 1,w / 2,1)
        surface.SetDrawColor(55,55,55,25)
        draw.GradientLeft(0,h - 1,w / 2,1)

        surface.SetDrawColor(255,255,255,25)
        draw.GradientLeft(w / 2,h - 1,w / 2,1)
        surface.SetDrawColor(55,55,55,25)
        draw.GradientRight(w / 2,h - 1,w / 2,1)
    end

    local panelButtons = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setPos(ScrW() * 0.4,avatarFrame.y + iconSize * 0.25 / 2):setSize(w - self.x,scoreboard.sizeButton) end)
    panelButtons:SetHighlightSide("bottom")

    local panelPages = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h) self:setPos(panelButtons.x,panelButtons.y + panelButtons:H()):setSize(panelButtons:W(),avatarFrame:H() - panelButtons:H()) end)
    Page.panelPages = panelPages
    panelPages:SetHorizontal(true)

    for i,page in pairs(Page.pages) do
        local pagePanel = panelPages:Add()
        page.panel = pagePanel

        panelButtons:Add(page.Name,function()
            Page.OpenPage(i)
        end):SetupDrawStyle("white_gradient")
        
        page.Open(pagePanel)
    end

    Page.OpenPage(Page.curretPage,true)
    panelButtons:Set(Page.curretPage,true)
end

function Page.OpenPage(prio,fast)
    Page.curretPage = prio

    if IsValid(Page.panelPages) then
        Page.panelPages:Set(prio,fast)
    end
end

if Initialize then scoreboard:Open() end