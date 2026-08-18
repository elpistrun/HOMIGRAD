player.classList = player.classList or {}
local classList = player.classList

local PlayerMeta = FindMetaTable("Player")

local empty = {}
function PlayerMeta:GetPlayerClass(class)
    class = classList[class or self.PlayerClassName or ""]
    if class then return class[1] end
end

if adminPanel and adminPanel.commandRegistry then xpcall(adminPanel.commandRegistry,function() end,"playerclass",{{type = "players",required = true},{type = "string",required = true}},"game") end

local meta
function PlayerMeta:PlayerClassEvent(name,...)
    meta = self:GetPlayerClass()

    if meta and meta[name] then return meta[name](self,...) end
end

function player.RegClass(class,base,isFolder)
    return oop.Reg(class,base,isFolder,0,classList)
end

function player.GetClass(class)
    return oop.Get(class,classes)
end

local empty = {}

hook.Add("Think","PlayerClass",function()
    local list = {}

    for i,ply in pairs(player.GetAll()) do
        local class = ply:GetPlayerClass()
        if not class then continue end

        list[class] = list[class] or {}
        list[class][ply] = true
    end

    for name,class in pairs(classList) do
        local func = class.GlobalThink
        if func then func(list) end
        local func = class.Think

        if not func then continue end

        for ply in pairs(list[class] or empty) do
            class.Think(ply,list)
        end
    end
end)

function player.EventPoint(pos,name,radius,...)
    for i,ply in pairs(player.GetAll()) do
        if ply:GetPos():Distance(pos) > radius then continue end

        ply:PlayerClassEvent("EventPoint",name,pos,radius,...)
    end
end

function player.Event(ply,name,...)
    ply:PlayerClassEvent("Event",name,...)
end

if SERVER then return end

net.Receive("setupclass",function()
    local ply = net.ReadEntity()
    if not IsValid(ply) then return end--lol

    local oldClass = ply.PlayerClassName
    if oldClass then
        oldClass = ply:GetPlayerClass(oldClass)

        if oldClass and oldClass.Off then oldClass.Off(self) end
    end

    local class = net.ReadString()
    ply.PlayerClassName = class ~= "" and class or nil
    if ply.PlayerClassName then ply:PlayerClassEvent("On") end
end)
