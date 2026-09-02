local Panel = scoreboard:Page_Reg(1)
Panel.Name = "scoreboard"
Panel.Icon = Material("homigrad/vgui/icons/users.png","smooth")

local specColor = Color(155,155,155)
local white = Color(255,255,255,255)
local colorSpec = Color(155,155,155)
local colorRed = Color(205,55,55)
local colorGreen = Color(55,255,55)
local colorBlue = Color(175,175,255)

ScoreboardRed = colorRed
ScoreboardBlue = colorBlue
ScoreboardSpec = colorSpec
ScoreboardGreen = colorGreen
ScoreboardBlack = Color(0,0,0,200)

local function timeSort(a,b)
    return a:GetNWFloat("Time",0) > b:GetNWFloat("Time",-1)
end

local green = Color(75,255,75)

function player.OpenDermaMenu(ply)
    local name,steamID

    if TypeID(ply) == TYPE_TABLE then
        name = ply.name
        steamID = ply.steamID
    else
        name = ply:Name()
        steamID = ply:SteamID()
    end

    local menu = DermaMenu()

    menu:AddOption(L("copy_nickname"),function()
        SetClipboardText(ply:Name())
        chat.AddText(Color(255,255,255),ply:Name())
    end)

    menu:AddOption(L("copy_steamid"),function()
        SetClipboardText(ply:SteamID())
        chat.AddText(Color(255,255,255),ply:SteamID())
    end)

    menu:AddOption(L("copy_steamid64"),function()
        SetClipboardText(ply:SteamID64())
        chat.AddText(Color(255,255,255),ply:SteamID64())
    end)
    
    if not ply.ShowProfile then menu:Open() menu:MakePopup() return end
    
    menu:AddOption(L("open_profile"),function() ply:ShowProfile() end)

    if LocalPlayer():IsAdmin() then
        local sub = menu:AddSubMenu("Set Team")

        for i = 1,3 do
            sub:AddOption(i,function() RunConsoleCommand("say","!teamforce " .. ply:SteamID() .. " " .. i) end)
        end

        sub:AddOption("Spectators",function() RunConsoleCommand("say","!teamforce " .. ply:SteamID() .. " 1002") end)

        menu:AddOption(L("kick"),function() RunConsoleCommand("ulx_cmd","kick",ply:Name(),"kick with tab") end)
    end

    menu:Open()
    menu:MakePopup()
end

local err = function(err) ErrorNoHaltWithStack(err) end

local history = {}
local historyPhys = {}

ScreenSizeHook("ScoreboardPlayer",function()
    scoreboard.iconSize = 72 * ScreenSize
    scoreboard.font = "HS22"
    scoreboard.playerFontSize = 15
    scoreboard.playerFont = "HS20"

    scoreboard.panelWByScreenMul = 0.4
end)

local corner = vgui.corner

