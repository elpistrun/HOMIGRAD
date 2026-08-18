ARC9.SWEPPatches = {
    -- ["arc9_uplp_m249"] = {
    --     VisualRecoilPunch = 1
    -- },
}

ARC9.SWEPStatPatches = {
    -- ["VisualRecoilPunch"] = function(swep, orig)
    --     if swep.UseVisualRecoil != false and isnumber(swep.VisualRecoilPunchHipFire) and isnumber(swep.VisualRecoilPunch) and swep.VisualRecoilPunch > swep.VisualRecoilPunchHipFire * 4 then
    --         return math.min(swep.VisualRecoilPunchHipFire * 0.5, orig)
    --     end
    -- end
}

function ARC9.AddSWEPPatch(tabl)
    table.insert(ARC9.SWEPPatches, tabl)
end

function ARC9.PatchWeapons()
    local patchedgunlist = {}

    for _, wep in ipairs(weapons.GetList()) do
        local classname = wep.ClassName
        if weapons.IsBasedOn(classname, "arc9_base") then
            local origswep = weapons.GetStored(classname)
            
            for stat, func in pairs(ARC9.SWEPStatPatches) do
                local result = origswep[stat] and func(origswep, origswep[stat])
                if result then
                    origswep[stat] = result

                    -- print("[ARC9] Patched stats on " .. classname)
                    table.insert(patchedgunlist, classname)
                end
            end

            if ARC9.SWEPPatches[classname] then
                -- print("[ARC9] Patched " .. classname)
                table.insert(patchedgunlist, classname)

                for stat, value in pairs(ARC9.SWEPPatches[classname]) do
                    origswep[stat] = value
                end
            end
        end
    end

    if SERVER then if #patchedgunlist > 0 then print("[ARC9] Patched stats for " .. #patchedgunlist .. " weapons: " .. table.concat(patchedgunlist, ", ") .. ". If you are creator of them, please open `ARC9/lua/arc9/common/sh_patching` and see what has to be changed!") end end
end

-- ARC9.PatchWeapons()

hook.Add("InitPostEntity", "ARC9_PatchWeapons", ARC9.PatchWeapons)

