local FrameNumber = FrameNumber

hook.Add("PrePlayerDraw", "ARC9_TPIK", function(ply, flags)
    -- each entity bonemerged to player call this hook
    
    -- flags = 0 for that ent
    -- flags = 1 for player
    -- flags = 134217729 for depth buffer

    -- with this code we always call tpik for players but only once per frame if called by a bonemerged entity
    
    if ply then
        local tick = FrameNumber()
        if ply.ARC9LastTPIKTick != tick or flags != 0 then
            ply.ARC9LastTPIKTick = tick

            local wpn = ply:GetActiveWeapon()
            if wpn.ARC9 then
                wpn:DoTPIK(flags == 134217729)
            end
        end
    end
end)