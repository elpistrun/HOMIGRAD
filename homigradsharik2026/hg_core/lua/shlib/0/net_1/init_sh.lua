local CurTime,FrameTime = CurTime,FrameTime
local player_GetAll = player.GetAll
local event_Call = event.Call

local Time,Frame,i,tbl,ply

if SERVER then
    util.AddNetworkString("initProtocol")
    util.AddNetworkString("initProtocol_Error")
end

event.Add("Think","Players",function()
    if CLIENT and not InitNET then return end--shut the fuck up
    
    Time,Frame = CurTime(),FrameTime()

    i = 0
    tbl = player_GetAll()

    ::start::

    i = i + 1

    ply = tbl[i]
    if not ply then return end

    if ply.init then event_Call("Player Think",ply,Time,Frame) end

    goto start
end,1)--dem

event.Add("Player Think","Time",function(ply,time,frame)
    if (ply.delay20 or 0) < time then
        ply.delay20 = time + 1 / 20

        event_Call("Player Think 20",ply,time,frame)
    end

    if (ply.delay01 or 0) < time then
        ply.delay01 = time + math.Rand(0.09,0.11)

        event_Call("Player Think 0.1",ply,time,frame)
    end

    if (ply.delay025 or 0) < time then
        ply.delay025 = time + math.Rand(0.25,0.3)

        event_Call("Player Think 0.25",ply,time,frame)
    end

    if (ply.delay1 or 0) < time then
        ply.delay1 = time + math.Rand(0.9,1.1)

        event_Call("Player Think 1",ply,time,frame)
    end
end)

hook.Add("StartCommand","SHLib",function(ply,cmd)
    if not ply.init then return true end

    return event_Call("StartCommand",ply,cmd)
end)

hook.Add("Move","SHLib",function(ply,mv)
    if not ply.init then return true end

    return event_Call("Move",ply,mv)
end)

hook.Add("SetupMove","SHLib",function(ply,mv,cmd)
    if not ply.init then return true end

    return event_Call("SetupMove",ply,mv,cmd)
end)

hook.Add("FinishMove","SHLib",function(ply,mv)
    if not ply.init then return true end

    return event_Call("FinishMove",ply,mv)
end)

event.Add("Player Spawn","RemoveDecals",function(ply)
	ply:RemoveAllDecals()--нихуя не работает ;c;c;c;;c;c;c
end)

local PLAYER = FindMetaTable("Player")
if not HPlayerName then HPlayerName = PLAYER.Name end
function PLAYER:Name() return self:GetNWString("Nick",HPlayerName(self)) end
PLAYER.Nick = PLAYER.Name

FindMetaTable("Entity").Nick = function(self) return self:GetNWString("Nick","UNKOWN") end

local skip = {}

gameevent.Listen("player_connect")
hook.Add("player_connect","!SHLIB",function(data)
    local result = event.Call("player_connect",data)

    if result == false then
        skip[data.userid] = true
    end
end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect","!SHLIB",function(data)
    local ply = Player(data.userid)

    if IsValid(ply) then
        event.Call("Player Leave",ply)
    end

    if skip[data.userid] then
        skip[data.userid] = nil

        return
    end
    
    return event.Call("player_disconnect",data)
end)

event.Add("Player Create","move_wish_dir",function(ply)
	ply.move_wish_dir = Vector()
end)

event.Add("Move","move_wish_dir",function(ply,cmv)
	ply.move_wish_dir = cmv:GetVelocity()
end,-100)

hook.Add("OnEntityCreated","Realy call when remove",function(ent)
    if not IsValid(ent) then return end

    ent.createdRealTime = RealTime()

    event.Call("EntityCreate",ent)
end)

if CLIENT then
    hook.Add("NetworkEntityCreated","Homigrad",function(ent)
        event.Call("EntityCreateFull",ent)
    end)
end

hook.Add("EntityRemoved","Realy call when remove",function(ent,fullUpdate)
    if fullUpdate then return end--https://www.youtube.com/watch?v=alOsTZlgxqQ

    event.Call("EntityRemove",ent)
end)

player.list = player.list or {}
local player_list = player.list

local function setup()
    for k,v in pairs(player_list) do player_list[k] = nil end

    for i,ply in pairs(player.GetAll()) do
        player_list[i] = ply
        ply.player_list_iteration = i
    end
end

event.Add("Player Create","player_list",function(ply)
    player_list[#player_list+1] = ply
    ply.player_list_iteration = #player_list
end,-1000)

event.Add("Player Leave","player_list",function(ply)
    table.remove(player_list,ply.player_list_iteration)
    
    for i = 1,#player_list do
        if not IsValid(player_list[i]) then setup() return end
        
        player_list[i].player_list_iteration = i
    end
end,1000)