AdminPanelPages[4] = AdminPanelPages[4] or {}
local Page = AdminPanelPages[4]

Page.Name = "ap_ui_ban"

function Page.CanOpen()
    return LocalPlayer():HasSuccess("ban_list")
end

local function OnClick(info,callback,callback2)
    local steamid64 = info.steamid64

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

    menu:AddOption(L("ap_ui_delete_from_table"),function() callback() end)
    menu:AddOption(L("open_profile"),function() gui.OpenURL("https://steamcommunity.com/profiles/" .. steamid64 .. "/") end)

    if info.content.info then
        menu:AddOption("copy info",function()
            SetClipboardText(info.content.info)
        end)
    end

    menu:Open()
end

local iconSize = 56
local empty = {}

local function createPage(page,nameTable,onclick)
    local scrollPanelWho = oop.CreatePanel("v_scrollpanel",page):ad(function(self,w,h) self:setSize(w/4,h - 70):setPos(0,70) end)
    function scrollPanelWho:Draw(w,h)
        surface.SetDrawColor(64,64,128,16)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(64,64,128,32)
        draw.GradientLeft(0,0,w,h)
    end

    local scrollPanel = oop.CreatePanel("v_scrollpanel",page):ad(function(self,w,h) self:setPos(scrollPanelWho:W(),70):setSize(w - scrollPanelWho:W(),h - 70) end)
    scrollPanel:CreateVBar()
    scrollPanel.scrolling = 200
    function scrollPanel:Draw(w,h)
        surface.SetDrawColor(64,64,128,16)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(64,64,128,32)
        draw.GradientLeft(0,0,w,h)
    end
    
    scrollPanelWho:LinkScrollPanel(scrollPanel)

    local playersListWho = oop.CreatePanel("v_avatarlist",scrollPanelWho)
    playersListWho:Setup(iconSize)
    playersListWho:SetScrollPanel(scrollPanelWho)

    local playersList = oop.CreatePanel("v_avatarlist",scrollPanel)
    playersList:Setup(iconSize)
    playersList:SetScrollPanel(scrollPanel)

    local searchCaller = oop.CreatePanel("v_textentry",page):ad(function(self,w,h) self:setSize(scrollPanelWho:W(),30):setPos(0,40) end)
    searchCaller:SetPlaceholderText(L("ap_ui_find_caller"))
    local filterCaller = ""
    function searchCaller:OnChange()
        filterCaller = self:GetValue()
        timer.Create("filterCaller",0.1,1,function()
            page:Update()
        end)
    end

    local searchSteamID = oop.CreatePanel("v_textentry",page):ad(function(self,w,h) self:setSize(playersList:W()/2,30):setPos(w - self:W(),40) end)
    searchSteamID:SetPlaceholderText(L("ap_ui_find_steamid32"))
    local filterSteamID = ""
    function searchSteamID:OnChange()
        filterSteamID = self:GetValue()
        timer.Create("filterSteamID",0.1,1,function()
            page:Update()
        end)
    end

    local count = 0

    function page:Draw(w,h)
        surface.SetDrawColor(175,175,255,55)
        surface.DrawRect(0,0,w,40)
        surface.SetDrawColor(175,175,255,255)

        local wScroll = playersListWho:W()
        draw.GradientRight(0,0,wScroll,40)
        draw.GradientLeft(wScroll,0,w - wScroll,40)

        draw.SimpleText(L("ap_ui_db_count",count),"HS.18",20,20,nil,nil,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("ap_ui_caller"),"HS.18",(iconSize + iconSize * 0.25 + wScroll)/2,20,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("ap_ui_user"),"HS.18",wScroll + (w - wScroll + iconSize + iconSize * 0.25)/2,20,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("ap_ui_reason"),"HS.18",w - 20 - iconSize * 0.25,20,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("ap_ui_start"),"HS.18",wScroll + iconSize + iconSize * 0.25 * 3 + 20,20,nil,nil,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("ap_ui_start_endless"),"HS.18",wScroll + iconSize * 0.25 * 3 + 20 + (w - wScroll)* 0.25,20,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    function page:Update()
        playersList:Clear()
        playersListWho:Clear()
        
        local listData = (_G[nameTable] or empty).list or empty

        count = table.Count(listData)
        
        local list = {}

        for steamid,info in pairs(listData) do
            list[#list + 1] = {steamid,info}
        end

        table.sort(list,function(a,b) return tonumber(a[2].timestamp_create) > tonumber(b[2].timestamp_create) end)

        for i,info in pairs(list) do
            local steamid64 = info[1]
            info = info[2]

            local who = info.who or "UNKOWN"

            if filterCaller != "" and who != filterCaller then continue end
            if filterSteamID != "" and steamid64 != filterSteamID then continue end
            
            local profile = Profiles[who]

            local butt

            if profile then
                butt = playersListWho:AddPanel(i,profile.name or who,profile.avatar,profile.avatarFrame,profile.background,profile.backgroundOpacity)
            elseif who == "Ё" then
                butt = playersListWho:AddPanel(i,"Ё","https://i.pinimg.com/736x/bb/f4/a2/bbf4a268dda92662c5fc4f2608e01a25.jpg","","https://i.pinimg.com/736x/ef/32/bd/ef32bd57d627bdca8dd40e5e357bd6de.jpg")
            elseif who == "0" or who == "CONSOLE" then
                butt = playersListWho:AddPanel(i,who,"https://i.pinimg.com/736x/5f/3b/2f/5f3b2f02fb4bbfbc58c3a42f5278495b.jpg","","https://i.pinimg.com/736x/9c/26/12/9c261201b6a3c72dd4c8638b50f063ee.jpg",1,0.6)
            else
                butt = playersListWho:AddPanel(i,who)
            end

            function butt:Draw(w,h)
                surface.SetDrawColor(0,0,0,100)
                surface.DrawRect(0,0,w,h)
            end

            function butt:OnClick()
                local menu = DermaMenu()

                menu:AddOption(L("copy_steamid64"),function()
                    chat.AddText(who)
                    SetClipboardText(who)
                end)

                if profile then
                    menu:AddOption(L("copy_nickname"),function()
                        chat.AddText(profile.name)
                        SetClipboardText(profile.name)
                    end)
                end

                menu:AddOption(L("open_profile"),function() gui.OpenURL("https://steamcommunity.com/profiles/" .. who .. "/") end)

                menu:Open()
            end
            
            //

            local profile = Profiles[steamid64]

            local butt

            if profile then
                butt = playersList:AddPanel(i,profile.name or steamid64,profile.avatar,profile.avatarFrame,profile.background,profile.backgroundOpacity)
            else
                butt = playersList:AddPanel(i,steamid64)
            end
            
            local reason = tostring(info.reason) or ""

            if utf8.len(reason) > 40 then
                reason = utf8.sub(reason,1,40) .. "..."
            end

            function butt:Draw(w,h)
                local info = listData[steamid64]
                if not info then return end//xd
        
                surface.SetDrawColor(0,0,0,100)
                surface.DrawRect(0,0,w,h)
        
                draw.SimpleText(os.date("%d.%m.%Y %H:%M:%S",info.timestamp_create) .. "","HS.14",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)
                local time

                if tonumber(info.time) == 0 then
                    time = "permament"
                else
                    local lessTime = tonumber(info.timestamp_create) + tonumber(info.time) - os.time()
                    
                    if lessTime <= 0 then
                        time = L("ap_ui_less")
                    else
                        time = adminPanel.TimeToText(tonumber(info.time)) .. " / " .. adminPanel.TimeToText(lessTime)
                    end
                end

                draw.SimpleText(time,"HS.14",w * 0.25,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                
                if time != "permament" then
                    local k = 1 - (tonumber(info.timestamp_create) + tonumber(info.time) - os.time()) / info.time

                    surface.SetDrawColor(255,255,255,255)
                    surface.DrawRect(0,0,w * k,2)
                end

                draw.SimpleText(reason,"HS.14",w-h/2,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

                self:DrawTip("reason: " .. info.reason .. "\nhours played: " .. math.floor((profile.hours or 0) / 60 * 10) / 10 .. ".hours\n" .. (info.content.info or "") ,1)
            end

            function butt:OnClick()
                onclick(info)
            end
        end
    end
end

function Page.Open(frame)
    local scrollNav = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(w,40) end)
    scrollNav:SetHighlightSide("bottom",nil,true)

    local scrollPage = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h) self:setSize(w,h - 40):setPos(0,40) end)
    scrollPage:SetHorizontal(true)

    scrollNav:Add("Bans",function() scrollPage:Set(1) end):SetupDrawStyle("white_gradient").font = "HS.18"
    local pageBan = scrollPage:Add()
    frame.pageBan = pageBan

    createPage(pageBan,"adminPanelBan",function(info)
        OnClick(info,function()
            VParametrEdit("Введите причину","",function(value)
                RunConsoleCommand("ulx_cmd","unban",info.steamid64,value)
            end)
        end)
    end)

    scrollNav:Add("Gag",function() scrollPage:Set(2) end):SetupDrawStyle("white_gradient").font = "HS.18"
    local pageGag = scrollPage:Add()
    frame.pageGag = pageGag

    createPage(pageGag,"adminPanelGag",function(info)
        OnClick(info,function()
            VParametrEdit("Введите причину","",function(value)
                RunConsoleCommand("ulx_cmd","ungag",info.steamid64,value)
            end)
        end)
    end)

    scrollNav:Add("Mute",function() scrollPage:Set(3) end):SetupDrawStyle("white_gradient").font = "HS.18"
    local pageMute = scrollPage:Add()
    frame.pageMute = pageMute

    createPage(pageMute,"adminPanelMute",function(info)
        OnClick(info,function()
            VParametrEdit("Введите причину","",function(value)
                RunConsoleCommand("ulx_cmd","unmute",info.steamid64,value)
            end)
        end)
    end)

    function frame:Update()
        pageBan:Update()
        pageGag:Update()
        pageMute:Update()
    end

    timer.Simple(0.3,function()--чего мы ждём блядь
        frame:Update()
    end)
end

//if Initialize then RunConsoleCommand("adminpanel_menu") end

adminPanelBan:Event_Add("Update","UI",function()
    if IsValid(adminpanel_menu) and IsValid(adminpanel_menu[4].pageBan) then adminpanel_menu[4].pageBan:Update() end
end)

adminPanelGag:Event_Add("Update","UI",function()
    if IsValid(adminpanel_menu) and IsValid(adminpanel_menu[4].pageGag) then adminpanel_menu[4].pageGag:Update() end
end)

adminPanelMute:Event_Add("Update","UI",function()
    if IsValid(adminpanel_menu) and IsValid(adminpanel_menu[4].pageMute) then adminpanel_menu[4].pageMute:Update() end
end)