function Panel.Open(panelPage)
    local panelPlayers = oop.CreatePanel("v_panel",panelPage):ad(function(self,w,h)
        self.iconSize = scoreboard.iconSize
        self.WIDE = self.iconSize * 0.25
        self.bottomCorner = scoreboard.iconSize

        self:setSize(ScrW() * scoreboard.panelWByScreenMul,h - 200):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2)
    end)

    scoreboard.panelPlayers = panelPlayers

    function panelPlayers:DrawTickRate(w,h)
        local wide = 1

        history[#history + 1] = {1 / ServerPerformance[1],ServerPerformance[2] * 1000 * 30}
        
        surface.SetDrawColor(0,255,0,15)

        for i = 1,#history do
            local v = self.bottomCorner * (history[i][1] / 120)

            surface.DrawRect(0 + wide * i,h - v + 1,wide,v)
        end

        surface.SetDrawColor(125,125,255,15)

        for i = 1,#history do
            local v = self.bottomCorner * (history[i][2] / 120)

            surface.DrawRect(0 + wide * i,h - v + 1,wide,v)
        end

        if #history >= w / wide then table.remove(history,1) end
    end

    function panelPlayers:DrawScoreboard() end
    
    function panelPlayers:Draw(w,h)
        self:DrawTickRate(w,h)
        self:DrawScoreboard(w,h)
    end

    function panelPlayers:Sort()
        local round = levelActive or Levels[roundActiveName] or Levels["level_"..(roundActiveName or "homicide")]
        if not round then return end

        local teams = {}
        local lives,deads = {},{}

        for i,ply in pairs(player.GetAll()) do
            if ply:GetNWBool("Hide") then continue end
            
            ply.last = nil

            local teamID = ply:Team()
            teams[teamID] = teams[teamID] or {{},{}}
            teamID = teams[teamID]

            local func = round.Scoreboard_Status
            if func then alive,alivecol,colorAdd = func(round,ply) end

            if ply:Alive() then
                teamID[1][#teamID[1] + 1] = ply
            else
                teamID[2][#teamID[2] + 1] = ply
            end
        end
        
        for teamID,list in pairs(teams) do
            xpcall(table.sort,err,list[1],timeSort)
            xpcall(table.sort,err,list[2],timeSort)
        end

        local sort = {}

        local func = round.ScoreboardSort

        if func then
            func(round,sort,teams)
        else
            for teamID,team in pairs(teams) do
                for i,ply in pairs(team[1]) do sort[#sort + 1] = ply end
                for i,ply in pairs(team[2]) do sort[#sort + 1] = ply end

                local last = team[1][#team[1]]
                if last then
                    local func = round.Scoreboard_DrawLast
                    if func and func(round,last) ~= nil then continue end

                    last.last = #team[1]
                end

                last = team[2][#team[2]]
                if last then
                    local func = round.Scoreboard_DrawLast
                    if func and func(round,last) ~= nil then continue end

                    last.last = #team[2]
                end
            end
        end

        self.sort = sort
    end

    local scroll = oop.CreatePanel("v_scrollpanel",panelPlayers):ad(function(self,w,h) self:setPos(0,40):setSize(w,h - 40) end)
    scroll.scrolling = panelPlayers.iconSize + panelPlayers.WIDE / 2 / 2
    scroll.scrollMul = 3
    scroll.scrollLerp = 0.25
    
    local scrollPing = oop.CreatePanel("v_scrollpanel",panelPage):ad(function(self,w,h) self:setSize(scoreboard.iconSize,scroll:H()):setPos(panelPlayers.x - self:W(),panelPlayers.y + scroll.y) end)
    scrollPing:LinkScrollPanel(scroll)

    local scrollMute = oop.CreatePanel("v_scrollpanel",panelPage):ad(function(self,w,h) self:setSize(scoreboard.iconSize,scroll:H()):setPos(panelPlayers.x + panelPlayers:W() + scoreboard.iconSize * 0.25,panelPlayers.y + scroll.y) end)
    scrollMute:LinkScrollPanel(scroll)

    local html = ScoreboardBuildOnHTML(panelPlayers,scroll,scrollPing,scrollMute)

    function panelPlayers:Update()
        self:Sort()

        if html.Ready then html:OnReady() end
    end

    panelPlayers:Update()

    --[[local panel = vCreate("v_panel",panelPage):ad(function(self,w,h) self:setSize(w * 0.2,h - 200):setPos(w * 0.025,h/2-self:H()/2) end)
    function panel:Draw(w,h)
        draw.SimpleText("Выберете Команду","H25",w/2,35/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        draw.SimpleText("ИНТЕРФЕЙС ВРЕМЕННЫЙ","H12",0,h,nil,nil,TEXT_ALIGN_BOTTOM)
    end

    local play = vCreate("v_button",panel):ad(function(self,w,h) self:setSize(w,60):setPos(0,40) end)
    function play:Draw(w,h)
        draw.RoundedBox(6,corner,corner,w - corner * 2,h - corner * 2,vgui.cBackground)
        if self:IsHovered() or table.HasValue(level.players,LocalPlayer()) then draw.RoundedBox(6,corner,corner,w - corner * 2,h - corner * 2,vgui.cBackgroundHover) end
        draw.SimpleText("PLAYERS","H30",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
    function play:OnClick()
        level.Join()
    end

    local unplay = vCreate("v_button",panel):ad(function(self,w,h) self:setSize(w,60):setPos(0,40 + 60) end)
    function unplay:Draw(w,h)
        draw.RoundedBox(6,corner,corner,w - corner * 2,h - corner * 2,vgui.cBackground)
        if self:IsHovered() or not table.HasValue(level.players,LocalPlayer()) then draw.RoundedBox(6,corner,corner,w - corner * 2,h - corner * 2,vgui.cBackgroundHover) end
        draw.SimpleText("SPECTATORS","H30",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
    function unplay:OnClick()
        level.Leave()
    end]]--
end

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect","Scoreboard Players",function()
    if IsValid(scoreboard.panelPlayers) then scoreboard.panelPlayers:Update() end
end)

gameevent.Listen("player_spawn")
hook.Add("player_spawn","Scoreboard Players",function()
    timer.Simple(0.1,function()
        if IsValid(scoreboard.panelPlayers) then scoreboard.panelPlayers:Update() end
    end)
end)

if Initialize and LocalPlayer():SteamID() == "STEAM_0:1:164889146" then scoreboard:Open() end

--

local PLAYER = FindMetaTable("Player")

function PLAYER:GetAliveStatus()
    local alive,alivecol,colorAdd

	local func = levelActive.Scoreboard_Status
            
	if func then
		alive,alivecol,colorAdd = func(levelActive,self)
	end

	if not func or (not alive) then
		if self:Alive() then
			alive = "scoreboard_live"
			alivecol = ScoreboardGreen
		elseif self:Team() == 1002 then
			alive = "scoreboard_spectate"
			alivecol = ScoreboardSpec
		else
			alive = "scoreboard_dead"
			alivecol = ScoreboardRed
			colorAdd = ScoreboardRed
		end
	end

    return alive,alivecol,colorAdd
end

function PLAYER:GetTeamStatus()
    local name,color = self:PlayerClassEvent("TeamName")

    if not name then
        name,color = level.HookCall("GetTeamName",self)
        name = name or "spectate"
        color = color or ScoreboardSpec
    end

    return name,color
end

function PLAYER:GetTimeStatus()
    local time = (self:IsBot() and 0) or self:GetNWInt("Time",-1)

    if time == -1 then
        return false
    else
        time = math.floor(time + (CurTime() - self:GetNWFloat("TimeStart",0)))

        local hours = math.floor(time / 60 / 60)
        local minutes = math.floor(time / 60) % 60

        if minutes > 0 and minutes % 10 == 0 then
            return hours .. "." .. math.floor(minutes / 10)
        end

        return tostring(hours)
    end
end