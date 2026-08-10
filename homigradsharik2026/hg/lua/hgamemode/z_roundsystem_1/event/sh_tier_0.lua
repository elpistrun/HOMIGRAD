local Level = oop.Reg("level_event","level_base",true)
if not Level then return INCLUDE_BREAK end

Level.teamEncoder = {
    [1] = "red"
}

Level.red = {"Play",Color(255,255,255),
    models = Level.StandardPlayerModels
}

function Level:GetTeamName(ply)

end

function Level:CanUseContextMenu(ply) return Event_CanAccess(ply,EventCanHelpHiredAdmins) end
function Level:CanUseSpawnMenu(ply) return Event_CanAccess(ply,EventCanHelpHiredAdmins) end

if SERVER then return end

function Level:HUDPaint(white2)
    self:HUDCursor()

    if not LocalPlayer():Alive() then
        local group = LocalPlayer().eventGroup

        if IsSpectate == 1 and group and group.spawnTime >= 0 then
            local time = math.floor(LocalPlayer():GetNWFloat("DeathStart",0) + group.spawnTime - CurTime())
            
            local text

            if time < 0 then
                text = L("click_for_spawn")

                if input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT) then
                    net.Start("event_respawn")
                    net.SendToServer()
                end
            else
                text = L("spawn_from_second",time)
            end

            draw.SimpleText(text,"HS.18",ScrW() / 2,ScrH() * 0.25,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end
end

function Level:GetTeamName(ply)
    local eventGroup = ply.eventGroup
    
    if not eventGroup then
        if ply:Team() != 1 then
            return "spectator",SpectatorGray
        else
            return "",black
        end
    end

    return eventGroup.name,eventGroup.color
end

local empty = {}

function Level:ScoreboardSort(sort,teams)
    local SORT = {}

    local players = player.GetAll()

    for id,group in pairs(EventGroups or empty) do
        for i,ply in pairs(players) do
            if not group.list[ply:SteamID()] then continue end

            SORT[id] = SORT[id] or {
                alive = {},
                dead = {}
            }
            
            local tbl = SORT[id][ply:Alive() and "alive" or "dead"]
            tbl[#tbl + 1] = ply

            players[i] = nil
        end
    end

    SORT[#SORT + 1] = {
        alive = {},
        dead = {}
    }

    local lastSort = SORT[#SORT]

    for i,ply in pairs(players) do
        local tbl = lastSort[ply:Alive() and "alive" or "dead"]
        tbl[#tbl + 1] = ply
    end

    for _,list in pairs(SORT) do
        for i,ply in pairs(list.alive) do sort[#sort + 1] = ply end
        for i,ply in pairs(list.dead) do sort[#sort + 1] = ply end
    end
end