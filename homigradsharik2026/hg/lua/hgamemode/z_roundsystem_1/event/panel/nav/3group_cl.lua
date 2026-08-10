EventPanel_Pages[3] = {}
local Panel = EventPanel_Pages[3]
Panel.Name = "event_group"

local function sendCmd(args)
    net.Start("event_group")
    net.WriteTable(args)
    net.SendToServer()
end

local empty

local function getPlayers(text)
    if text == "^" then
        if table.Count(cursorEntities) != 0 then
            local list = {}

            for ent in pairs(cursorEntities) do
                if not IsValid(ent) then cursorEntities[ent] = nil end

                list[ent:SteamID()] = true
            end

            return list
        else
            return {[LocalPlayer():SteamID()] = true}
        end
    elseif string.sub(text,1,1) == "#" then
        local group = EventGroups[tonumber(string.sub(text,2,#text))]
        if not group then return end

        return group.list
    else
        return 
    end
end

function Panel.Create(page)
    local groupSettingsFrame = oop.CreatePanel("v_panel",page):ad(function(self,w,h) self:setPos(0,60):setSize(w,h - self.y) end)
    
    local buttonAdd = oop.CreatePanel("v_button",groupSettingsFrame):ad(function(self,w,h) self:setSize(w * 0.15,30):setPos(0,h - self:H()) end)
    buttonAdd.text = "+"
    buttonAdd.font = "HS.18"
    function buttonAdd:OnClick()
        sendCmd({"create"})
    end

    local groupList = oop.CreatePanel("v_scrollnav",groupSettingsFrame):ad(function(self,w,h) self:setSize(buttonAdd:W(),h - buttonAdd:H()) end)
    groupList:SetHighlightSide("right",nil,30)
    function groupList:Draw(w,h)
        surface.SetDrawColor(0,0,0,50)
        surface.DrawRect(0,0,w,h)
        surface.DrawRect(w - 1,0,1,h)
    end

    local settingsNav = oop.CreatePanel("v_scrollnav",groupSettingsFrame):ad(function(self,w,h) self:setPos(groupList:W() + 60,0):setSize(w - self.x,30) end)
    settingsNav:SetHighlightSide("bottom")

    local scrollPage = oop.CreatePanel("v_scrollpage",groupSettingsFrame):ad(function(self,w,h) self:setPos(settingsNav.x,settingsNav:H()):setSize(w - self.x,h - self.y) end)
    scrollPage:SetHorizontal(true)
    function scrollPage:Draw(w,h)
        surface.SetDrawColor(0,0,0,50)
        surface.DrawRect(0,0,w,h)
        surface.DrawRect(0,0,1,h)
    end

    local groupSelect

    local function Set(id)
        if not groupSelect then return end
        
        scrollPage:Set(id)
    end

    function page:Draw(w,h)
        draw.SimpleText(not groupSelect and L("event_group") or groupSelect.name,"HS.25",scrollPage.x + scrollPage:W() / 2,30,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    -- SETTINGS

    local settings = scrollPage:Add(); settingsNav:Add("Settings",function(id) Set(id) end)
    function settings:Draw(w,h) draw.SimpleText(L("event_group_settings"),"HS.25",w / 2,30,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
    local textEntry = oop.CreatePanel("v_textentry",settings):ad(function(self,w,h) self:setSize(400,30):setPos(30,60) end)
    function textEntry:OnEnter() sendCmd({"rename",groupSelect.id,self:GetValue()}) end
    function textEntry:OnUnFocus() self:SetValue(groupSelect.name) end

    local butt = oop.CreatePanel("v_button",settings):ad(function(self,w,h) self:setSize(200,30):setPos(w - 30 - self:W(),h - self:H() - 30) end)
    butt.text = L("event_group_remove")
    function butt:OnClick() sendCmd({"remove",groupSelect.id}) end

    local butt = oop.CreatePanel("v_button",settings):ad(function(self,w,h) self:setSize(400,30):setPos(30,h - self:H() - 30) end)
    butt.text = L("event_group_join_auto")
    function butt:OnClick() sendCmd({"playerjoin",groupSelect.id,not groupSelect.playerjoin}) end
    function butt:PreDrawText(w,h)
        if groupSelect and groupSelect.playerjoin then
            surface.SetDrawColor(0,255,0)
            surface.DrawRect(0,0,2,h)
            surface.SetDrawColor(0,255,0,6)
            draw.GradientLeft(0,0,16,h)
        end
    end

    local butt = oop.CreatePanel("v_button",settings):ad(function(self,w,h) self:setSize(400,30):setPos(30,h - self:H() - 60 - 5) end)
    butt.text = L("event_group_join_auto_remove")
    function butt:OnClick() sendCmd({"playerremovebyleave",groupSelect.id,not groupSelect.playerremovebyleave}) end
    function butt:PreDrawText(w,h)
        if groupSelect and groupSelect.playerremovebyleave then
            surface.SetDrawColor(0,255,0)
            surface.DrawRect(0,0,2,h)
            surface.SetDrawColor(0,255,0,6)
            draw.GradientLeft(0,0,16,h)
        end
    end

    local butt = oop.CreatePanel("v_button",settings):ad(function(self,w,h) self:setSize(200,30):setPos(w - 30 - self:W(),h - self:H() - 100) end)
    butt.text = L("event_group_up")
    function butt:OnClick() sendCmd({"up",groupSelect.id}) end

    local butt = oop.CreatePanel("v_button",settings):ad(function(self,w,h) self:setSize(200,30):setPos(w - 30 - self:W(),h - self:H() - 65) end)
    butt.text = L("event_group_down")
    function butt:OnClick() sendCmd({"down",groupSelect.id}) end

    local colorMixer = oop.CreatePanel("v_colormixer",settings):ad(function(self,w,h) self:setSize(350,280):setPos(30,textEntry.y + textEntry:H() + 30) end)
    colorMixer:SetPalette(false)

    function colorMixer:ValueChanged(col)
        if self.override then return end//MDAM
        timer.Create("group color mixer",0.25,1,function()
            sendCmd({"recolor",groupSelect.id,col})
        end)
    end
    
    function settings:Update()
        if groupSelect then
            textEntry:SetValue(groupSelect.name)
            colorMixer.override = true
            colorMixer:SetColor(groupSelect.color)
            colorMixer.override = nil
        end
    end

    local iconSize = 32

    -- PLAYERS IN GROUP
    
    local playersInGroup = scrollPage:Add(); settingsNav:Add(L("event_group_players"),function(id) Set(id) end)
    local playersOutGroup = scrollPage:Add(); settingsNav:Add(L("event_group_all_players"),function(id) Set(id) end)
    function playersInGroup:Draw(w,h) draw.SimpleText(L("event_group_players"),"HS.25",w - iconSize * 0.25 * 2,30,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER) end
    function playersOutGroup:Draw(w,h) draw.SimpleText(L("event_group_all_players"),"HS.25",w - iconSize * 0.25 * 2,30,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER) end
    local scrollPanel = oop.CreatePanel("v_scrollpanel",playersInGroup):ad(function(self,w,h) self:setPos(0,60):setSize(w,h - self.y) end)
    scrollPanel:CreateVBar()
    
    local playersIn = oop.CreatePanel("v_players",playersInGroup):ad(function(self,w,h) self:setSize(w,h) end)
    playersIn:CreateVBar()
    playersIn:Setup(iconSize)
    playersIn.search:ad(function(self,w,h) self:setSize(w * 0.5,60 - iconSize * 0.25):setPos(iconSize * 0.25,iconSize * 0.25 / 2) end)
    playersIn.avatars:InvalidateLayout(true)

    local fake = {
        GetAliveStatus = function() return "Offline",Color(255,0,0) end,
        GetUserColor = function() return Color(255,255,255) end,
        GetTimeStatus = function() return 0 end,
        Name = function(self) return self.name end,
        GetTimeStatus = function() return 0 end,
        Ping = function() return "" end,
        GetTeamStatus = function() return "",Color(0,0,0) end,
        GetNWBool = function(key,def) return def end,
        GetUserGroup = function() return "" end
    }

    local checkList
    function playersIn:OnChangeFilterValue(value)
        checkList = getPlayers(value)
    end

    function playersIn:Filter(value,info)
        if not checkList and value != "" and not string.find(string.utf8lower(info.name),value) then return false end
        if checkList and not checkList[info.id] then return false end

        return true
    end

    function playersIn:DrawPanel(w,h,panel,info)
        local ply = player.GetBySteamID(info.id)

        if not IsValid(ply) then
            fake.name = info.name
            ply = fake
        end

        scoreboard.DrawPlayer(ply,w,h,{dontDrawMute = true,dontDrawPing = true})

        if Event_CanAccess(ply) then draw.SimpleText("EVENT TEAM","HS.12",w / 2,h / 4,gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
    end

    function playersIn:OnClick(key,info)
        if key == MOUSE_RIGHT then
            local ply = player.GetBySteamID(info.id)

            if IsValid(ply) then player.OpenDermaMenu(ply) else player.OpenDermaMenu({name = info.name,steamID = info.id}) end
        else
            sendCmd({"user_remove",groupSelect.id,info.id})
        end
    end

    function playersInGroup:Update(typeCall)
        playersIn:Clear()
        --if typeCall == "page" then playersIn:OnChangeFilterValue(playersIn.value) end//Update

        if not groupSelect then return end

        for steamid,info in pairs(groupSelect.list) do
            playersIn:AddPanel(steamid,info.name,info.avatar,info.avatarFrame)
        end
    end

    -- PLAYERS OUT GROUP
    
    local playersOut = oop.CreatePanel("v_players",playersOutGroup):ad(function(self,w,h) self:setSize(w,h) end)
    playersOut:CreateVBar()
    playersOut:Setup(iconSize)
    playersOut.search:ad(function(self,w,h) self:setSize(w * 0.5,60 - iconSize * 0.25):setPos(iconSize * 0.25,iconSize * 0.25 / 2) end)
    playersOut.avatars:InvalidateLayout(true)

    local checkList
    
    function playersOut:OnChangeFilterValue(value)
        checkList = getPlayers(value)
    end

    function playersOut:Filter(value,info)
        local ply = player.GetBySteamID64(info.id)
        if not IsValid(ply) then return false end
        
        if not checkList then
            if value != "" and not string.find(string.utf8lower(ply:Name()),value) then return false end
        else
            if not checkList[ply:SteamID64()] then return false end
        end

        return true
    end

    function playersOut:DrawPanel(w,h,panel,info)
        local ply = player.GetBySteamID64(info.id)
        if not IsValid(ply) then return end

        scoreboard.DrawPlayer(ply,w,h,{dontDrawMute = true,dontDrawPing = true})

        if Event_CanAccess(ply) then draw.SimpleText("EVENT TEAM","HS.12",w / 2,h / 4,gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
    end

    function playersOut:OnClick(key,info)
        local ply = player.GetBySteamID64(info.id)
        if not IsValid(ply) then return end//lol

        if key == MOUSE_RIGHT then
            player.OpenDermaMenu(ply)
        else
            sendCmd({"user_add",groupSelect.id,ply})
        end
    end
    
    function playersOutGroup:Update(typeCall)
        playersOut:Clear()
        --if typeCall == "page" then playersOut:OnChangeFilterValue(playersOut.value) end//Update 

        if not groupSelect then return end

        for i,ply in pairs(player.GetAll()) do
            playersOut:AddPlayer(ply)
        end
    end

    --

    local function pagesUpdate(typeCall)
        if not IsValid(settings) then return end
        settings:Update()

        playersOutGroup:Update(typeCall)
        playersInGroup:Update(typeCall)
    end

    function page:Update()
        groupList:Clear()

        local setGroup

        for i,group in pairs(EventGroups) do
            local button = groupList:Add(group.name,function()
                groupSelect = group
                pagesUpdate("page")
            end)

            function button:DrawOver(w,h)
                local color = group.color
                surface.SetDrawColor(color.r,color.g,color.b)
                surface.DrawRect(0,0,4,h)

                surface.SetDrawColor(255,255,255,5)
                surface.DrawRect(0,0,1,h)
                surface.DrawRect(0,0,4,1)
                surface.SetDrawColor(0,0,0,175)
                surface.DrawRect(0,h - 1,4,1)

                draw.SimpleText("#" .. i,"HS.12",h / 2,h / 2,white,nil,TEXT_ALIGN_CENTER)
            end

            if groupSelect and groupSelect.id == group.id and groupSelect ~= group then
                local findByName 
    
                for id,group in pairs(EventGroups) do
                    if group.name == groupSelect.name then findByName = group break end
                end
    
                setGroup = findByName or group
            end//update info
        end

        if not setGroup and EventGroups[1] then
            setGroup = EventGroups[1]
        end

        if setGroup then
            groupSelect = setGroup
            groupList:Set(groupSelect.id)

            if scrollPage.setPage == 0 then scrollPage:Set(1) end
        else
            groupSelect = nil

            scrollPage:Set(0)
            scrollPage.page = 0
        end

        --scrollPage:Set(3)

        pagesUpdate()
    end

    timer.Simple(0,function()
        if not IsValid(page) then return end
        
        page:Update()
    end)
end

net.Receive("event_group",function()
    EventGroups = net.ReadTable()

    for i,ply in pairs(player.GetAll()) do
        ply.eventGroup = nil
    end

    for id,group in pairs(EventGroups) do
        group.id = id

        for i,ply in pairs(player.GetAll()) do
            if group.list[ply:SteamID()] then ply.eventGroup = group end
        end
    end

    EventPanel_Update()
end)

if Initialize then scoreboard:Open() end
