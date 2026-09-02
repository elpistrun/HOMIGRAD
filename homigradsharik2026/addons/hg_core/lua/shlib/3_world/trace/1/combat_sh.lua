function hitBoxGame.CreateTraceTable()
    local tr = {}

    local filterTrace = {}
    tr.filterTrace = filterTrace
    
    tr.mask = MASK_SHOT
    tr.filter = function(ent)
        if SERVER then
            if ent:IsLagCompresion() then return false end
        else
            if util.IsHumanoid(ent) then return false end
        end
        
        return not filterTrace[ent] and true or false
    end

    local output = {}
    
    tr.output = output

    function tr.ClearFilterTrace()
        for key in pairs(filterTrace) do filterTrace[key] = nil end
    end

    function tr.ClearOutput()
        output.HitBone = nil
        output.HitBox = nil
        output.HitBoxPos = nil
        output.HitBoxAng = nil
    end

    return tr
end