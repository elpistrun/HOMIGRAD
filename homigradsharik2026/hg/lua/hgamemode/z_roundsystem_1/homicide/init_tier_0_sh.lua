local Level = oop.Reg("level_homicide","level_base",true)
if not Level then return INCLUDE_BREAK end

pointManager:Registry("onlyhomicide",Color(0,0,255),"general")


adminPanel.commandRegistry("homicide_sett",{"players^"},"game")
adminPanel.commandRegistry("homicide_get",{},"game")

pointManager:Registry("police_arrive_car",Color(0,255,255),"general")

function Level:RandomOften() return math.random(1,2) == 2 end

Level.red = {"innocent",Color(122,122,122),models = Level.StandardPlayerModels}
Level.teamEncoder = {
	[1] = "red"
}

Level.LevelRoundsNext = 2
Level.ShouldSpawnLoot = true
Level.PropBreakLoot = true

local roundTypes = {
    [1] = {
        name = "State of Emergency",
        playsnd = "snd_jack_hmcd_disaster.mp3"
    },
    [2] = {
        name = "Standard",
        playsnd = "snd_jack_hmcd_shining.mp3"
    },
    [3] = {
        name = "Gun-Free-Zone",
        playsnd = "snd_jack_hmcd_panic.mp3"
    },
    [4] = {
        name = "Wild West",
        playsnd = "snd_jack_hmcd_wildwest.mp3"
    },
}

Level.ColorRed = Color(255,0,0)
Level.ColorBlue = Color(0,0,255)

if SERVER then return end

local empty = {}

function Level:Sync(data)
    for i,ply in pairs(player.GetAll()) do
        ply.roleT = false
        ply.roleCT = false
    end

    for i,ply in pairs(data.traitors or empty) do ply.roleT = true end
    for i,ply in pairs(data.inoccent or empty) do ply.roleCT = true end

    roundType = data.roundType
end

function Level:GetTeamName(ply)
    if ply.roleT then return "traitor",Level.ColorRed end
    if ply.roleCT then return "innocent",Level.ColorBlue end

    local teamID = ply:Team()

    if teamID <= 3 then
        return "innocent",Level.red[2]
    end
end

local black = Color(0,0,0,255)

function Level:HUDPaint_Spectate(spec)
    --local name,color = homicide.GetTeamName(spec)
    --draw.SimpleText(name,"H.25",ScrW() / 2,ScrH() - 150,color,TEXT_ALIGN_CENTER)
end

function Level:Scoreboard_Status(ply)
    local lply = LocalPlayer()
    if lply.roleT or not lply:Alive() then return end

    return "unknown",ScoreboardSpec
end

Level.LoadScreenTime = 6

function Level:DrawScreen(lply,k)
    local name,color = self:GetTeamName(lply)

    local w,h = ScrW(),ScrH()

    draw.DrawText(L("you",L(name)),"H.25",w / 2,h / 2,cname,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.DrawText(L("level_homicide"),"H.45",w / 2,h / 8,cblue,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.DrawText(roundTypes[roundType].name,"H.25",w / 2,h / 5,cblue,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    if lply.roleT then
        draw.DrawText(L("homicide_loadscreen_roleT"),"H.25",w / 2,h / 1.2,cred,TEXT_ALIGN_CENTER)
    elseif lply.roleCT then
        if roundType == 2 then 
            draw.DrawText(L("homicide_loadscreen_roleCT2"),"H.25",w / 2,h / 1.2,cblue,TEXT_ALIGN_CENTER)
        else
            draw.DrawText(L("homicide_loadscreen_roleCT"),"H.25",w / 2,h / 1.2,cblue,TEXT_ALIGN_CENTER)
        end
    else
        draw.DrawText(L("homicide_loadscreen"),"H.25",w / 2,h / 1.2,cgray,TEXT_ALIGN_CENTER)
    end
end

local colorRed = Color(255,0,0)
local colorBlue = Color(55,55,255)

function Level:HUDPaint(k)
    local lply = LocalPlayer()
    local name,color = self:GetTeamName(lply)

    self:DrawLoadScreen()
    self:DrawCenter()
  
    local time = math.Round(roundTimeStart + roundTime - CurTime())
    if time > 0 then
        local acurcetime = string.FormattedTime(time,"%02i:%02i")
        acurcetime = L("police_come",acurcetime)

        draw.SimpleText(acurcetime,"H.18",ScrW() / 2,ScrH() - 25,showRoundInfoColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local lply_pos = lply:GetPos()

    local trace = lply:EyeTrace()

    for i,ply in pairs(player.GetAll()) do
        local color = ply.roleT and self.ColorRed
        if not color or ply == lply or not ply:Alive() then continue end

        local pos = ply:GetPos()
        local dis = lply_pos:Distance(pos)

        local k = math.max(1 - dis / 800,0)

        local pos = pos:ToScreen()
        if not pos.visible then continue end
        
        if Vector(pos.x,pos.y,0):Distance(Vector(ScrW()/2,ScrH()/2,0)) <= 128 / math.max(dis / 512,1) and util.VisibleEntity(EyePos(),ply,LocalPlayer()) then k = 1 end

        color = color:Clone()
        color.a = 255 * k

        draw.SimpleText(ply:Nick(),"H.18",pos.x,pos.y,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity.roleCT then
        local pos = trace.Entity:GetPos():ToScreen()

        draw.SimpleText(trace.Entity:Nick(),"H.18",pos.x,pos.y,colorBlue,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    if not lply.roleT or (lply:Alive() and lply:GetNWBool("Otrub")) then return end

    local trace = lply:EyeTrace(PlayerDis)
    local ent = trace.Entity
    
    if IsValid(ent) and ent:GetNWBool("Poison") then
        local pos = ent:GetPos():Add(ent:OBBCenter()):ToScreen()

        draw.SimpleText(L("object_is_poison"),"HS.12",pos.x,pos.y,colorRed,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    self:DrawTTTButtons()
    self:DrawScan()
end

function Level:VBWHide(ply,list)
    if ply:Team() == 1002 then return end

    local blad = {}

    for i = 1,#list do
        local wep = list[i]
        if wep.itemType == "weaponSecondary" then continue end

        blad[#blad + 1] = wep
    end--ufff

    return blad
end

function Level:Scoreboard_DrawLast(ply)
    if LocalPlayer():Team() ~= 1002 and LocalPlayer():Alive() then return false end
end

function Level:End() self:StartWinnerVGUI(roundDataEnd.winnerVGUI) end