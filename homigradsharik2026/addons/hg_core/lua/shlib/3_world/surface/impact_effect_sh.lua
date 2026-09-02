local alpha = 64
local white = Color(255,255,255,alpha)
local dieTieMul = 2


local Index_Registry = function(name,manual) surfaceWorld.Index_Registry(name,"effect","bullet",manual) end

local Get = function(name) local mat = Material(name) return mat end

local manual_wood = {
    Get("particles/wood1"),
    Get("particles/wood2"),
    Get("particles/wood3")
}

local manual_glass = {
    Get("particles/glass1"),
    Get("particles/glass2"),
    Get("particles/glass3"),
    Get("particles/glass4"),
}

local manual_cocrete = {
    Get("particles/concrete1"),
    Get("particles/concrete2"),
    Get("particles/concrete3")
}

-- Base

Index_Registry("default",{})
Index_Registry("glass",{particles = {size = 6,list = manual_glass}})
Index_Registry("computer",{particles = {size = 2,list = manual_glass}})


-- Concrete

Index_Registry("concrete",{particles = {size = 2,list = manual_cocrete}})
Index_Registry("concrete_block",{particles = {size = 2,list = manual_cocrete}})
Index_Registry("tile",{particles = {size = 2,list = manual_cocrete}})
Index_Registry("brick",{particles = {size = 2,list = manual_cocrete}})
Index_Registry("stone",{particles = {size = 2,list = manual_cocrete}})
Index_Registry("rock",{particles = {size = 2,list = manual_cocrete}})
Index_Registry("porcelain",{particles = {size = 2,list = manual_cocrete}})
Index_Registry("boulder",{particles = {size = 2,list = manual_cocrete}})

--Metal

--Sand

Index_Registry("grass",{smoke = {color = Color(75,63,39,alpha)}})
Index_Registry("dirt",{smoke = {color = Color(75,63,39,alpha)}})

--Wood

Index_Registry("wood",{particles = {size = 2,list = manual_wood}})
Index_Registry("wood_box",{particles = {size = 2,list = manual_wood}})
Index_Registry("wood_crate",{particles = {size = 2,list = manual_wood}})
Index_Registry("wood_plank",{particles = {size = 2,list = manual_wood}})
Index_Registry("wood_solid",{particles = {size = 2,list = manual_wood}})
Index_Registry("wood_furniture",{particles = {size = 2,list = manual_wood}})
Index_Registry("wood_panel",{particles = {size = 2,list = manual_wood}})

-- Flesh
    
-- Plastic

-- Clotch

local Rand,random = math.Rand,math.random

function surfaceWorld.CreateEffectBulletFlesh(pos,normal,ent,surfaceName,mul,withoutSmoke)
    if hg_dev_dontparticles then return end

    local r = random(2,3)
    local emitter = ParticleEmitter(pos)

    local dirAngle = normal:Angle()

    local unlitGeneric = gibParticles.bloodDrop.unlitGeneric

    for i = 1,r do
        local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
        if not part then continue end

        part:SetColor(125,0,0)
        part:SetDieTime(Rand(0.5,1) * dieTieMul)

        part:SetStartAlpha(random(95,125)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(2,4)) part:SetEndSize(Rand(5,7) * mul)

        part:SetGravity(ParticleGravity)
        part:SetCollide(true)

        local dir = normal:Clone():Mul(-75 * Rand(0.25,1) * mul)
        dir:Add(dirAngle:Right() * Rand(-1,1) * 45)
        dir:Add(dirAngle:Up() * Rand(-0.5,0.5) * 75)

        part:SetStartLength(12 * mul)--wooooooow
        part:SetEndLength(0)

        part:SetRoll(Rand(-360,360))
        part:SetVelocity(dir) part:SetAirResistance(55)
        part:SetPos(pos)
    end

    r = random(1,2)

    for i = 1,r do
        local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
        if not part then continue end

        part:SetColor(125,0,0)
        part:SetDieTime(Rand(0.5,1) * dieTieMul)

        part:SetStartAlpha(random(95,125)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(2,4)) part:SetEndSize(Rand(15,25) * mul)

        part:SetGravity(ParticleGravity)
        part:SetCollide(true)

        local dir = normal:Clone():Mul(-125 * Rand(0.25,1) * mul)
        dir:Add(dirAngle:Right() * Rand(-1,1) * 25)
        dir:Add(dirAngle:Up() * Rand(-0.5,0.5) * 125)

        part:SetRoll(Rand(-360,360))
        part:SetVelocity(dir) part:SetAirResistance(125)
        part:SetPos(pos)
    end
    
    --

    r = random(1,2)

    for i = 1,r do
        local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
        if not part then continue end

        part:SetColor(125,0,0)
        part:SetDieTime(Rand(0.5,1) * dieTieMul)

        part:SetStartAlpha(random(95,125)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(2,4)) part:SetEndSize(Rand(15,25) * mul)

        part:SetGravity(ParticleGravity)
        part:SetCollide(true)

        local dir = normal:Clone():Mul(512 * Rand(0.75,1.25) * mul)
        dir:Add(dirAngle:Right() * Rand(-1,1) * 25)
        dir:Add(dirAngle:Up() * Rand(-0.5,0.5) * 125)

        part:SetStartLength(25 * mul)
        part:SetEndLength(0)

        part:SetRoll(Rand(-360,360))
        part:SetVelocity(dir) part:SetAirResistance(125)
        part:SetPos(pos)
    end

    r = random(1,2)

    for i = 1,r do
        local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
        if not part then continue end

        part:SetColor(125,0,0)
        part:SetDieTime(Rand(0.5,1) * dieTieMul)

        part:SetStartAlpha(random(95,125)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(2,4)) part:SetEndSize(Rand(15,25) * mul)

        part:SetGravity(ParticleGravity)
        part:SetCollide(true)

        local dir = normal:Clone():Mul(512 * Rand(0.25,0.5) * mul)
        dir:Add(dirAngle:Right() * Rand(-1,1) * 25)
        dir:Add(dirAngle:Up() * Rand(-0.5,0.5) * 125)

        part:SetStartLength(15 * mul)
        part:SetEndLength(0)

        part:SetRoll(Rand(-360,360))
        part:SetVelocity(dir) part:SetAirResistance(125)
        part:SetPos(pos)
    end

    r = random(1,2)

    for i = 1,r do
        local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos)
        if not part then continue end

        part:SetDieTime(Rand(0.5,1) * dieTieMul)

        part:SetStartAlpha(random(75,125)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(2,4)) part:SetEndSize(Rand(25,35) * mul)

        part:SetGravity(ParticleGravity)
        part:SetCollide(true)
        part:SetColor(75,0,0)

        local dir = normal:Clone():Mul(512 * Rand(0.25,1) * mul)
        dir:Add(dirAngle:Right() * Rand(-1,1) * 25)
        dir:Add(dirAngle:Up() * Rand(-0.5,-0.25) * 25)

        part:SetRoll(Rand(-360,360))
        part:SetVelocity(dir) part:SetAirResistance(1024)
        part:SetPos(pos)
    end

    emitter:Finish()
