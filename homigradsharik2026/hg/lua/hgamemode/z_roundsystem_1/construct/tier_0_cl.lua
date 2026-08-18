if not CLIENT then return end

-- Construct mode client: show build hints, hide combat HUD elements

hook.Add("HUDPaint", "HG Construct HUD", function()
    if roundActiveName ~= "construct" and roundActiveName ~= "level_construct" then return end

    local lply = LocalPlayer()
    if not IsValid(lply) then return end

    -- Show tool hint at bottom
    local wep = lply:GetActiveWeapon()
    if IsValid(wep) then
        local wepClass = wep:GetClass()
        local hint = ""
        if wepClass == "weapon_physgun" then
            hint = L("construct_hint_physgun")
        elseif wepClass == "gmod_tool" then
            hint = L("construct_hint_tool")
        end

        if hint ~= "" then
            draw.SimpleText(hint, "DermaDefault", ScrW() / 2, ScrH() - 50, Color(255, 255, 255, 180), TEXT_ALIGN_CENTER)
        end
    end
end)
