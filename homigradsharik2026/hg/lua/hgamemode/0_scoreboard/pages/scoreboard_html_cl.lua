player.muteSteamIDIndex = util.JSONToTable(file.Read("homigrad_mute.txt","DATA") or "") or {}

function player.mute(ply,value)
	if value == false or value == 1 then value = nil end
    
	player.muteSteamIDIndex[ply:SteamID()] = value

	file.Write("homigrad_mute.txt",util.TableToJSON(player.muteSteamIDIndex))
end

local SetDrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect

local mat_speaker_1 = Material( "homigrad/vgui/icons/speaker/voice_1.png","noclamp smooth")
local mat_speaker_2 = Material( "homigrad/vgui/icons/speaker/voice_2.png","noclamp smooth")
local mat_speaker_3 = Material( "homigrad/vgui/icons/speaker/voice_3.png","noclamp smooth")

local mat_speaker_mute = Material( "homigrad/vgui/icons/speaker/voice_mute.png","noclamp smooth")

local color_gray = Color(125,125,125)
local white = Color(255,255,255,255)
local empty = {}

function scoreboard.DrawPlayer(ply,w,h,tbl,self)
    local font = scoreboard.playerFont

    tbl = tbl or empty
    if TypeID(ply) != TYPE_TABLE and not IsValid(ply) then return end
    
    SetDrawColor(0,0,0,75)
    DrawRect(0,0,w,h)

    if ply == LocalPlayer() then
        SetDrawColor(125,125,125,15)
        DrawRect(0,0,w,h)
    end

    local alive,colorAlive,colorAddAlive

    if not tbl.dontDrawAlive then
        alive,colorAlive,colorAddAlive = ply:GetAliveStatus()

        if colorAddAlive then
            SetDrawColor(colorAddAlive.r,colorAddAlive.g,colorAddAlive.b,5)
            DrawRect(0,0,w,h)

            SetDrawColor(colorAddAlive.r / 2,colorAddAlive.g / 2,colorAddAlive.b / 2,75)
            draw.GradientLeft(0,0,w / 4,h)
        else
            SetDrawColor(colorAlive.r / 5,colorAlive.g / 5,colorAlive.b / 5,75)
            draw.GradientLeft(0,0,w / 4,h)
        end

        draw.SimpleText(L(alive),font,h / 2,h / 2,colorAlive,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
    end

    local nameGroup = ply:GetUserName()

    if not nameGroup then
        local group = adminPanelRole.GetStockUserGroup and adminPanelRole.GetStockUserGroup(ply)
        nameGroup = group or "user"
    end

    local color = ply:GetUserColor() or white

    if color then
        if not tbl.dontDrawGroup then
            if nameGroup then
                SetDrawColor(color)
                DrawRect(0,h - 2,w,2)
                
                local xPos = tbl.dontDrawAlive and h / 2 or w * 0.25

                if tbl.dontDrawAlive then
                    draw.SimpleText(nameGroup,font,xPos,h / 2,ply:GetNWBool("DontShowMyPerm") and color_gray or color,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText(nameGroup,font,xPos,h / 2,ply:GetNWBool("DontShowMyPerm") and color_gray or color,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
                end

                SetDrawColor(color.r / 4,color.g / 4,color.b / 4,75)
                draw.GradientDown(0,h / 2,w,h / 2)
            end
        end
    end

    if ply:IsBot() then draw.SimpleText("BOT","HS.12",w / 2,4,color_gray,TEXT_ALIGN_CENTER) end
    
    if colorAddAlive then
        SetDrawColor(colorAddAlive.r,colorAddAlive.g,colorAddAlive.b,255)
        DrawRect(0,0,2,h)
    elseif not tbl.dontDrawAlive then
        SetDrawColor(colorAlive.r,colorAlive.g,colorAlive.b,255)
        DrawRect(0,0,2,h)
    end

    if not tbl.dontDrawTime then
        local hours = ply:GetTimeStatus()

        if tbl.dontDrawTeam then
            if hours then
                draw.SimpleText(hours .. "h",font,w - h / 2,h / 2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
            else
                DrawLoading(w - h / 2,h / 2,h / 2,h / 2)
            end
        else
            if hours then
                draw.SimpleText(hours .. "h",font,w * 0.7,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            else
                DrawLoading(w * 0.7,h / 2,h / 2,h / 2)
            end
        end
    end

    if not tbl.dontDrawTeam then
        local name,color = ply:GetTeamStatus()

        SetDrawColor(color.r / 2,color.g / 2,color.b / 2,75)
        draw.GradientRight(w - w / 3,0,w / 3,h)

        SetDrawColor(color.r,color.g,color.b,255)
        DrawRect(w - 2,0,2,h)

        draw.SimpleText(L(name),font,w - h / 2,h / 2,color,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
    end

    draw.Frame(0,0,w,h,cframe1,cframe2)
end

local discord_icon = Material("homigrad/discord_icon.png")

function ScoreboardAddPlayerHTML(html,ply,tab)
    local p,avatar = html:AddPlayer(ply)

    local avatarImage = oop.CreatePanel("v_avatarimage",avatar):ad(function(self,w,h)
        local size = scoreboard.iconSize
        local wide = size * 0.25
        self:setSize(size,size):setPos(wide,wide)
    end)
    if IsValid(ply) then avatarImage:SetPlayer(ply,184) end
    if avatarImage.SetPaintCorner then avatarImage:SetPaintCorner(2) end

    function avatar:Draw(w,h)
        plyVoice.Draw(w,h,ply,1)
    end

    function avatar:DrawOver(w,h)
        if not IsValid(ply) then return end
        
        if ply:GetNWBool("DontShowMyDiscord") then return end
        
        local profile = ply:GetDiscordProfile()
        if not profile then return end

        self:SetCursor("blank")

        surface.SetMaterial(discord_icon)
        surface.SetDrawColor(86,98,246)
        local corner = w * 0.25/2
        surface.DrawTexturedRectRotated(corner,corner,w/4,w/4,25)

        if self:IsHovered() then
            DiscordProfileDraw(ply:SteamID(),gui.MouseX(),gui.MouseY(),{
                avatar = profile.avatar,
                banner = profile.banner,
                username = profile.username,
                displayName = profile.displayName,
                roles = ply:GetNWBool("DontShowMyPerm") and {["user"] = true} or ply.roles
            })
        end 
    end

    function p:Draw(w,h)
        scoreboard.DrawPlayer(ply,w,h,tab or {drawDiscordProfile = true},self)
    end

    function p:OnClick(value)
        if value ~= MOUSE_RIGHT then return end

        player.OpenDermaMenu(ply)
    end

    return p,avatar
end

local color_green,color_red = Color(75,255,75),Color(255,75,75)

function ScoreboardBuildOnHTML(panel,scroll,scrollPing,scrollMute)
    local html = oop.CreatePanel("v_avatarlist",scroll)
    html.fontSize = scoreboard.playerFontSize + 1
    html:Setup(panel.iconSize)

    html:SetScrollPanel(scroll)

    scroll:CreateVBar()

    function html:Update()
        html:Clear()--очищает html элементы

        scroll:Clear()
        scrollPing:Clear()
        scrollMute:Clear()

        for id,ply in pairs(panel.sort or {}) do
            local panel,avatar = ScoreboardAddPlayerHTML(html,ply)

            local panelPing = oop.CreatePanel("v_panel",scrollPing):ad(function(self,w,h) self:setPos(0,panel.y):setSize(scrollPing:W(),scrollPing:W()) end)

            function panelPing:Draw(w,h)
                draw.SimpleText(ply:Ping(),scoreboard.font,w/2,h/2,color_gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end

            local panelMute = oop.CreatePanel("v_button",scrollMute):ad(function(self,w,h) self:setPos(0,panel.y):setSize(scrollPing:W(),scrollPing:W()) end)

            local oldK
            local delaySND = 0

            function panelMute:Draw(w,h)
                local k = player.muteSteamIDIndex[ply:SteamID()] or 1
                if k == true then k = 0 end

                surface.SetMaterial(k <= 0 and mat_speaker_mute or (k > 0 and k <= 1 / 3 and mat_speaker_1) or (k > 1 / 3 and k <= (1 / 3 * 2) and mat_speaker_2) or mat_speaker_3)
                local size = h * (0.75 + math.max(self.hovered,0) / 10)

                surface.SetDrawColor(0,0,0,128)
                surface.DrawTexturedRectRotated(w/2 + 6,h/2 + 6,size,size,0)
                
                surface.SetDrawColor(40,40,40,255)
                surface.DrawTexturedRectRotated(w/2,h/2,size,size,0)

                local x,y = self:LocalToScreen(0,0)
                
                render.SetScissorRect(0,0,x + w / 2 - size / 2 + size * k,ScrH(),true)
                    surface.SetDrawColor(255,255,255,100)
                    surface.DrawTexturedRectRotated(w/2,h/2,size,size,0)
                render.SetScissorRect(0,0,0,0,false)

                if self.mouse[MOUSE_LEFT] then
                    k = math.max(gui.MouseX() - x,0) / w
                    k = math.Clamp(k,0,1)

                    player.mute(ply,k)
                end

                if k > 0 and k < 1 then
                    DisableClipping(true)
                    draw.SimpleText(math.floor(k * 100) .. "%",scoreboard.font,w / 2,h,color_gray,TEXT_ALIGN_CENTER)
                    DisableClipping(false)
                elseif k == 0 then
                    DisableClipping(true)
                    draw.SimpleText("MUTED",scoreboard.font,w / 2,h,color_gray,TEXT_ALIGN_CENTER)
                    DisableClipping(false)
                end

                k = math.Round(k * 100) / 100

                if not oldK then oldK = k end

                if oldK ~= k then
                    oldK = k

                    if delaySND < RealTime() then
                        delaySND = RealTime() + 1 / 20

                        sound.EmitScreen("homigrad/vgui/csgo_ui_contract_type5.wav",0.33,255)
                    end
                end
            end
        end

        function panel:Step()
            for id,ply in pairs(panel.sort or {}) do
                if not IsValid(ply) then panel:Update() break end
            end
        end
    end

    html.OnReady = html.Update

    local particles = particles2D:Create()
    particles.friction = 0
    particles.gravity = {0,0}
    
    particles.SetDrawFunction(function(part,ft)
        local col = 65 + math.max(65 * math.cos(part[1] / 100 - particles.Time() * 3),0)

        surface.SetDrawColor(col,col,col,65)
        surface.DrawRect(part[1] - 1,part[2] - 1,2,2)

        part[4] = part[4] + math.sin(part[2] / 100) * 60 * ft
    end)

    local delay = 0

    function panel:DrawScoreboard(w,h)
        --[[particles.Draw(w,h,FrameTime() * 1)

        if #particles.list < 100 and delay < RealTime() then
            delay = RealTime() + 0.1

            if math.random(0,1) == 1 then
                particles.Add(w,math.random(0,w),-math.random(20,40),math.random(-60,60))
            else
                particles.Add(0,math.random(0,w),math.random(20,40),math.random(-60,60))
            end
        end]]--

        local font = scoreboard.font

        DisableClipping(true)

        draw.SimpleText(GetHostName(),"HS.45",ScrW() - self.x - ScrW() / 2,-self.y / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        draw.SimpleText(L("scoreboard_players",#(self.sort or {})),font,20,h + 20,ScoreboardGreen,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

        local tick = math.Round(1 / ServerPerformance[1])
        draw.SimpleText(L("scoreboard_tickrate",tick),font,w - 15,h + 20,tick <= 15 and ScoreboardRed or ScoreboardGreen,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
 
        local tick = math.ceil(1 / ServerPerformance[2])
        if tick > 1000 then tick = ">1000" end

        draw.SimpleText(L("scoreboard_tickrate_phys",tick),font,w - 150,h + 20,tick ~= ">1000" and ScoreboardRed or ScoreboardBlue,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

        DisableClipping(false)

        local x = self.iconSize + self.WIDE * 2
        w = w - x - self.WIDE - scroll.vbar:W()
        
        draw.SimpleText(L("scoreboard_status"),font,x + self.iconSize / 2,20,white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("scoreboard_name"),font,x + w / 2,20,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        draw.SimpleText(L("scoreboard_played"),font,x + w * 0.7,20,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        draw.SimpleText(L("scoreboard_team"),font,x + w - scoreboard.iconSize / 2,20,white,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
    end

    function scroll:DrawOver(w,h)
        SetDrawColor(255,255,255,25)
        draw.GradientRight(0,0,w / 2,1)
        SetDrawColor(55,55,55,25)
        draw.GradientLeft(0,0,w / 2,1)
        
        SetDrawColor(255,255,255,25)
        draw.GradientLeft(w / 2,0,w / 2,1)
        SetDrawColor(55,55,55,25)
        draw.GradientRight(w / 2,0,w / 2,1)

        SetDrawColor(255,255,255,25)
        draw.GradientRight(0,h - 1,w / 2,1)
        SetDrawColor(55,55,55,25)
        draw.GradientLeft(0,h - 1,w / 2,1)

        SetDrawColor(255,255,255,25)
        draw.GradientLeft(w / 2,h - 1,w / 2,1)
        SetDrawColor(55,55,55,25)
        draw.GradientRight(w / 2,h - 1,w / 2,1)
    end

    function scrollPing:Draw(w,h)
        DisableClipping(true)
        draw.SimpleText(L("scoreboard_ping"),scoreboard.font,w/2,-20,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        DisableClipping(false)
    end

    function scrollMute:Draw(w,h)
        DisableClipping(true)
        draw.SimpleText(L("Mute"),scoreboard.font,w/2,-20,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        DisableClipping(false)
    end

    local muteDeath = oop.CreatePanel("v_button",panel:GetParent()):ad(function(self,w,h) self:setSize(200,40):setPos(panel.x,panel.y + panel:H() + 40) end)
    muteDeath:SetupDrawStyle("white")
    
    function muteDeath:DrawText(w,h)
        draw.SimpleText("Замутить мёртвых","H25",w/2,h/2,player.muteDeath and color_green or color_red,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    function muteDeath:OnClick() player.muteDeath = not player.muteDeath end

    local muteAll = oop.CreatePanel("v_button",panel:GetParent()):ad(function(self,w,h) self:setSize(200,40):setPos(panel.x + panel:W() - self:W(),panel.y + panel:H() + 40) end)
    muteAll:SetupDrawStyle("white")

    function muteAll:DrawText(w,h)
        draw.SimpleText("Замутить всех","H25",w/2,h/2,player.muteAll and color_green or color_red,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    function muteAll:OnClick() player.muteAll = not player.muteAll end

    return html
end

plyVoice:Event_Add("Volume","MuteAll",function(ply,value)
    if player.muteAll then value[1] = 0 return false end
end,-10)

plyVoice:Event_Add("Volume","MuteAllDeath",function(ply,value)
    if player.muteDeath and not ply:Alive() then value[1] = 0 return false end
end,-10)

plyVoice:Event_Add("Volume","Change Global Volume",function(ply,value)
    value[1] = value[1] * (tonumber(player.muteSteamIDIndex[ply:SteamID()]) or 1)
end,2)

plyVoice:Event_Add("Volume","Change Death Volume",function(ply,value)
    value[1] = value[1] * (ply:Alive() and 1 or 0.7)
end,2)

if Initialize and LocalPlayer():SteamID() == "STEAM_0:1:164889146" then scoreboard:Open() end