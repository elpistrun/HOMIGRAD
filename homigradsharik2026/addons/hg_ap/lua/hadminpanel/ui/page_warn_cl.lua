AdminPanelPages[5] = AdminPanelPages[5] or {}
local Page = AdminPanelPages[5]

Page.Name = "Варны"

function Page.CanOpen()
    return LocalPlayer():HasSuccess("warn_list")
end

local iconSize = 50

local function OnClick(steamid64)
    local steamProfile = Profiles[steamid64]

    local menu = DermaMenu()
    menu:AddOption(L("copy_steamid64"),function()
        chat.AddText(steamid64)
        SetClipboardText(steamid64)
    end)

    if steamProfile then
        menu:AddOption(L("copy_nickname"),function()
            chat.AddText(steamProfile.name)
            SetClipboardText(steamProfile.name)
        end)
    end

    menu:AddOption(L("open_profile"),function() gui.OpenURL("https://steamcommunity.com/profiles/" .. steamid64 .. "/") end)

    menu:Open()
end

function Page.Open(frame)
    local panel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w,h) end)

    local scrollPage = oop.CreatePanel("v_scrollpage",panel):ad(function(self,w,h) self:setPos(0,40):setSize(w,h - self.y) end)
    scrollPage:SetHorizontal(true)

    local pagePlayers = scrollPage:Add()
    local pageWarns = scrollPage:Add()

    local listPlayers
    local textEntry = oop.CreatePanel("v_textentry",pagePlayers):ad(function(self,w,h) self:setSize(w,30) end)
    textEntry:SetPlaceholderText(L("ap_ui_find_caller"))
    local filterCaller = ""
    function textEntry:OnChange()
        filterCaller = self:GetValue()
        timer.Create("filterCaller",0.1,1,function()
            listPlayers:Update()
        end)
    end

    listPlayers = oop.CreatePanel("v_scrollpanel",pagePlayers):ad(function(self,w,h) self:setPos(0,textEntry:H()):setSize(w,h - self.y) end)
    listPlayers:CreateVBar()
    listPlayers.scrolling = 300
    
    function pageWarns:SetChoice(steamid)
        self.choice = steamid

        self:Update()
    end

    function pageWarns:Update()
        self:Clear()
        
        if not self.choice then
            scrollPage:Set(1)
            
            return
        end

        local buttBack = oop.CreatePanel("v_button",self):ad(function(self,w,h) self:setSize(w,60) end)
        buttBack:SetupDrawStyle("white"); buttBack.text = "Назад"; buttBack.font = "HS.25"
        function buttBack:OnClick() pageWarns:SetChoice() end

        scrollPage:Set(2)

        local scrollPanel = oop.CreatePanel("v_scrollpanel",self):ad(function(self,w,h) self:setPos(0,buttBack:H()):setSize(w,h - self.y) end)
        scrollPanel:CreateVBar()
        
        local list = {}

        for i,warn in pairs(adminPanelWarn.list[self.choice]) do
            list[#list + 1] = warn
        end

        table.sort(list,function(a,b) return tonumber(a.timestamp_create) >= tonumber(b.timestamp_create) end)

        local avatar = oop.CreatePanel("v_avatarlist",scrollPanel):ad(function(self,w,h) self:setSize(w * 0.3,iconSize * 0.25 + table.Count(list) * (iconSize + iconSize * 0.25)) end)
        avatar:Setup(iconSize)

        pageWarns.avatar = avatar

        local i = 1

        for id,warnInfo in pairs(list) do
            local steamid64 = warnInfo.who
            local profile = Profiles[steamid64]

            local butt

            if profile then
                butt = avatar:AddPanel(steamid64,profile.name or steamid64,profile.avatar,profile.avatarFrame,profile.background,profile.backgroundOpacity)
            else
                butt = avatar:AddPanel(steamid64,steamid64,nil,nil,who)
            end
            
            function butt:Draw(w,h)
                surface.SetDrawColor(0,0,0,100)
                surface.DrawRect(0,0,w,h)
            end
            
            function butt:OnClick()
                OnClick(steamid64)
            end

            local I = i
            i = i + 1
            
            local reason = utf8.sub(warnInfo.reason,1,30)

            local butt = oop.CreatePanel("v_panel",scrollPanel):ad(function(self,w,h) self:setPos(avatar:W(),iconSize * 0.25 + (iconSize + iconSize * 0.25) * (I - 1)):setSize(w - self.x - iconSize * 0.25,iconSize) end)
            function butt:Draw(w,h)
                surface.SetDrawColor(0,0,0,100)
                surface.DrawRect(0,0,w,h)

                draw.SimpleText(warnInfo.count,"HS.12",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)
                draw.SimpleText(os.date("%d.%m.%Y - %H:%M",tonumber(warnInfo.timestamp_create)),"HS.12",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                draw.SimpleText(reason,"HS.12",w - h/2,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

                self:DrawTip(warnInfo.reason,1)
            end

            function butt:OnClick()
                OnClick(self.choice)
            end
        end
    end

    local avatar = oop.CreatePanel("v_avatarlist",listPlayers):ad(function(self,w,h) self:setSize(w,iconSize + iconSize * 0.5) end)
    avatar:Setup(iconSize)
    avatar:SetScrollPanel(listPlayers)

    function listPlayers:Update()
        avatar:Clear()

        local list = {}

        for steamid64,warnList in pairs(adminPanelWarn.list or {}) do
            local first = 0

            for _,warn in pairs(warnList) do
                first = math.max(first,tonumber(warn.timestamp_create))
            end

            list[#list + 1] = {steamid64,first}
        end
        
        table.sort(list,function(a,b)
            return a[2] >= b[2]
        end)

        for i,steamid64 in pairs(list) do
            steamid64 = steamid64[1]
            
            local info = adminPanelWarn.list[steamid64]

            if filterCaller != "" and steamid64 != filterCaller then continue end

            local profile = Profiles[steamid64]

            local butt

            if profile then
                butt = avatar:AddPanel(steamid64,profile.name or steamid64,profile.avatar,profile.avatarFrame,profile.background,profile.backgroundOpacity)
            else
                butt = avatar:AddPanel(steamid64,nil,nil,nil,who)
            end

            local count = table.Count(info)
            local curretCount = 0

            for i,warnInfo in pairs(info) do
                curretCount = curretCount + tonumber(warnInfo.count)
            end

            function butt:Draw(w,h)
                surface.SetDrawColor(0,0,0,100)
                surface.DrawRect(0,0,w,h)

                if self:IsHovered() then
                    surface.SetDrawColor(255,255,255,15)
                    surface.DrawRect(0,0,w,h)
                end

                draw.SimpleText(curretCount,"HS.18",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)
                draw.SimpleText(count,"HS.18",w - h/2,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
            end

            function butt:OnClick(key)
                if key == MOUSE_RIGHT then
                    OnClick(steamid64)
                else
                    pageWarns:SetChoice(steamid64)
                end
            end
        end
    end

    local count = 0

    function panel:Draw(w,h)
        surface.SetDrawColor(175,175,255,55)
        surface.DrawRect(0,0,w,40)
        surface.SetDrawColor(175,175,255,255)

        draw.GradientRight(0,0,w/2,40)
        draw.GradientLeft(w/2,0,w - w/2,40)

        if scrollPage.setPage == 1 then
            draw.SimpleText(L("ap_ui_db_count",count),"HS.18",20,20,nil,nil,TEXT_ALIGN_CENTER)
            draw.SimpleText("Текущие количество варнов","HS.18",iconSize + iconSize * 0.5 + iconSize/2,20,nil,nil,TEXT_ALIGN_CENTER)
            draw.SimpleText("Имя","HS.18",iconSize * 0.33 + w/2,20,nil,nil,TEXT_ALIGN_CENTER)
            draw.SimpleText("Всего было выдано","HS.18",w - iconSize * 0.33 - iconSize/2,20,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        else
            local avatar = pageWarns.avatar

            draw.SimpleText("Кто выдал","HS.18",avatar:W()/2 - iconSize * 0.25/2,20,nil,nil,TEXT_ALIGN_CENTER)
            draw.SimpleText("Выдано варнов","HS.18",avatar:W() + iconSize/2,20,nil,nil,TEXT_ALIGN_CENTER)
            draw.SimpleText("Дата выдачи","HS.18",avatar:W() + (w - avatar:W())/2,20,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            draw.SimpleText("Причина","HS.18",w - iconSize/2 - iconSize * 0.25,20,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        end
    end

    function frame:Update()
        listPlayers:Update()
        pageWarns:Update()

        count = table.Count(AdminPanelWarnList or {})
    end

    frame:Update()
end

//if Initialize then RunConsoleCommand("adminpanel_menu") end
