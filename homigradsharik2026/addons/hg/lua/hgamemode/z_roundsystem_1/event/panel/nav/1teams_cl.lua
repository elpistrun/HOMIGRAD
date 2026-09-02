EventPanel_Pages[1] = {}
local Panel = EventPanel_Pages[1]
Panel.Name = "event_team"

local function sendCmd(args)
    net.Start("event_team")
    net.WriteTable(args)
    net.SendToServer()
end

function Panel.Create(frame)
    local playerInTeam = oop.CreatePanel("v_players",frame):ad(function(self,w,h) self:setSize(w * 0.5 - 30,h - 90):setPos(30,60) end)
    playerInTeam:CreateVBar()
    playerInTeam:Setup(64)

    function playerInTeam:OnClick(key,info)
        sendCmd({"remove",info.id})
    end

    local players = oop.CreatePanel("v_players",frame):ad(function(self,w,h) self:setSize(w * 0.5 - 30,h - 90):setPos(w * 0.5,60) end)
    players:CreateVBar()
    players:Setup(64)
    
    function players:OnClick(key,info)
        sendCmd({"add",info.id})
    end

    function players:DrawPanel(w,h,panel,info)
        local ply = player.GetBySteamID64(info.id)
        if not IsValid(ply) then return end--не ебёт

        scoreboard.DrawPlayer(ply,w,h,{dontDrawMute = true,dontDrawPing = true,dontDrawTeam = true,dontDrawAlive = true})
    end

    function playerInTeam:DrawPanel(w,h,panel,info)
        local ply = player.GetBySteamID64(info.id)
        if not IsValid(ply) then return end

        scoreboard.DrawPlayer(ply,w,h,{dontDrawMute = true,dontDrawPing = true,dontDrawTeam = true,dontDrawAlive = true})
    end

    function frame:Update()
        playerInTeam:Clear()
        players:Clear()

        local owner = Event_Claimed.owner

        if not IsValid(players) then return end

        for i,ply in pairs(player.GetAll()) do
            if owner.steamid64 == ply:SteamID64() or Event_Claimed.friends[ply:SteamID64()] then continue end
            
            players:AddPlayer(ply)
        end

        if not IsValid(playerInTeam) then return end

        local profile = Profiles[owner.steamid64] or {}
        playerInTeam:AddPanel(owner.steamid64,profile.name,profile.avatar,profile.avatarFrame,profile.background)

        for steamid64,info in pairs(Event_Claimed.friends) do
            local profile = Profiles[steamid64] or {}

            local ply = player.GetBySteamID64(steamid64)

            if IsValid(ply) then
                playerInTeam:AddPlayer(ply)
            else
                playerInTeam:AddPanel(steamid64,profile.name,profile.avatar,profile.avatarFrame,profile.background)
            end
        end
    end

    timer.Simple(0.1,function()
        if not IsValid(frame) then return end

        frame:Update()
    end)

    function frame:Draw(w,h)
        draw.SimpleText(L("event_you_team"),"HS.25",playerInTeam.x + playerInTeam:W() / 2,30,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("event_players"),"HS.25",players.x + players:W() / 2,30,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end

event.Add("Event Claimed Info Updated","Team",function()
    EventPanel_Update(1)
end)

adminPanel.commandRegistry("event_give_superadmin",{{type = "players",name = "player"}},"game",nil,"rcon")