end

local Fast = surfaceWorld.Fast.effect.bullet

function surfaceWorld.CreateEffectBullet(pos,normal,ent,surfaceName,mul,withoutSmoke)
    if hg_dev_dontparticles then return end

    mul = mul or 1
    
    if surfaceWorld.TypeIndex[surfaceName] == "flesh" then
        surfaceWorld.CreateEffectBulletFlesh(pos,normal,ent,surfaceName,mul,withoutSmoke)
        return
    end

    local surfaceData = Fast[surfaceName] or Fast.default

    local emitter = ParticleEmitter(pos)
    local color = surfaceData.color or white
    local ang = Angle(Rand(-1,1),Rand(-1,1),0)

    for i = 1,random(2,3) do
        local length = Rand(175,200) * mul

        local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos - (normal * (length / 2)):Rotate(ang))
        if not part then continue end

        part:SetColor(color.r,color.g,color.b)
        part:SetLighting(true)
        part:SetDieTime(Rand(0.5,0.9) * dieTieMul)

        part:SetStartAlpha(color.a)
        part:SetEndAlpha(0)

        part:SetStartSize(Rand(1,2))
        part:SetEndSize(Rand(75,125) * mul)

        part:SetStartLength(length)
        part:SetEndLength(length)

        ang[1] = ang[1] + Rand(-2,2)
        ang[2] = ang[2] + Rand(-2,2)
        part:SetVelocity(normal)
    end

    if not withoutSmoke then
        for i = 1,random(3,4) do
            local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos + (normal * math.Rand(3,6)):Rotate(ang))
            if not part then continue end

            part:SetColor(color.r,color.g,color.b)
            part:SetLighting(true)
            part:SetDieTime(Rand(5,6) * dieTieMul)

            part:SetStartAlpha(color.a - Rand(-5,5))
            part:SetEndAlpha(0)

            part:SetStartSize(Rand(10,12))
            part:SetEndSize(Rand(100,150) * mul)

            part:SetGravity(Vector(0,0,-25))

            ang[1] = ang[1] + Rand(-6,6) * (1 / math.min(mul * 7,1))
            ang[2] = ang[2] + Rand(-6,6) * (1 / math.min(mul * 7,1))
            part:SetVelocity((normal * (Rand(75,200) * Rand(0.9,1.1))):Rotate(ang))
            part:SetAirResistance(Rand(90,120))
            part:SetRollDelta(Rand(0.1,0.5) * math.randAbs())
        end
    end

    local info = surfaceData.particles

    if info then
        for i = 1,random(3,4) do
            local part = emitter:Add(info.list[random(1,#info.list)],pos + (normal * math.Rand(3,6)):Rotate(ang))
            if not part then continue end

            part:SetColor(255,255,255)
            part:SetLighting(true)
            part:SetDieTime(Rand(2,3) * dieTieMul)

            part:SetStartAlpha(255)
            part:SetEndAlpha(0)

            local size = info.size + info.size * Rand(-0.1,0.1) * mul
            part:SetStartSize(size)
            part:SetEndSize(size)

            part:SetGravity(Vector(0,0,-1000))

            ang[1] = ang[1] + Rand(-25,25)
            ang[2] = ang[2] + Rand(-25,25)
            part:SetVelocity((normal * (Rand(125,200) * Rand(0.9,1.1))):Rotate(ang))
            part:SetAirResistance(Rand(90,120))
            part:SetBounce(0.25)

            part:SetRollDelta(Rand(-6,6))
            part:SetCollide(true)
        end
    end

    emitter:Finish()
end

if SERVER then
    util.AddNetworkString("surfaceWorld_effectBullet")

    function surfaceWorld.CreateEffectBullet_Net(pos,normal,ent,surfaceName,mul,withoutSmoke)
        net.Start("surfaceWorld_effectBullet",true)
        net.WriteVector(pos)
        net.WriteVector(normal)
        net.WriteEntity(ent)
        net.WriteString(surfaceName)
        net.WriteFloat(mul or 1)
        net.WriteBool(withoutSmoke or false)
    end
else
    net.Receive("surfaceWorld_effectBullet",function()
        surfaceWorld.CreateEffectBullet(
            net.ReadVector(),
            net.ReadVector(),
            net.ReadEntity(),
            net.ReadString(),
            net.ReadFloat(),
            net.ReadBool()
        )
    end)
end