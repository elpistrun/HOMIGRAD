util.AddNetworkString("weapon_secondary")

net.Receive("weapon_secondary",function(len,ply)
    local entIndex = net.ReadInt(14)
    
    local wep = entIndex > 0 and Entity(entIndex) or nil
    if wep and not IsValid(wep) then wep = nil end
    
    -- Verify the weapon is valid for secondary slot
    local success = true
    local errMsg = ""
    
    if wep then
        if not IsValid(wep) or not wep:IsWeapon() then
            success = false
            errMsg = "invalid entity"
        end
    end
    
    if success then
        ply:SetPVSVar("WeaponSecondary", wep and wep:EntIndex() or nil)
        ply:SetActiveSecondaryWeapon(wep)
    end
    
    net.Start("weapon_secondary")
    net.WriteBool(success)
    if not success then net.WriteString(errMsg) end
    net.Send(ply)
end)
