local Level = oop.Get("level_jailbreak")
if not Level then return end

local color = Color(165,165,165)

function Level:GetTeamName(ply)
    local teamID = ply:Team()

    if teamID == 2 then
        teamID = self[self.teamEncoder[teamID]]

        return teamID[1],teamID[2]
	elseif teamID == 1 then
        local rank = jailbreakManager:GetRank(ply)
        if not rank then return "Уволен",color end

        return rank[1],rank[2]
    end
end

function Level:Scoreboard_Status(ply)
	if not LocalPlayer():Alive() or LocalPlayer():Team() == 1002 then return end

    if ply:Alive() then return "live",ScoreboardGreen else return "dead",ScoreboardRed,ScoreboardRed end
end

--

local white = Color(255,255,255)
local whitePoint = Color(255,255,255)
local point
local pointStart = 0
local old

local circlePos,circleAngle

local circleMat = Material("vgui/loading-rotate")

function Level:HUDPaint(k)
    if #team.GetPlayers(1) == 0 then
        draw.SimpleText(L("jailbreak_minonect"),"HS.25",ScrW() / 2,ScrH() / 2 - 250,nil,TEXT_ALIGN_CENTER)
    elseif #team.GetPlayers(2) == 0 then
        draw.SimpleText(L("jailbreak_minonet"),"HS.25",ScrW() / 2,ScrH() / 2 - 250,nil,TEXT_ALIGN_CENTER)
    end

    local lply = LocalPlayer()

    if lply:Team() == 1 then
        if lply:Alive() then
            local trace = lply:GetEyeTrace()
            local active = input.IsMouseDown(MOUSE_MIDDLE)

            if old ~= active then
                old = active

                if active then
                    local ent = trace.Entity
                    if IsValid(ent) and ent:GetClass() == "func_door" then
                        net.Start("jailbreak_door")
                        net.WriteEntity(ent)
                        net.SendToServer()
                    else
                        net.Start("jailbreak_point")
                        net.WriteVector(trace.HitPos)
                        net.SendToServer()
                    end
                end
            end
        end
    else
        old = false
    end

    local k = math.max(pointStart + 5 - CurTime(),0) / 5

    if k > 0 then
        local pos = point:ToScreen()

        whitePoint.a = 255 * k
        draw.SimpleText(".","HS.25",pos.x,pos.y,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText(pointName,"HS.12",pos.x,pos.y + 25,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end

net.Receive("jailbreak_point",function()
    point = net.ReadVector()
    pointName = net.ReadString()
    pointStart = CurTime()
end)

local Page = scoreboard:Page_Reg(13)
Page.Name = "Jail Break"

function Page.CanOpen(frame) return roundActiveName == "level_jailbreak" end

function Page.Open(frame)
    local panel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w * 0.9,h * 0.9):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2) end)

    local scrollNav = oop.CreatePanel("v_scrollnav",panel):ad(function(self,w,h) self:setSize(w,40) end)
    scrollNav:SetHighlightSide("bottom")

    local scrollpage = oop.CreatePanel("v_scrollpage",panel):ad(function(self,w,h) self:setPos(0,scrollNav:H()):setSize(w,h - self.y) end)
    scrollpage:SetHorizontal(true)

    --

    scrollNav:Add("Rules",function() scrollpage:Set(1) end)

    local page = scrollpage:Add()
    local html = oop.CreatePanel("v_html",page):ad(function(self,w,h) self:setSize(w,h) end)
    
    function html:Paint()
        if not html.open then html.open = true html:OpenURL("https://kopigrad.com/wiki/gamemodes/special/jailbreak/?lang=ru") end
    end

    --

    scrollNav:Add("Ranks",function() scrollpage:Set(2) end)

    local page = scrollpage:Add()
    Page.OpenRank(page)
end

event.Add("Setup World","Rules Construct",function()
    if roundActiveName ~= "level_construct" then return end

    timer.Simple(0,function() scoreboard:Open() scoreboard:OpenPage(13) end)
end)

event.Add("Setup World","Rules Jailbreak",function()
    if roundActiveName ~= "level_jailbreak" then return end

    timer.Simple(0,function() scoreboard:Open() scoreboard:OpenPage(13) end)
end)

function Level:ScoreboradInventoruUICreate(frame,force)
    if LocalPlayer():Team() == 1 then
        local butt = oop.CreatePanel("v_button",frame)
        butt.text = GetGlobalBool("JailBreakAntiRDM",false) and "Guilt Включён" or "GUILT Выключен"
        butt:setSize(300,50):setPos(ScrW() * 0.075,ScrH() * 0.9)

        function butt:OnClick()
            RunConsoleCommand("hg_jailbreak_noguilt")
        end

        function butt:Step()
            butt.text = GetGlobalBool("JailBreakAntiRDM",false) and "Guilt Включён" or "GUILT Выключен"
        end
    end
end