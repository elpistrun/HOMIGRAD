local Level = oop.Get("level_event")
if not Level then return end

local cursorOrigin,cursorNamem,cursorStart
local cursorDelay = 10

local color = Color(0,255,0)

cursorEntities = cursorEntities or {}

local white = Color(255,255,255)
local black = Color(0,0,0)

function EventCursorGuiDraw(self,w,h)
    surface.SetDrawColor(0,0,0,32)
    surface.DrawRect(0,0,w,h)
    surface.SetDrawColor(0,0,0,64)
    draw.GradientUp(0,0,w,h)

    DisableClipping(true)
    surface.SetDrawColor(0,0,0,16)
    draw.GradientDown(0,-16,w,16)

    draw.SimpleText("Выбраные игроки","HS.18",0,-32)
    draw.SimpleText("Выбрано: " .. table.Count(cursorEntities) .. " из " .. #player.GetAll(),"HS.18",w,-32,nil,TEXT_ALIGN_RIGHT)
    DisableClipping(false)

    surface.SetDrawColor(255,255,255)
    surface.DrawRect(0,0,w,1)
end

function EventCursorGuiUpdate(self)
    local avatarList = self.avatarList
    avatarList:Clear()

    for ent in pairs(cursorEntities) do
        local panel = avatarList:AddPanel(ent:SteamID(),ent:GetNWString("Avatar"),ent:GetNWString("AvatarFrame"))
        function panel:Draw(w,h)
            if not IsValid(ent) then cursorEntities[ent] = nil EventCursorGuiUpdate(EVENTCURSORGUI) return end

            draw.SimpleText(ent:Name(),"HS.12",h / 2,h / 2,nil,nil,TEXT_ALIGN_CENTER)
        end
    end

    EventPanel_Update(2)
end

local old

function Level:HUDCursor()
        if Event_CanAccess(LocalPlayer(),EventCanHelpHiredAdmins) then
        local active = input.IsMouseDown(MOUSE_MIDDLE)

        if active then
            local trace = LocalPlayer():EyeTrace()

            local ent = trace.Entity

            if IsValid(ent) and not cursorEntities[ent] and ent:IsPlayer() then
                cursorEntities[ent] = true

                net.Start("event_cursor")
                net.WriteEntity(ent)
                net.SendToServer()

                old = active
            end
        end

        if old ~= active then
            old = active
            
            if active then
                net.Start("event_cursor")
                net.WriteEntity(ent)
                net.SendToServer()
            end
        end
    end

    /*if cursorStart and cursorOrigin then
        local k = math.max(cursorStart + cursorDelay - RealTime(),0) / cursorDelay
        
        if k > 0 then
            surface.SetAlphaMultiplier(k)
            local pos = cursorOrigin:ToScreen()
            draw.RoundedBox(2,pos.x - 2,pos.y - 2,4,4,color)
            draw.SimpleText(cursorName,"HS.12",pos.x,pos.y + 12,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            surface.SetAlphaMultiplier(1)
        end
    end*/

    local w,h = ScrW(),ScrH()

    local drawCursor = table.Count(cursorEntities) > 0

    local x,y = w * 0.3,h * 0.4

    if drawCursor then
        if not IsValid(EVENTCURSORGUI) then
            EVENTCURSORGUI = oop.CreatePanel("v_panel"):ad(function(self,w,h) self:setSize(w * 0.35,h * 0.3):setPos(w * 0.4 - self:W(),h * 0.4) end)
            EVENTCURSORGUI.Draw = function(self,w,h) EventCursorGuiDraw(self,w,h) end
            EVENTCURSORGUI.Update = function(self) EventCursorGuiUpdate(self) end
            EVENTCURSORGUI:SetZPos(-100)
            
            local avatarList = oop.CreatePanel("v_avatarlist",EVENTCURSORGUI):setDSize(1,1)
            avatarList:Setup(32)

            EVENTCURSORGUI.avatarList = avatarList
        end

        draw.RoundedBox(6,w/2 - 3,h/2 - 3,6,6,black)
        draw.RoundedBox(4,w/2 - 2,h/2 - 2,4,4,white)
    else
        if IsValid(EVENTCURSORGUI) then EVENTCURSORGUI:Remove() end
    end
end

net.Receive("event_cursor",function()
    cursorEntities = net.ReadTable()

    if IsValid(EVENTCURSORGUI) then EVENTCURSORGUI:Update() end
end)

local white = Color(255,255,255)
local listHalos = {}

hook.Add("PreDrawHalos","EventCursorEnt",function()
    listHalos = {}

    for ent in pairs(cursorEntities) do
        if IsValid(ent) then
            if (ent:IsPlayer() and not ent:Alive()) then continue end

            listHalos[#listHalos + 1] = ent
        end
    end

    halo.Add(listHalos,white,5,5,2)
end)