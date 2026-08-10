local Panel = scoreboard:Page_Reg(4)
Panel.list[1] = Panel.list[1] or {}
Panel = Panel.list[1]
Panel.Name = "team"

local empty = {}

function Panel.Open(frame)
    local level = levelActive or Levels[roundActiveName] or Levels["level_"..(roundActiveName or "homicide")]
    if not level or not level.teamEncoder then return end
    local max = table.Count(level.teamEncoder)

    local w,h = ScrW(),ScrH()
    local panel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(325 * max * ScreenSize,655 * ScreenSize):setPos(w / 2 - self:W() / 2,h / 2 - self:H() / 2) end)

    function panel:Draw(w,h)
        surface.SetDrawColor(15,15,15,100)
        surface.DrawRect(0,0,w,h)

        DrawBlurByPanel(6,self)

        draw.Frame(0,0,w,h,cframe1,cframe2)
    end

    function frame:Draw(w,h)
        draw.SimpleText(L("select_team"),"HS.25",w / 2,panel.y/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
    
    local num = 0

    for i,name in pairs(level.teamEncoder) do
        local team = level[name]
        local col = team[2]

        num = num + 1
        local numm = num

        local butt = oop.CreatePanel("v_panel",panel):ad(function(self,w,h)
            local x = 10

            for i,child in pairs(panel:GetChildren()) do
                child:setSize(w / max - (i == 1 and 20 or 0),h - 20):setPos(x,10)
                x = x + child:W()
            end
        end)
        
        local copy = {}
        for k,v in pairs(team) do copy[k] = v end
        team = copy
        
        local func = levelActive.TeamTab_Team
        if func then func(team) end

        butt.hovered = 0
        butt.down = 0

        local list = {}

        local fakePly = customEnts.Create("player_fake")

        local function setup(team)
            local class = table.Random(team.classes or {})

            local mdlpath,bodygroups = level.GetModel((class and class.models) or team.models)
            
            fakePly:SetModel(mdlpath)
            for id,value in pairs(bodygroups) do fakePly:SetBodygroup(id,value) end
            fakePly:SetPlayerColor(col:ToVector())

            local main_weapon = (class and class.main_weapon) or team.main_weapon
            local wepMain = main_weapon and main_weapon[math.random(1,#main_weapon)]
            if wepMain then fakePly:AddWeapon(wepMain) end

            local secondary_weapon = (class and class.secondary_weapon) or team.secondary_weapon
            local wepSecondary = secondary_weapon and secondary_weapon[math.random(1,#secondary_weapon)]
            if wepSecondary then fakePly:AddWeapon(wepSecondary) end

            for i,class in pairs((class and class.weapons) or team.weapons or empty) do fakePly:AddWeapon(class) end
            for i,armor in pairs((class and class.armors) or team.armors or empty) do fakePly:GiveArmor(level.GetArmor(armor,col)) end
        end

        setup(team)

        function butt:Draw(w,h)
            surface.SetDrawColor(15,15,15,75)
            surface.DrawRect(0,0,w,h)
    
            draw.Frame(0,0,w,h,cframe1,cframe2)

            local isMyTeam = i == LocalPlayer():Team()

            self.hovered = LerpFT(0.25,self.hovered,not isMyTeam and self:IsHovered() and 1 or 0)
            self.down = LerpFT(0.5,self.down,not isMyTeam and self:IsDown() and 1 or 0)

            surface.SetDrawColor(col.r,col.g,col.b,25 + self.hovered * 55)
            
            local size = h / 1.25 + h / 3 * math.cos(CurTime())
            draw.GradientDown(0,h - size,w,size)

            if isMyTeam then
                surface.SetDrawColor(0,0,0,175)
                surface.DrawRect(0,0,w,h)
                
                surface.SetDrawColor(255,255,255,175)
                surface.DrawRect(0,h - 1,w,1)
            end

            local x,y = self:LocalToScreen()
            cam.Start3D(Vector(100,0,40),(-Vector(1,0,0)):Angle(),20,x,y,w,h)
            render.SuppressEngineLighting(true)
            self:EnableScissor()
            fakePly:Render(self,w,h,-self.hovered - 5)
            self:DisableScissor()
            render.SuppressEngineLighting(false)
            cam.End3D()

            draw.SimpleText(L(team[1]),"HS.18",w / 2,h - 25,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            surface.SetDrawColor(255,255,255,self.down * 2)
            surface.DrawRect(0,0,w,h)
        end

        butt:Event_Add("Remove","Fakeply",function() fakePly:Remove() end)

        function butt:OnMouse(key,value)
            if not value then return end

            net.Start("want change team")
            net.WriteString(tostring(i))
            net.SendToServer()
        end
    end

    local butt = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(325* ScreenSize,50 * ScreenSize):setPos(w / 2 - self:W() / 2,h - (h - panel.y - panel:H())/2-self:H()/2) end)
    butt.text = L("spectator")
    butt.font = "HS.18"

    function butt:OnMouse(key,value)
        if not value then return end

        net.Start("want change team")
        net.WriteString("1002")
        net.SendToServer()
    end
end

net.Receive("want change team",function()
    scoreboard:Close()

    surface.PlaySound("buttons/blip1.wav")

    timer.Simple(0.1,function()
        local ply = LocalPlayer()

        ply:ChatPrint(L("you_select_team",L(levelActive:GetTeamName(ply) or "spectators")))
    end)--pizsed
end)

concommand.Add("hg_showteam",function()
    if not scoreboard.status then scoreboard:Open() end
    
    scoreboard:OpenPage(4,true)
end)

if Initialize then scoreboard:Open() end