local Level = oop.Get("level_jailbreak")
if not Level then return end

Level.ranksList = {
    {"jailbreak_rank_1",Color(125,125,255),
        armors = {}
    },
    {"jailbreak_rank_2",Color(75,75,255),
        armors = {}
    },
    {"jailbreak_rank_3",Color(25,25,25,255),
        armors = {}
    },
    {"jailbreak_rank_4",Color(25,25,125),
        armors = {}
    }
}

if SERVER then return end

jailbreakManager = ManagerCreate("jailbreakManager",{"node"})
jailbreakManager.listUser = jailbreakManager.listUser or {}

function jailbreakManager:GetRank(ply)
    local rankID = ply:GetNWString("JailBreakRank","0")
    if not rankID or rankID == "0" then return end

    local rank = Level.ranksList[tonumber(rankID)]

    return rank,rankID
end

function jailbreakManager:InputFull(body)
    jailbreakManager.listUser = JSONToTable(body)

    jailbreakManager:Event_Call("Update")
end

net.Receive("jailbreak_ranks_data",function()
    local body = net.ReadString()
    jailbreakManager:InputFull(body)
end)

jailbreakManager:Event_Add("Update","UI",function()
    if IsValid(JailBreakMenuRanks) then JailBreakMenuRanks:Update() end
end)

local cframe1 = Color(255,255,255,5)

local Page = scoreboard:Page_Reg(13)

function Page.OpenRank(frame)
    JailBreakMenuRanks = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w * 0.9,h * 0.9):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2) end)

    function JailBreakMenuRanks:Draw(w,h)
        surface.SetDrawColor(255,255,255,5)
        draw.GradientDown(w / 2 - 2,200,4,h / 2)
        draw.GradientUp(w / 2 - 2,h / 2 + 200,4,h / 2 - 400)
    end
    
    local iconSize = 64
    local wide = iconSize * 0.25

    local ranksList = oop.CreatePanel("v_players",JailBreakMenuRanks):ad(function(self,w,h)
        self:setSize(w / 2 - 100,h - 64):setPos(0,64)
    end)

    ranksList:CreateVBar()
    ranksList:Setup(iconSize)
    ranksList.scrolling = (iconSize + wide) * 6

    function ranksList:Draw(w,h)
        DisableClipping(true)
        draw.SimpleText("Players With Ranks","HS.25",w / 2,-32,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        DisableClipping(false)
    end

    local function OpenDermaPanel(steamid64)
        local myOwnRankID = jailbreakManager.listUser[LocalPlayer():SteamID64()]
        if not myOwnRankID and not LocalPlayer():IsAdmin() then return end

        local menu = DermaMenu() 
        
        local sub = menu:AddSubMenu("Повысить до...")

        for id,rank in pairs(level_jailbreak.ranksList) do
            if LocalPlayer():IsAdmin() or myOwnRankID > id then
                sub:AddOption(L(rank[1]),function()
                    RunConsoleCommand("say","!jailbreak_add " .. steamid64 .. " " .. id)
                end)
            end
        end

        local rank = tonumber(jailbreakManager.listUser[steamid64])
        rank = rank and level_jailbreak.ranksList[rank]

        if rank then
            menu:AddOption("Уволить",function()
                RunConsoleCommand("say","!jailbreak_add " .. steamid64 .. " 0")
            end)
        end
        
        menu:Open()
    end

    function ranksList:DrawPanel(w,h,panel,info)
        local rankInfo = level_jailbreak.ranksList[tonumber(jailbreakManager.listUser[info.id])]
        local col = rankInfo and rankInfo[2] or Color(25,25,25)

        surface.SetDrawColor(15,15,15,75)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(col.r,col.g,col.b,255)
        surface.DrawRect(0,0,4,h)

        surface.SetDrawColor(col.r,col.g,col.b,25)
        draw.GradientLeft(0,0,w,h)

        if self:IsHovered() then
            surface.SetDrawColor(255,255,255,255)
            surface.DrawRect(0,0,4,h)

            surface.SetDrawColor(255,255,255,1)
            surface.DrawRect(0,0,w,h)
        end

        draw.SimpleText(L(rankInfo and rankInfo[1] or "jailbreak_rank_0"),"HS.25",w -  h / 2,h / 2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        
        draw.Frame(0,0,w,h,cframe1,cframe2)
    end

    function ranksList:OnClick(key,info)
        OpenDermaPanel(info.id)
    end

    function ranksList.Update()//mdam
        ranksList:Clear()
  
        for steamid64,info in pairs(jailbreakManager.listUser) do
            local profile = Profiles[steamid64]

            if profile then
                ranksList:AddPanel(steamid64,profile.name,profile.avatar,profile.avatarFrame,profile.background)
            else
                ranksList:AddPanel(steamid64,steamid64)
            end
        end
    end

    local playersList = oop.CreatePanel("v_players",JailBreakMenuRanks):ad(function(self,w,h)
        self:setSize(w / 2 - 100,h - 64):setPos(w / 2 + 100,64)
    end)

    playersList:CreateVBar()
    playersList.scrolling = (iconSize + wide) * 6
    playersList:Setup(iconSize,wide)

    function playersList:Draw(w,h)
        DisableClipping(true)
        draw.SimpleText("Players","HS.25",w / 2,-32,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        DisableClipping(false)
    end

    function playersList:DrawPanel(w,h,panel,info)
        local rankInfo = tonumber(jailbreakManager.listUser[info.id])
        rankInfo = rankInfo and level_jailbreak.ranksList[rankInfo]

        local col = rankInfo and rankInfo[2] or Color(25,25,25)

        surface.SetDrawColor(15,15,15,75)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(col.r,col.g,col.b,255)
        surface.DrawRect(0,0,4,h)

        surface.SetDrawColor(col.r,col.g,col.b,25)
        draw.GradientLeft(0,0,w,h)

        if self:IsHovered() then
            surface.SetDrawColor(255,255,255,255)
            surface.DrawRect(0,0,4,h)

            surface.SetDrawColor(255,255,255,1)
            surface.DrawRect(0,0,w,h)
        end

        draw.SimpleText(L(rankInfo and rankInfo[1] or ""),"HS.25",w -  h / 2,h / 2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        
        draw.Frame(0,0,w,h,cframe1,cframe2)
    end

    function playersList:OnClick(key,info)
        OpenDermaPanel(info.id)
    end

    function playersList.Update()
        playersList:Clear()
 
        for i,ply in pairs(player.GetAll()) do
            playersList:AddPlayer(ply)
        end
    end

    function JailBreakMenuRanks:Update()
        ranksList.Update()

        timer.Simple(0.6,function()
            if not IsValid(playersList) then return end
            playersList.Update()
        end)
    end

    timer.Simple(0.1,function()
        if not IsValid(JailBreakMenuRanks) then return end
        
        JailBreakMenuRanks:Update()
    end)
end