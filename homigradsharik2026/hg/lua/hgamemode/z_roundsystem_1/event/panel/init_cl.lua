EventPanel_Pages = EventPanel_Pages or {}

EventPanel_Page = 1
EventPanel_SetPage = 1

function EventPanel_UICreate(frame)
    function frame:Draw(w,h)
        surface.SetDrawColor(20,20,20,64)
        draw.GradientDown(0,0,w,h)

        EventPanel_Page = LerpFTLess(0.25,EventPanel_Page,EventPanel_SetPage,0.001)
    end

    local backPage = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(200,50):setPos(30,30) end)
    backPage:SetupDrawStyle("white_gradient"); backPage.gradientSide = "left"; backPage.text = "BACK"; backPage.font = "HS.25"
    function backPage:OnClick() scoreboard.pages[6].SetPage(1) end

    local openWiki = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(200,50):setPos(w - self:W() - 30,30) end)
    openWiki:SetupDrawStyle("white_gradient"); openWiki.gradientSide = "right"; openWiki.text = "WIKI"; openWiki.font = "HS.25"
    function openWiki:OnClick() gui.OpenURL("https://homigrad.com/wiki/gamemodes/special/event/") end

    local panelPages = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w - math.max(300,w * 0.2) - 60,h * 0.8):setPos(30,(h - self:H()) / 2) end)
    function panelPages:Draw(w,h)
        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)
    end
    function panelPages:DrawOver(w,h)
        surface.SetDrawColor(255,255,255,15)
        surface.DrawRect(0,0,w,1)
        surface.DrawRect(0,h - 1,w,1)
    end

    local scrollNav = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(w - (panelPages.x + panelPages:W()),panelPages:H()):setPos(panelPages.x + panelPages:W(),panelPages.y) end)
    scrollNav:SetHighlightSide("left",true,60)
    scrollNav:CreateVBar()
    scrollNav:SetFont("HS.18")
    function scrollNav:Draw(w,h)
        surface.SetDrawColor(0,0,0,150)
        surface.DrawRect(0,0,w,h)
    end

    local scrollPage = oop.CreatePanel("v_scrollpage",panelPages):ad(function(self,w,h) self:setSize(w,h) end)
    scrollPage:SetHorizontal(false)
    function scrollPage:OnPage(id) EventPanel_SetPage = id end
    
    for i,page in pairs(EventPanel_Pages) do
        scrollNav:Add(L(page.Name),function()
            scrollPage:Set(i)
            
            EventPanel_Update(i)
        end)

        local panelPage = scrollPage:Add()
        page.panel = panelPage
        page.Create(panelPage)
    end

    scrollPage:Set(EventPanel_SetPage,true)
    scrollNav:Set(EventPanel_SetPage)
end

function EventPanel_Update(id)
    if id then
        local page = EventPanel_Pages[id]
        if IsValid(page.panel) and page.panel.Update then page.panel:Update() end
    else
        for i,page in pairs(EventPanel_Pages) do
            if IsValid(page.panel) and page.panel.Update then page.panel:Update() end
        end
    end
end

if Initialize then scoreboard:Open() end