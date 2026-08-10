function hitBoxGame.LagTraceLine(tr,lagCompresionTick,isDebug,entsList)
    if tr.ClearOutput then tr.ClearOutput() end

    local result = util.TraceLine(tr)

    result.start = result.StartPos
    result.endpos = result.HitPos

    if isDebug then debugoverlayNet.Sphere(result.StartPos,2,10,Color(255,125,0,125)) end

    local filterTrace = tr.filterTrace
    
    local hitEntity = result.Entity

    if not IsValid(hitEntity) then
        entsList = entsList or ents.FindInSphere(tr.start,tr.start:Distance(tr.endpos))

        for i = 1,#entsList do
            local ent = entsList[i]

            if ent.GetEntity then ent = ent:GetDummy() end

            if not util.IsHumanoid(ent) or filterTrace[ent] or (ent:IsPlayer() and not ent:Alive()) then continue end

            if hitBoxGame.TraceLine(ent,hitBoxGame.GetInfo(ent),nil,result,isDebug) then return result end
        end
    else
        if util.IsHumanoid(hitEntity) then hitBoxGame.TraceHull(hitEntity,hitBoxGame.GetInfo(hitEntity),nil,result,isDebug) end
    end

    return result
end

function hitBoxGame.LagTraceHull(tr,lagCompresionTick,isDebug,entsList)
    if tr.ClearOutput then tr.ClearOutput() end
    
    local result = util.TraceHull(tr)

    local start,dir = result.StartPos,result.HitPos - result.StartPos

    result.start = result.StartPos
    result.endpos = result.HitPos
    result.mins = tr.mins
    result.maxs = tr.maxs + Vector(dir:Length(),0,0)

    if isDebug then debugoverlayNet.BoxAngles(result.StartPos,tr.mins,tr.maxs + Vector(result.StartPos:Distance(result.HitPos),0,0),result.Normal:Angle(),3,Color(255,125,0,125)) end

    local filterTrace = tr.filterTrace
    
    local hitEntity = result.Entity

    if not IsValid(hitEntity) then
        entsList = entsList or ents.FindInSphere(tr.start,tr.start:Distance(tr.endpos))

        for i = 1,#entsList do
            local ent = entsList[i]

            if ent.GetEntity then ent = ent:GetDummy() end

            if not util.IsHumanoid(ent) or filterTrace[ent] or (ent:IsPlayer() and not ent:Alive()) then continue end

            if hitBoxGame.TraceHull(ent,hitBoxGame.GetInfo(ent),nil,result,isDebug) then return result end
        end
    else
        if util.IsHumanoid(hitEntity) then hitBoxGame.TraceHull(hitEntity,hitBoxGame.GetInfo(hitEntity),nil,result,isDebug) end
    end
    
    return result
end