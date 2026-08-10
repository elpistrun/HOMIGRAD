RTVVote = RTVVote or {}

local function sendVote(vote)
    net.Start("rtv vote")
    net.WriteString(vote)
    net.SendToServer()
end

local function CreateIconsPanel(frame,mapName)
    local iconSize = math.min(ScrH(),ScrW()) * 0.25

    local panel = oop.CreatePanel("v_avataricons",frame):ad(function(self,w,h) self:setSize(iconSize-mapManager.textH,iconSize-mapManager.textH):setPos(mapManager.textH/2,mapManager.textH) end)
    panel:SetMouseInputEnabled(false)

    /*local SIZE = 16

    for i,size in pairs({64,48,32,24,18}) do
        if size * 1.25 * (8 + 1) < panel:W() then SIZE = size break end
    end*/
    
    local SIZE = 16
    panel:Setup(SIZE)

    function panel:Update()
        self:Clear()
        
        for steamid,info in pairs(RTVVote[mapName]) do
            //for i = 1,8 do
                self:AddPanel(steamid,info.avatar,info.avatarFrame)
            //end
        end
    end

    frame.icons = panel
    return panel
end

local function getCount(vote)
    return tostring(math.floor(((RTVVoteNumber[vote] or 0) / (RTVVoteMax == 0 and 1 or RTVVoteMax)) * 100))
end

function RTVUI_CreateMapVote(page)
    local iconSize = math.min(ScrH(),ScrW()) * 0.25

    local panel = oop.CreatePanel("v_scrollpanel",page)
    panel:CreateHBar()
    panel:ad(function(self,w,h) self:setSize(w * 0.85,iconSize + mapManager.textH + self.hbar:H()):setPos(w/2 - self:W()/2,h * 0.2) end)//сомнительно,vbar будет после этой обработки..... мдем
    panel.scrolling = iconSize * 2

    //panel.hbar.Draw = function(self,w,h) end

    local hoverMap

    function panel:Draw(w,h)
        local hbar = self.hbar:H()
        h = h - hbar

        surface.SetDrawColor(255,255,255)
        surface.DrawRect(0,0,1,h)
        surface.DrawRect(w - 1,0,1,h)
    end

    local screenshoots = oop.CreatePanel("v_panel",page):ad(function(self,w,h) self:setSize(h * 0.85,h * 0.4):setPos(w/2 - self:W()/2,h * (0.95) - self:H()) end)

    local olderScreenshoot,curretScreenshoot
    local animSlideShow = 0

    function screenshoots:Draw(w,h)
        if not hoverMap then hoverMap = RTVLeaders[1] end
        local map = hoverMap
        hoverMap = nil

        if not map then return end
        if map == "extend" then map = game.GetMap() end
        if map == "random" then map = RTVGetRandomMap() end

        local screenshoots = RTVMapsAviable[map].screenshoots
        if not screenshoots or #screenshoots == 0 then return end

        for i,url in pairs(screenshoots) do
            GetHTTPMaterial(url)
        end
        
        screenshoots = screenshoots[math.ceil(CurTime()) % (#screenshoots)]

        local time = RealTime()

        if curretScreenshoot ~= screenshoots then
            olderScreenshoot = curretScreenshoot
            curretScreenshoot = screenshoots
            animSlideShow = time
        end

        local k = math.max(animSlideShow - time + 0.2,0) / 0.2

        surface.SetDrawColor(255,255,255,255 * (1 - k))
        DrawHTTPMaterialCenter(0,0,w,h,screenshoots)

        if olderScreenshoot then
            surface.SetDrawColor(255,255,255,255 * k)
            DrawHTTPMaterialCenter(0,0,w,h,olderScreenshoot)
        end

        draw.Frame(0,0,w,h,cframe1,cframe2)
    end

    local extend = oop.CreatePanel("v_button",page):ad(function(self,w,h) self:setSize(iconSize,iconSize + mapManager.textH):setPos(panel.x + panel:W() - self:W(),h * 0.55) end)
    CreateIconsPanel(extend,"extend")
    function extend:Draw(w,h)
        mapManager.DrawIcon(0,0,w,h,game.GetMap(),"CENTER")

        surface.SetDrawColor(0,0,0,225)
        surface.DrawRect(mapManager.textH/2,mapManager.textH,iconSize-mapManager.textH,iconSize-mapManager.textH)

        draw.SimpleText(getCount("extend") .. "%","HS.18",w/2,mapManager.textH/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        if self:IsHovered() then
            surface.SetDrawColor(255,255,255,5)
            surface.DrawRect(0,0,w,h)

            hoverMap = "extend"
        end

        draw.SimpleText("EXTEND","HS.45",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
    function extend:OnClick() sendVote("extend") end

    local random = oop.CreatePanel("v_button",page):ad(function(self,w,h) self:setSize(iconSize,iconSize + mapManager.textH):setPos(panel.x,h * 0.55) end)
    CreateIconsPanel(random,"random")

    function random:Draw(w,h)
        local time = RealTime()

        mapManager.DrawIcon(0,0,w,h,RTVGetRandomMap(),"CENTER")

        surface.SetDrawColor(0,0,0,225)
        surface.DrawRect(mapManager.textH/2,mapManager.textH,iconSize-mapManager.textH,iconSize-mapManager.textH)

        draw.SimpleText(getCount("random") .. "%","HS.18",w/2,mapManager.textH/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        if self:IsHovered() then
            surface.SetDrawColor(255,255,255,5)
            surface.DrawRect(0,0,w,h)
        end

        draw.SimpleText("RANDOM","HS.45",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
    function random:OnClick() sendVote("random") end

    //

    local oldCount = 0

    function page:Update()
        extend.icons:Update()
        random.icons:Update()

        local count = table.Count(RTVVote)
        
        if oldCount ~= count then
            panel:Clear()

            oldCount = count
            local pointX = 0

            for map,list in pairs(RTVVote) do
                if map == "extend" or map == "random" then continue end

                local x = pointX
                local icon = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(iconSize,h):setPos(x,0) end)
                icon.icon = CreateIconsPanel(icon,map)
                pointX = pointX + icon:W()//mdem

                function icon:Draw(w,h)
                    mapManager.DrawIcon(0,0,w,h,map,"CENTER")

                    draw.SimpleText(getCount(map) .. "%","HS.18",w/2,mapManager.textH/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

                    if self:IsHovered() then
                        surface.SetDrawColor(255,255,255,5)
                        surface.DrawRect(0,0,w,h)

                        hoverMap = map
                    end
                end
                function icon:OnClick() sendVote(map) end
            end
        end

        for i,child in pairs(panel.canvasPanel:GetChildren()) do
            child.icon:Update()
        end
    end
end

//if Initialize and LocalPlayer():SteamID() == "STEAM_0:1:164889146" then OpenRTV() end