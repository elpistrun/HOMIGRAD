local Page = scoreboard:Page_Reg(1000)
Page.Name = "settings"
Page.Icon = Material("homigrad/vgui/icons/settings.png","smooth")

local SetDrawColor,DrawRect = surface.SetDrawColor,surface.DrawRect

Page.pages = Page.pages or {}
Page.curretPage = Page.curretPage or 1

local corner = 32

function Page.Open(frame)
    local panel = vCreate("v_panel",frame):ad(function(self,w,h) self:setSize(w - scoreboard.sizeButton * 4 - scoreboard.cornerButton * 2,h * 0.8):setPos(w/2-self:W()/2,h/2-self:H()/2) end)

    local scrollnav = vCreate("v_scrollnav",panel):ad(function(self,w,h) self:setSize(200,h) end)
    scrollnav:SetHighlightSide("left",nil,50)

    local panelInfo = vCreate("v_panel",panel):ad(function(self,w,h) self:setSize(w / 3.5,h):setPos(w - self:W(),0) end)
    local panelImage = vCreate("v_panel",panelInfo):ad(function(self,w,h) self:setSize(w,w) end)

    function panelInfo:DrawOver(w,h)
        surface.SetDrawColor(255,255,255)
        surface.DrawRect(w - 1,0,1,h)
        
        local itemPanel = self.item
        if not itemPanel then return end

        local mark = markup.Parse('<font=H22>' .. itemPanel.info.description .. "</font>",self:W())
        mark:Draw(0,panelImage:H() + 8)
    end

    function panelImage:Draw(w,h)
        local itemPanel = panelInfo.item
        if not itemPanel then return end

        if itemPanel.info.DrawImage then
            itemPanel.info.DrawImage(self,w,h)
        elseif itemPanel.info.getImage then
            surface.SetDrawColor(255,255,255)
            surface.SetMaterial(itemPanel.info.getImage(itemPanel.cvar and GetConVar(itemPanel.cvar):GetString()))
            surface.DrawTexturedRect(0,0,w,h)
        end
    end

    function panelInfo:SetItem(item)
        self.item = item and item
    end

    local scrollpage = vCreate("v_scrollpage",panel):ad(function(self,w,h) self:setSize(w - scrollnav:W() - panelInfo:W() - corner * 2 + 20,h):setPos(scrollnav:W() + corner) end)
    scrollpage:SetHorizontal(false)

    function scrollpage:DrawOver(w,h)
        surface.SetDrawColor(255,255,255)
        surface.DrawRect(0,0,1,h)

        surface.SetDrawColor(0,0,0,200)
        surface.DrawRect(1,0,1,h)
    end

    for i,page in pairs(Page.pages) do
        local pagePanel,id = scrollpage:Add()

        local scrollpanel = vCreate("v_settings",pagePanel):ad(function(self,w,h) self:setSize(w,h) end)
        scrollpanel.scrolling = 200
        scrollpanel:CreateVBar()
        scrollpanel.canvasW = scrollpanel:W() - 20

        page.Open(scrollpanel,panelInfo)

        function scrollpanel:WantUnFocus(panel)
            if panel:HasParent(panelInfo) then return false end
            end

        function scrollpanel:OnFocus(item)
            panelInfo:SetItem(item)
        end

        function scrollpanel:OnUnFocus(item)
            panelInfo:SetItem()
        end

        local button = scrollnav:Add(L(page.Name or i),function()
            scrollpage:Set(id)
            Page.curretPage = id
        end)

        button.font = "H.25"
        button:SetupDrawStyle("white")
    end

    scrollnav:Set(Page.curretPage,true)
    scrollpage:Set(Page.curretPage,true)
end

if Initialize then scoreboard:Open() end