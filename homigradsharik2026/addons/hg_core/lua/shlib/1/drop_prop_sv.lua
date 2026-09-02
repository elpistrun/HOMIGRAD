function DropProp(model,scale,pos,ang,vel,angvel)
    if not model or not util.IsValidModel(model) then return end

    local prop = ents.Create("prop_physics")
    if not IsValid(prop) then return end

    prop:SetModel(model)
    prop:SetPos(pos or vector_origin)
    prop:SetAngles(ang or angle_zero)
    prop:SetModelScale(scale or 1)
    prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    prop:Spawn()
    prop:Activate()

    local phys = prop:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(vel or vector_origin)
        phys:AddAngleVelocity(angvel or vector_origin)
        phys:Wake()
    end

    SafeRemoveEntityDelayed(prop,30)

    return prop
end
