local Panel = scoreboard:Page_Reg(6)

Panel.Name = "Event"
Panel.Page = 1

function Panel.Open(frame)
    Panel.panel = frame
    
    local panelVertical = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h) self:setSize(w * 0.9,h * 0.9):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2) end)
    panelVertical:SetHorizontal(false)
    Panel.panelVertical = panelVertical

    local panelHorizontal = oop.CreatePanel("v_scrollpage",panelVertical:Add()):ad(function(self,w,h) self:setSize(w,h) end)
    panelHorizontal:SetHorizontal(true)
    Panel.panelHorizontal = panelHorizontal

    function panelVertical:Draw(w,h)
        surface.SetDrawColor(0,0,0,75)
        surface.DrawRect(0,0,w,h)

        DrawBlurByPanel(5,self)
    end

    function panelVertical:DrawOver(w,h)
        draw.Frame(0,0,w,h,cframe1,cframe2)
    end

    local planingEvent = panelHorizontal:Add()
    local eventPanel = panelHorizontal:Add()
    local commentPanel = panelVertical:Add()
    frame.commentPanel = commentPanel
    
    local playersTimePanel = panelVertical:Add()
    frame.playersTimePanel = playersTimePanel

    function frame:Step()
        if Panel.Page == 2 then
            if not eventPanel.create then
                eventPanel.create = true
                EventPanel_UICreate(eventPanel)
            end
        elseif Panel.Page == 1 then
            if not planingEvent.create then
                planingEvent.create = true
                EventPlaning_UICreate(planingEvent)
            end
        elseif Panel.Page == 3 then
            if not commentPanel.create then
                commentPanel.create = true
                EventComment_UICreate(commentPanel)
            end
        elseif Panel.Page == 4 then
            if not playersTimePanel.create then
                playersTimePanel.create = true
                EventPlayersTime_UICreate(playersTimePanel)
            end
        end
    end

    Panel.SetPage(Panel.Page,true)
    panelHorizontal:Step()
end

function Panel.SetPage(value,fast)
    Panel.Page = value

    if value == 1 then
        Panel.panelHorizontal:Set(1,fast)
        Panel.panelVertical:Set(1,fast)
    elseif value == 2 then
        Panel.panelHorizontal:Set(2,fast)
        Panel.panelVertical:Set(1,fast)
    elseif value == 3 then
        Panel.panelVertical:Set(2,fast)

        local panel = Panel.panel.commentPanel
        if IsValid(panel) and panel.Update then panel:Update() end
    elseif value == 4 then
        Panel.panelVertical:Set(3,fast)

        local panel = Panel.panel.playersTimePanel
        if IsValid(panel) and panel.Update then panel:Update() end
    end
end

if Initialize then scoreboard:Open() end
