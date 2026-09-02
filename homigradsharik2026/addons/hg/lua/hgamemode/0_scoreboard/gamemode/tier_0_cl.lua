local Panel = scoreboard:Page_Reg(4)
Panel.Name = "gamemode"
Panel.list = Panel.list or {}
Panel.Icon = Material("homigrad/vgui/icons/gamemodes.png","smooth")

function Panel.Open(frame)
    local pagesHorizontal = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h) self:setSize(w * 0.85,h * 0.85):setPos(w/2-self:W()/2,h/2-self:H()/2) end)
    pagesHorizontal:SetHorizontal(true)

    local navButtons = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(pagesHorizontal:W(),40):setPos(pagesHorizontal.x,pagesHorizontal.y - self:H()) end)
    navButtons:SetHighlightSide("bottom")
    navButtons:SetupDrawStyle("whitebox")

    for i,page in pairs(Panel.list) do
        local panel = pagesHorizontal:Add()
        page.panel = panel
        page.Open(panel)

        local butt = navButtons:Add(L(page.Name),function() pagesHorizontal:Set(i) Panel.selectPage = i end)
        butt:SetupDrawStyle("white_gradient"); butt.gradientSide = "bottom"; butt.font = "HS.18"
    end

    if Panel.selectPage then
        pagesHorizontal:Set(Panel.selectPage,true)
        navButtons:Set(Panel.selectPage)
    end
end

if Initialize then scoreboard:Open() end