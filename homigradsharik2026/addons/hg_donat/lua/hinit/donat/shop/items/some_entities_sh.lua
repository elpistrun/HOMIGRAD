DonatItemsList.sent_she_fire = {ent = "sent_she_fire",raryType = "common",limitSpawn = 1}
DonatItemsList.sent_she_sleep = {ent = "sent_she_sleep",raryType = "common",cantSpawn = true}
DonatItemsList.sent_she_target = {ent = "sent_she_target",raryType = "common",limitSpawn = 1}

DonatItemsList.sent_she_petdog = {ent = "sent_she_petdog",raryType = "legendary",limitSpawn = 1}
DonatItemsList.sent_she_mogeko = {ent = "sent_she_mogeko",raryType = "legendary",notInv = true,cantSpawn = true}

DonatItemsList.sent_she_potion = {ent = "sent_she_potion",raryType = "rary",limitSpawn = 1}

DonatItemsList.sent_she_garden = {ent = "sent_she_garden",raryType = "rary",cantSpawn = true}

DonatItemsList.sent_she_tray = {ent = "sent_she_tray",raryType = "rary",cantSpawn = true}
DonatItemsList.sent_she_tick = {ent = "sent_she_tick",raryType = "rary",limitSpawn = 1,notInv = true,spawnFunction = function(ply,ent)
    ent:GetPhysicsObject():EnableMotion(false)
    ent:SetAngles(Angle(0,ply:EyeAngles()[2],0))

    local tr = {
        start = ply:EyePos(),
        endpos = ply:EyePos() + Vector(100,0,0):Rotate(ply:EyeAngles()),
        filter = ply
    }

    tr = util.TraceLine(tr)
    ent:SetPos(tr.HitPos)
end}

DonatItemsList.sent_she_bush = {ent = "sent_she_bush",raryType = "rary",limitSpawn = 1,notInv = true}
DonatItemsList.sent_she_manhole = {ent = "sent_she_manhole",raryType = "rary",limitSpawn = 1,cantSpawn = true}
DonatItemsList.npc_pig = {ent = "npc_pig",raryType = "rary",notInv = true,limitSpawn = 3}

DonatItemsList.sent_she_cirno = {ent = "sent_she_cirno",raryType = "legendary",limitSpawn = 1}

DonatItemsList.sent_she_stove = {ent = "sent_she_stove",raryType = "legendary",limitSpawn = 1}