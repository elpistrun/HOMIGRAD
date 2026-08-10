local function Think(ply)
    if not ply:Alive() then return end
    
    local activeWep = ply:GetActiveWeapon()
    if not IsValid(activeWep) then activeWep = nil end

    if activeWep and activeWep.IsSecondaryWeapon then
        if SERVER then ply:SetActiveWeapon() activeWep = nil end
    end
    
    local wantWep = ply.wantWeaponPrimary

    if not IsValid(wantWep) or not table.HasValue(ply:GetWeapons(),wantWep) then
        wantWep = nil
    end

    if IsValid(wantWep) and wantWep.IsSecondaryWeapon then
        wantWep = nil
    end

    ply.wantWeaponPrimary = wantWep

    if not wantWep then return end

    --print(activeWep.stateHandling)

    if wantWep != activeWep then
        if IsValid(activeWep) and activeWep.Holster then
            local result = activeWep:Holster(true)
            if not result then return end
        end

        if SERVER then
            ply:SetActiveWeapon(wantWep)
        else
            if IsValid(wantWep) then input.SelectWeapon(wantWep) end
        end

        if IsValid(wantWep) and wantWep.Deploy then
            ply.wantWeaponPrimary = nil
            
            wantWep:Deploy(true)
        end
    end
end

if CLIENT then
    event.Add("Think","WeaponPrimary",function()
        Think(LocalPlayer())
    end)

    net.Receive("input.SelectWeapon",function()
        coroutine.wrap(function()
            local wep = EntityCoroutine(net.ReadInt(13))
            if not IsValid(wep) then return end

            input.SelectWeapon(wep)
        end)()
    end)
else
    util.AddNetworkString("input.SelectWeapon")

    event.Add("Player Think","WeaponPrimary",Think)

    local PLAYER = FindMetaTable("Player")
    if not HSelectWeapon then HSelectWeapon = PLAYER.SelectWeapon end

    function PLAYER:SelectWeapon(className)
        local wep = self:GetWeapon(className)
        if not IsValid(wep) then return end

        net.Start("input.SelectWeapon")
        net.WriteInt(wep:EntIndex(),13)
        net.Send(self)
    end

    player.UpdateWeaponsList = function(ply)
        local list = {}
        
        for i,wep in pairs(ply:GetWeapons()) do
            list[#list+1] = wep:EntIndex()
        end

        ply:SetNWTable("WeaponEntIndexList",list)
    end

    event.Add("PlayerPickupItem","UpdateWeaponsList",function(ply)
        player.UpdateWeaponsList(ply)
    end,1000)

    event.Add("PlayerDroppedWeapon","UpdateWeaponsList",function(ply)
        player.UpdateWeaponsList(ply)
    end,1000)

    event.Add("Player Think 1","Weapons",function(ply)
        player.UpdateWeaponsList(ply)
    end)
end

event.Add("PlayerSwitchWeapon","WeaponCanFunction",function(ply,old,new)
    if IsValid(new) and new.CanSwitch then
        local result = new:CanSwitch(ply,old)
        if result == false then return false end
    end
end,10)

hook.Add("PlayerSwitchWeapon","Homigrad",function(ply,old,new,type)
    if BYPASSWEP then return true end

    local result = event.Call("PlayerSwitchWeapon",ply,old,new,type)
    if result == nil then result = true end

    if result then ply.wantWeaponPrimary = new end

    return not result
end)
