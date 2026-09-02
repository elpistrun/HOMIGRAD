adminPanel.successRegistry("spawnmenu_access",nil,"rights")
adminPanel.successRegistry("spawnmenu_superadmin",nil,"rights")

hook.Add("SpawnMenuOpen","hide_spawnmenu",function()
    return event.Call("Can Use Spawn",LocalPlayer())
end)

hook.Add("ContextMenuOpen","hide_spawnmenu",function()
    return event.Call("Can Properties",LocalPlayer())
end)

event.Add("Can Use Spawn","Admin",function(ply)
    return ply:HasSuccess("spawnmenu_access")
end,10)

event.Add("Can Properties","Admin",function(ply)
    return ply:HasSuccess("spawnmenu_access")
end,10)

hook.Add("OnPhysgunFreeze","ent",function(_,_,ent,ply)
    ent.hold = nil

    if ent.CanPhysgunFreeze then return ent:CanPhysgunFreeze(ply) end
end)

hook.Add("PhysgunPickup","ent",function(ply,ent)
    ent.hold = ply

    if ent.CanPhysgun then return ent:CanPhysgun(ply) end
end)

hook.Add("PhysgunDrop","ent",function(ply,ent)
    ent.hold = nil

    if ent.CanPhysgunDrop then return ent:CanPhysgunDrop(ply) end
end)

hook.Add("PlayerCheckLimit","FUCK YOU",function() return true end)

properties.Add("ignite",{
	MenuLabel = "#ignite",
	Order = 999,
	MenuIcon = "icon16/fire.png",
	Filter = function(self,ent,ply)
		return ply:HasSuccess("spawnmenu_access") and not ent:IsOnFire() 
	end,
	Action = function(self,ent)
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function(self,length,ply)
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted(ent,ply) then return end
		if !self:Filter( ent,ply) then return end

		ent:Ignite(360)
	end 
})

ExplosiveModel = {
    ["models/props_c17/oildrum001_explosive.mdl"] = true,
    ["models/props_junk/gascan001a.mdl"] = true,
    ["models/props_junk/propane_tank001a.mdl"] = true,

    ["models/props_phx/torpedo.mdl"] = true,
    ["models/props_phx/mk-82.mdl"] = true,
    ["models/props_phx/ww2bomb.mdl"] = true,
    ["models/props_phx/oildrum001_explosive.mdl"] = true,
    ["models/props_phx/ball.mdl"] = true,
    ["models/props_phx/amraam.mdl"] = true,
    ["models/props_c17/canister02a.mdl"] = true,
    ["models/props_junk/metalgascan.mdl"] = true,
    ["models/props_c17/canister01a.mdl"] = true,

    ["models/props_junk/propanecanister001a.mdl"] = true,
    ["models/props_junk/PropaneCanister001a.mdl"] = true,
    
    ["models/tadano/fumo/pack/flandere.mdl"] = true,
    ["models/tadano/fumo/pack/cirno.mdl"] = true,
    ["models/tadano/fumo/pack/inu.mdl"] = true,
    ["models/tadano/fumo/pack/reimu.mdl"] = true,
    ["models/tadano/fumo/pack/yuuka.mdl"] = true,
    ["models/tadano/fumo/pack/yuyu.mdl"] = true,
    ["models/tadano/fumo/pack/remilia.mdl"] = true
}

if SERVER then
    local function CanSpawn(ply)
        return IsValid(ply) and ply:HasSuccess("spawnmenu_access") or false
    end

    local function GetSpawnPos(ply)
        return ply:EyePos() + ply:GetAimVector() * 80
    end

    concommand.Add("gm_giveswep",function(ply,_,args)
        if not CanSpawn(ply) then return end

        local class = args[1]
        if not class or class == "" then return end

        if not weapons.Get(class) then return end

        ply:Give(class)
    end)

    concommand.Add("gm_spawnswep",function(ply,_,args)
        if not CanSpawn(ply) then return end

        local class = args[1]
        if not class or class == "" then return end

        if not weapons.Get(class) then return end

        local ent = ents.Create(class)
        if not IsValid(ent) then return end

        ent:SetPos(GetSpawnPos(ply))
        ent:Spawn()
        ent:Activate()

        local physics = ent:GetPhysicsObject()
        if IsValid(physics) then physics:Wake() end
    end)

    concommand.Add("gm_spawnsent",function(ply,_,args)
        if not CanSpawn(ply) then return end

        local class = args[1]
        if not class or class == "" then return end

        local ent = ents.Create(class)
        if not IsValid(ent) then return end

        ent:SetPos(GetSpawnPos(ply))
        ent:Spawn()
        ent:Activate()

        local physics = ent:GetPhysicsObject()
        if IsValid(physics) then physics:Wake() end
    end)

    concommand.Add("gm_spawnvehicle",function(ply,_,args)
        if not CanSpawn(ply) then return end

        local class = args[1]
        if not class or class == "" then return end

        local ent = ents.Create(class)
        if not IsValid(ent) then return end

        ent:SetPos(GetSpawnPos(ply))
        ent:Spawn()
        ent:Activate()
    end)

    concommand.Add("gm_spawnnpc",function(ply,_,args)
        if not CanSpawn(ply) then return end

        local class = args[1]
        if not class or class == "" then return end

        local ent = ents.Create(class)
        if not IsValid(ent) then return end

        ent:SetPos(GetSpawnPos(ply))
        ent:Spawn()
        ent:Activate()

        local weapon = args[2]
        if weapon and weapon != "" then ent:Give(weapon) end
    end)

    concommand.Add("hg_spawn",function(ply,_,args)
        if not CanSpawn(ply) then return end

        local entClass = args[1]
        local dataName = args[2]
        if not entClass or entClass == "" then return end

        local ent = ents.Create(entClass)
        if not IsValid(ent) then return end

        ent:SetPos(GetSpawnPos(ply))
        ent:Spawn()

        if dataName and dataName != "" then
            if ent.SetAmmoName then ent:SetAmmoName(dataName) end
            if ent.SetAttachmentName then ent:SetAttachmentName(dataName) end
        end

        ent:Activate()

        local physics = ent:GetPhysicsObject()
        if IsValid(physics) then physics:Wake() end
    end)
end
