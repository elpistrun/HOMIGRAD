local PLAYER = FindMetaTable("Player")

function PLAYER:GetActiveSecondaryWeapon()
    local entIndex = self.secondaryWeaponEntIndex or self:GetPVSVar("WeaponSecondary")
    if not entIndex then return end

    return Entity(entIndex)
end

function PLAYER:SetActiveSecondaryWeapon(wep)
    local entIndex = IsValid(wep) and wep:EntIndex()

    self.secondaryWeaponEntIndex = entIndex

    return self:SetPVSVar("WeaponSecondary",entIndex)
end

local PLAYER = FindMetaTable("Player")

function PLAYER:SelectSecondaryWeapon(nextWep)
    if not IsValid(nextWep) or not nextWep.SupportSecondarSlot then nextWep = nil end

    local wep = self:GetActiveWeapon()
    if IsValid(wep) and IsValid(nextWep) and wep.BlockSecondaryWeapon then self:UserMessage("Нельзя взять это, смените основное оружие.",USERMSG_ERROR) nextWep = nil end

    local oldWep = self:GetActiveSecondaryWeapon()
    if oldWep == nextWep then return end
    
    if IsValid(oldWep) then oldWep:Holster(nextWep) end

    local result = hook.Run("PlayerSwitchWeapon",self,oldWep,nextWep,"secondary")
    if result == true then return end

    self.wantWeaponSecondary = nextWep

    return true
end

local function Think(ply)
    if not ply:Alive() then return end
    
    local activeWep = ply:GetActiveSecondaryWeapon()
    if not IsValid(activeWep) then activeWep = nil end

    if activeWep and (not activeWep.IsSecondaryWeapon or activeWep:GetOwner() != ply) then
        ply:SetActiveSecondaryWeapon()
        activeWep = nil
    end
    
    local wantWep = ply.wantWeaponSecondary

    if not IsValid(wantWep) or not table.HasValue(ply:GetWeapons(),wantWep) or not wantWep.IsSecondaryWeapon then
        wantWep = nil
    end

    ply.wantWeaponSecondary = wantWep
    
    if wantWep != activeWep then
        if activeWep and activeWep.Holster then
            local result = activeWep:Holster(true)
            if not result then return end
        end

        ply:SetActiveSecondaryWeapon(wantWep)

        if wantWep and wantWep.Deploy then
            wantWep:Deploy(true)
        end
    end
end

if CLIENT then
    event.Add("Think","WeaponSecondary",function()
        Think(LocalPlayer())
    end)
else
    event.Add("Player Think","WeaponSecondary",Think)
end

event.Add("PlayerSwitchWeapon","Block By Secondary Weapon",function(ply,old,new,type)
    if type != "secondary" and IsValid(new) and new.SupportSecondarSlot then return false end--engine shit
    
    if IsValid(new) and new.BlockSecondaryWeapon and IsValid(ply:GetActiveSecondaryWeapon()) then
        if SERVER then ply:UserMessage("Нельзя брать это оружие, смените основное оружие.",USERMSG_ERROR) end--ebani cring, сказано же на клиенте что нельзя нах он отправляет это сюды

        return false
    end
end)
