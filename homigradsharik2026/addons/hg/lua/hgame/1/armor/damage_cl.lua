local Rand,random = math.Rand,math.random

net.Receive("dmgarmor_head",function()
    local pos = net.ReadVector()
    local dir = net.ReadVector()
    local ent = net.ReadInt(13)

    ent = Entity(ent)

    if ent == GetViewEntity() then
        for i = 1,2 do sound.Emit(ent,"eft/impact/helmet" .. math.random(1,4) .. "_me.wav",75,1,100,pos) end
    else
        sound.Emit(ent,"eft/impact/helmet" .. math.random(1,4) .. "_other.wav",70,1,75,pos)
    end

    if not IsValid(ent) then return end

    --sound.Emit(ent,"snd_jack_hmcd_ricochet_1.wav",65,0.5,125,pos)

    local dlight = DynamicLight(ent:EntIndex())
    dlight.pos = pos
    dlight.r = random(245,255)
    dlight.g = random(245,255)
    dlight.b = random(75,125)
    dlight.brightness = 10
    dlight.Decay = 1000
    dlight.Size = Rand(60,75)
    dlight.DieTime = CurTime() + 0.1

    local eff = EffectData()
    eff:SetOrigin(pos)
    eff:SetNormal(-dir)
    eff:SetRadius(0.1)
    eff:SetMagnitude(0.25)
    eff:SetScale(0.25)

    util.Effect("Sparks",eff)
    util.Effect("MetalSpark",eff)
end)

net.Receive("dmgarmor_rich",function()
    local pos = net.ReadVector()
    local dir = net.ReadVector()
    local ent = net.ReadInt(13)

    ent = Entity(ent)

    sound.Emit(ent,"weapons/ricochet/strong_" .. math.random(1,2) .. ".wav",70,0.5,125,pos)

    if not IsValid(ent) then return end

    local dlight = DynamicLight(ent:EntIndex())
    dlight.pos = pos
    dlight.r = random(245,255)
    dlight.g = random(245,255)
    dlight.b = random(75,125)
    dlight.brightness = 10
    dlight.Decay = 1000
    dlight.Size = Rand(60,75)
    dlight.DieTime = CurTime() + 0.1

    local eff = EffectData()
    eff:SetOrigin(pos)
    eff:SetNormal(-dir)
    eff:SetRadius(0.1)
    eff:SetMagnitude(0.25)
    eff:SetScale(0.25)

    util.Effect("Sparks",eff)
    util.Effect("MetalSpark",eff)
end)

net.Receive("dmgarmor_kevlar",function()
    local pos = net.ReadVector()
    local dir = net.ReadVector()
    local ent = net.ReadInt(13)

    ent = Entity(ent)

    if ent == GetViewEntity() then
        for i = 1,2 do sound.Emit(ent,"eft/impact/bodyarmor" .. math.random(1,4) .. "_me.wav",75,1,100,pos) end
    else
        sound.Emit(ent,"eft/impact/bodyarmor" .. math.random(1,4) .. "_other.wav",75,1,100,pos)
    end

    if not IsValid(ent) then return end

    for i = 1,2 do
        local eff = EffectData()
        eff:SetOrigin(pos)
        eff:SetNormal(-dir)

        util.Effect("GlassImpact",eff)
    end
end)