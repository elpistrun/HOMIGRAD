local size = 1

local SoundBleedSurface = surfaceWorld.Fast.sound.bleed

local white = Color(255,0,0)
local Rand,random = math.Rand,math.random

local tr = {}

function gibParticles.bloodDrop.CollidePart(part,hitPos,hitNormal)
    tr.start = hitPos + hitNormal
    tr.endpos = hitPos - hitNormal

    local result = util.TraceLine(tr)
    if result.HitSky then return end
    
    local decalModulate = gibParticles.bloodDrop.decalModulate
    util.DecalEx(decalModulate[random(1,#decalModulate)],IsValid(result.Entity) and result.Entity or game.GetWorld(),hitPos,hitNormal,white,0.1,0.1)

    if not TEMPORARY then
        local info = SoundBleedSurface[surfaceWorld.GetSurfaceName(result.SurfaceProps)] or SoundBleedSurface.concrete
        sound.Emit(nil,info.list[random(1,#info.list)],65,0.1,info.pitch + random(-1,1) + 35,hitPos)
    end

    part:SetDieTime(0)
end

function gibParticles.bloodPoint.CollidePart(part,hitPos,hitNormal)
    tr.start = hitPos + hitNormal
    tr.endpos = hitPos - hitNormal

    local result = util.TraceLine(tr)
    if result.HitSky then return end

    local decalModulate = gibParticles.bloodPoint.decalModulate
    util.DecalEx(decalModulate[random(1,#decalModulate)],IsValid(result.Entity) and result.Entity or game.GetWorld(),hitPos,hitNormal,white,1,1)

    if not TEMPORARY then
        local info = SoundBleedSurface[surfaceWorld.GetSurfaceName(result.SurfaceProps)] or SoundBleedSurface.concrete
        sound.Emit(nil,info.list[random(1,#info.list)],65,0.1,info.pitch + random(-1,1) + 35,hitPos)
    end

    part:SetDieTime(0)
end


function gibParticles.bloodSeparate.CollidePart(part,hitPos,hitNormal)
    tr.start = hitPos + hitNormal
    tr.endpos = hitPos - hitNormal

    local result = util.TraceLine(tr)
    if result.HitSky then return end

    local decalModulate = gibParticles.bloodSeparate.decalModulate
    util.DecalEx(decalModulate[random(1,#decalModulate)],IsValid(result.Entity) and result.Entity or game.GetWorld(),hitPos,hitNormal,white,1,1)

    if not TEMPORARY then
        local info = SoundBleedSurface[surfaceWorld.GetSurfaceName(result.SurfaceProps)] or SoundBleedSurface.concrete
        sound.Emit(nil,info.list[random(1,#info.list)],65,0.1,info.pitch + random(-1,1) + 35,hitPos)
    end

    part:SetDieTime(0)
end

local function bleedInWater(pos,vel)
    local emitter = ParticleEmitter(pos)

    vel = VectorRand():Mul(12)

    local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos)

    if part then
        part:SetDieTime(Rand(15,20))

        part:SetColor(Rand(75,80),0,0)
        part:SetStartAlpha(Rand(90,100))
        part:SetEndAlpha(0)

        part:SetStartSize(Rand(8,10))
        part:SetEndSize(Rand(75,100))

        part:SetVelocity(vel)
        part:SetRoll(Rand(-10,10))
    end

    emitter:Finish()
end

function gibParticles.bloodDrop.CreatePart(pos,vel)
    if bit.band(util.PointContents(pos),CONTENTS_WATER) == CONTENTS_WATER then
        bleedInWater(pos,vel)
    else
        local emitter = ParticleEmitter(pos)

        local unlitGeneric = gibParticles.bloodDrop.unlitGeneric
        local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)

        if part then
            part:SetDieTime(dieTime or Rand(15,20))

            part:SetColor(255,255,255)
            part:SetStartAlpha(255)
            part:SetEndAlpha(0)

            part:SetStartLength(16)
            part:SetEndLength(0)
            part:SetStartSize(1.1)
            part:SetEndSize(1.1)

            part:SetGravity(ParticleGravity)
            part:SetVelocity(vel)
            part:SetLighting(true)
            part:SetCollide(true)
            part:SetCollideCallback(gibParticles.bloodPoint.CollidePart)
        end

        emitter:Finish()
    end
end

function gibParticles.bloodDrop.CreatePartArtery(pos,vel)
    if bit.band(util.PointContents(pos),CONTENTS_WATER) == CONTENTS_WATER then
        bleedInWater(pos,vel)
    else
        local emitter = ParticleEmitter(pos)

        local unlitGeneric = gibParticles.bloodDrop.unlitGeneric

        local velAng = vel:Angle()

        for i = 1,2 do
            local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)

            if part then
                part:SetDieTime(Rand(3,4))

                part:SetColor(75,0,0)
                part:SetStartAlpha(200)
                part:SetEndAlpha(0)

                part:SetStartLength(16)
                part:SetEndLength(0)
                part:SetStartSize(1.1)
                part:SetEndSize(1.1)

                vel:Rotate(Angle(Rand(-6,6),Rand(-6,6),0))

                part:SetGravity(ParticleGravity)
                part:SetVelocity(vel * Rand(0.5,1))
                part:SetCollide(true)
                part:SetCollideCallback(gibParticles.bloodPoint.CollidePart)
            end
        end

        local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos)

        if part then
            part:SetDieTime(Rand(0.1,0.3))

            part:SetColor(255,0,0)
            part:SetStartAlpha(5)
            part:SetEndAlpha(0)

            part:SetStartSize(0)
            part:SetEndSize(25)

            part:SetVelocity(vel * Rand(0.5,0.6))
            part:SetCollide(true)
        end

        timer.Simple(0.06,function()
            if not IsValid(emitter) then return end--lol?
            
            for i = 1,2 do
                local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)

                if part then
                    part:SetDieTime(Rand(3,4))

                    part:SetColor(75,0,0)
                    part:SetStartAlpha(200)
                    part:SetEndAlpha(0)

                    part:SetStartLength(5)
                    part:SetEndLength(0)

                    part:SetStartSize(1)
                    part:SetEndSize(1)

                    vel:Rotate(Angle(Rand(-6,6),Rand(-6,6),0))

                    part:SetGravity(ParticleGravity)
                    part:SetVelocity(vel * Rand(0.5,1))
                    part:SetCollide(true)
                    part:SetCollideCallback(gibParticles.bloodPoint.CollidePart)
                end
            end

            emitter:Finish()
        end)
    end
end