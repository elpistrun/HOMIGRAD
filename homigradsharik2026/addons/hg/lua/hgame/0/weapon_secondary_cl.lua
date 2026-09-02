function input.SelectSecondaryWeapon(wep)
    if LocalPlayer():SelectSecondaryWeapon(wep) then
        net.Start("weapon_secondary")
        net.WriteInt(IsValid(wep) and wep:EntIndex() or -1,14)
        net.SendToServer()
    end
end

net.Receive("weapon_secondary",function()
    local result = net.ReadBool()
    
    if not result then
        print("net error: secondary weapon - " .. net.ReadString())

        local ent = LocalPlayer():GetPVSVar("WeaponSecondary")

        LocalPlayer():SetActiveSecondaryWeapon(ent and Entity(ent))
    end
end)