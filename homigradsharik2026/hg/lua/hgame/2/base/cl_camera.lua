local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

event.Add("PreCalcView","Weapon Camera",function(ply,view)
    local wep = ply:GetActiveWeapon()

    if IsValid(wep) and wep.PreCalcView then
        return wep:PreCalcView(ply,view)
    end
end)