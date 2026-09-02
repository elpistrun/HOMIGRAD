local Level = oop.Reg("level_nextbot","level_base",true)
if not Level then return INCLUDE_BREAK end

pointManager:Registry("nextbot",Color(125,125,125),"nextbot")
pointManager:Registry("nextbot_canfind",Color(255,0,0),"nextbot")
pointManager:Registry("autokickdoor_player",Color(255,255,255),"nextbot")

function Level:CanRandomNext() return pointManager:GetList("nextbot") end

Level.TimeLoadScreen = 6
Level.LevelRoundsNext = 3

Level.red = {
	"NextBot",Color(255,0,0),
    models = Level.StandardPlayerModels
}

Level.blue = {
	"Player",Color(0,255,0),
    models = Level.StandardPlayerModels
}

function Level:GetMax2() return pointManager:GetList("nextbot") end

Level.teamEncoder = {
	[1] = "red",
    [2] = "blue",
}

Level.nextbotsTouhou = {
    "npc_komeiji_fumo_enemy",
    "npc_yuyuko",
    "npc_flandrenextbot",
    "npc_sakuyanextbot"
}

Level.nextbotsHondaMio = {
    "npc_honda_mio",
}

Level.nextbotsScared = {
    "npc_kevin",
    "npc_kevin",
    "npc_kevin",
    "npc_youseemee",
    "npc_youseemee",
    "npc_car",
}

function Level:EyeDefault() return true end

if SERVER then return end

function Level:Sync(data)
    roundType = data.roundType
end

local cgray = Color(125,125,125)

local materials = {
    Material("npc_sakuyanextbot/sakuyanextbot"),
    Material("npc_flandrenextbot/flandrenextbot"),
    Material("fumo/npc_fumo.png", "smooth mips"),
    Material("npc_yuyuko/yuyuko"),
    Material("npc_komeiji_fumo_friendly/komeiji_fumo_friendly.png"),
    Material("npc_koishinextbot/koishinextbot")
}

function Level:DrawScreenTouhou(lply,k)
    local name,color = self:GetTeamName(lply)

    local c = (state == 1 and Color(255,255,255)) or HSVToColor(CurTime() * 360 % 360,1,1)
    c.a = 255 * k

    local w,h = ScrW(),ScrH()

    draw.DrawText(L("you",L(name)),"H.25",w / 2,h / 2,cname,TEXT_ALIGN_CENTER)
    draw.DrawText("NextBot" .. (state == 1 and "" or " with Touhou! ;3"),"H.25",w / 2,h / 8,c,TEXT_ALIGN_CENTER)

    surface.SetMaterial(materials[1 + math.floor(CurTime() % (#materials - 1))])
    surface.SetDrawColor(255,255,255,255 * k)
    surface.DrawTexturedRectRotated(
        ScrW() / 2,ScrH() / 1.45,
        128 + math.cos(CurTime() * 16) * 25,
        128 + math.sin(CurTime() * 16) * 25,
        math.cos(CurTime() * 14) * 25
    )

    draw.DrawText("Fumos!","H.25",w / 2,h - h / 8,c,TEXT_ALIGN_CENTER)
end

local smile = Material("homigrad/scp/scared/youseemee1.png")

function Level:DrawScreenScared(lply,k)
    local w,h = ScrW(),ScrH()

    surface.SetDrawColor(0,0,0,255 * k)
    surface.DrawRect(0,0,ScrW(),ScrH())

    surface.SetMaterial(smile)
    surface.SetDrawColor(75,75,75,1 + math.random(5,14) * k)
    surface.DrawTexturedRect(0,0,ScrW(),ScrH())

    local a = math.random(5,15) * k

    draw.DrawText("the fog is coming","chatfont",w / 2,h / 2,Color(255,255,255,a),TEXT_ALIGN_CENTER)
end

local mat = Material("homigrad/scp/honda_mio/1.png")

function Level:DrawScreenHondaMio(lply,k)
    local name,color = self:GetTeamName(lply)

    local c = (state == 1 and Color(255,255,255)) or HSVToColor(CurTime() * 360 % 360,1,1)
    c.a = 255 * k

    local w,h = ScrW(),ScrH()

    draw.DrawText(L("you",L(name)),"H.25",w / 2,h / 2,cname,TEXT_ALIGN_CENTER)
    draw.DrawText("NextBot","H.25",w / 2,h / 8,c,TEXT_ALIGN_CENTER)

    surface.SetMaterial(mat)
    surface.SetDrawColor(255,255,255,255 * k)
    surface.DrawTexturedRectRotated(
        ScrW() / 2,ScrH() / 1.45,
        128 + math.cos(CurTime() * 16) * 25,
        128 + math.sin(CurTime() * 16) * 25,
        math.cos(CurTime() * 14) * 25
    )

    draw.DrawText("Honda Mio!","H.25",w / 2,h - h / 8,c,TEXT_ALIGN_CENTER)
end

function Level:DrawScreen(lply,k)
    if roundType == "touhou" then
        self:DrawScreenTouhou(lply,k)
    elseif roundType == "honda mio" then
        self:DrawScreenHondaMio(lply,k)
    elseif roundType == "scared" then
        self:DrawScreenScared(lply,k)
    end
end

local old = 0
local startShow = 0

local delayHit = 0

function Level:HUDPaint()
    self:DrawLoadScreen()
	self:DrawRoundTime()

    local active = LocalPlayer():GetNWFloat("DefNextBotCount",0)

    if old ~= active then
        old = active

        startShow = RealTime() + 3

        if delayHit < RealTime() then
            delayHit = RealTime() + 0.1

            LocalPlayer():EmitSound("homigrad/vgui/menu_accept.wav",75,100,0.5)
        end
    end

    local k = math.Clamp(startShow - RealTime(),0,1)

    surface.SetAlphaMultiplier(k)

    surface.SetDrawColor(255,255,255,64)

    local x,y = ScrW() * 0.5,ScrH() * 0.9
    local size = math.floor(100 * k)

    draw.GradientRight(x - size,y - 45/2,size,45)
    draw.GradientLeft(x,y - 45/2,size,45)

    draw.SimpleText(active,"HS.45",x,y,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    surface.SetAlphaMultiplier(1)
end

//function Level:ShouldViewCamera() return true end

local defActive

function Level:Think()
    local ply = LocalPlayer()

    if not ply:Alive() or ply:GetMoveType() ~= MOVETYPE_WALK then return end
    
    if input.IsKeyDown(KEY_SPACE) then
        if ply:IsOnGround() then
            RunConsoleCommand("+jump")

            timer.Create("Bhop",0,0,function() RunConsoleCommand("-jump") end)
        end
    else
        RunConsoleCommand("-jump")
    end

    local active = ply:KeyDown(IN_ATTACK)

    if active ~= defActive then
        defActive = active

        if active and not ply:GetNWBool("Fake") and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_hands" and ply:GetNWFloat("DefNextBotCount",0) > 0 then
            ply:SetNWFloat("DefNextBotCount",ply:GetNWFloat("DefNextBotCount",0) - 1)

            net.Start("nextbot_def",true)
            net.SendToServer()

            timer.Simple(LocalPlayer():Ping() / 1000,function()
                Level:StartBlock()
            end)//не факт ваще х3
        end
    end
end

function Level:DrawScreenspace() return false end

function Level:SpectateNext(tbl)
    for ent in pairs(g_nextbots) do
        if not IsValid(ent) then g_nextbots[ent] = nil continue end
        
        tbl[#tbl + 1] = ent
    end
end