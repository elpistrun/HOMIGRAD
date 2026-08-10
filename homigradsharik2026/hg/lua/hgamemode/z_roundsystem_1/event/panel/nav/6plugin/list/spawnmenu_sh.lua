local Plugin = EventPlugin_Reg("spawnmenu","base")
if not Plugin then return end

Plugin.PrintName = "Spawnmenu"

Plugin.EventPlug = {
    ["Can Use Spawn"] = "CanUseSpawn",
}

Plugin.HookPlug = {
    ["PhysgunPickup"] = "PhysgunPickup",
    ["OnPhysgunReload"] = "OnPhysgunReload"
}

function Plugin:PhysgunPickup(ply,ent)
    if Event_CanAccess(ply) then return end
    
    if ent:GetNWString("OwnerSteamID") != ply:SteamID() then return false end
end

function Plugin:Sync(data)
    if SERVER then
        data.prop_max_scale = self.prop_max_scale
    else
        self.prop_max_scale = data.prop_max_scale
    end
end

if SERVER then
    Plugin.EventPlug["Spawn Object"] = "SpawnObject"

    function Plugin:SpawnObject(ply,type,ent)
        if ent:OBBMins():Length() + ent:OBBMaxs():Length() > (self.prop_max_scale or 0) then
            ent:Remove()

            ply:SendNotify("Слишком большой объект.",NOTIFY_ERROR,5)

            return
        end

        ent:SetNWString("OwnerSteamID",ply:SteamID())
    end

    function Plugin:OnPhysgunReload(wep,ply)
        if not Event_CanAccess(ply) then return false end
    end

    function Plugin:CanUseSpawn(ply,type,model,tr)
        if not ply:Alive() or Event_CanAccess(ply) then return end//lol
        if type == "tool" and tr.Entity:GetNWString("OwnerSteamID") != ply:SteamID() then return false end

        if type != "prop" and type != "tool" then ply:SendNotify("Запрещено.",NOTIFY_ERROR,5) return false end
        if (ply.pluginSpawnmenu_delay or 0) > RealTime() then ply:SendNotify("Подождите секунду.",NOTIFY_ERROR,5) return false end
        if type == "prop" and ExplosiveModel[model] then ply:SendNotify("Запрещено.",NOTIFY_ERROR,5) return false end

        ply.pluginSpawnmenu_delay = RealTime() + 1
    
        return true
    end

    Plugin:AddCMD("prop_max_scale",function(self,ply,args)
        self.prop_max_scale = tonumber(args[1] or 0) or 0

        return true,tostring(self.prop_max_scale)
    end)

else
    function Plugin:CanUseSpawn(ply,type)
        if ply:Alive() then return true end
    end

    function Plugin:Create(page)
        page:AddEdit("prop_max_scale")
    end
end