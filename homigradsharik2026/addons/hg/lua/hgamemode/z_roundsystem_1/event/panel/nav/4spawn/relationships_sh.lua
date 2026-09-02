EventGroupRealships = EventGroupRealships or {}

local function addEdit(name,data)
    EventGroupRealships[name] = data
end

if SERVER then
    event.Add("Event Group Create","RelationShips",function(group,groupID)
        for name,edit in pairs(EventGroupRealships) do edit.createGroup(group) end
    end)

    function EventSpawnRelationshipsCMD(cmd,group,groupID,args)
        local edit = EventGroupRealships[cmd]
        if not edit then return end

        local groupLink = args[1]
        table.remove(args,1)
        
        edit.cmd(group,groupLink,args)
    end
end

addEdit("cantdamage",{
    title = "Урон",
    cmd = function(group,groupLink,args)
        group.cantDamage[groupLink] = (tonumber(args[1] or 0) or 0) > 0
    end,
    createGroup = function(group)
        group.cantDamage = {[group.link] = true}
    end,
    getText = function(group,groupSelect)
        return group.cantDamage[groupSelect.link] and "Запрещён" or "Разрещён"
    end,
    getTextEntry = function(group,groupSelect)
        return group.cantDamage[groupSelect.link] and 1 or 0
    end,
    tip = "Напишите 1 если хотите запретить урон\nНапишите 0 если нет"
})

addEdit("cantloot",{
    title = "Лутать",
    cmd = function(group,groupLink,args)
        local type = math.Clamp(args[1] or 0,0,2)

        group.cantLoot[groupLink] = type
    end,
    createGroup = function(group)
        group.cantLoot = {[group.link] = 2}
    end,
    getText = function(group,groupSelect)
        local type = group.cantLoot[groupSelect.link]

        if not type or type == 0 then return "Можно" end
        if type == 1 then return "Нельзя если не в отрубе" end
        if type == 2 then return "Нельзя если это не труп" end

        return type
    end,
    getTextEntry = function(group,groupSelect) return group.cantLoot[groupSelect.link] or 0 end,
    tip = "Напишите число от 0 до 2"
})

if SERVER then
    event.Add("Damage","Event Group",function(dmgTab)
        if not Event_Claimed then return end

        local ply = dmgTab.target
        if not ply:IsPlayer() then return end
        
        local att = dmgTab.att
        if not IsValid(att) or not att:IsPlayer() then return end

        local group = ply.eventGroup
        if not group then return end

        local attGroup = att.eventGroup
        if attGroup.cantDamage[group.link] then return false end
    end,-5)

    event.Add("Can Loot Player","Event Group",function(ply,ply2,ent)
        if not Event_Claimed then return end

        local group = ply.eventGroup
        if not group then return end

        local groupTarget = ply2.eventGroup
        if not groupTarget then return end
        
        local type = group.cantLoot[groupTarget.link]

        if type == 1 and not ply then return false end
        if type == 2 then return false end
    end)
end