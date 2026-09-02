local white = Color(255,255,255,75)
local Mat = Material("particle/dirt")

local vec = Vector(608.257080,784.239441,-12223.968750)

local list = {}

function ExplosiveWave(pos,maxdis,delay,createParticle,particleDis)
    local wave = {
        pos = pos,

        dis = maxdis,
        delay = delay,

        time = CurTime(),
        stops = {}
    }

    if createParticle then
        wave.emit = ParticleEmitter(pos)
        wave.emitDis = particleDis or maxdis
    end

    list[#list + 1] = wave
end

local white = Color(255,255,255,255)

local cos,sin = math.cos,math.sin
local min,max = math.min,math.max

local Rand = math.Rand
local vec = Vector()
local vec2 = Vector()

local TraceLine = util.TraceLine
local DrawSprite = render.DrawSprite

local tr = {
    filter = function(ent) return not ent:IsPlayer() and not ent:IsNPC() end
}

local colors = {
    [12] = Color(200,125,125)
}

local white = Color(255,255,255)

local particleLimit = 25
local delayParticle = 0
local particleCount = 0

hook.Add("PreDrawTranslucentRenderables","Wave",function()
    if true then return end
    render.SetMaterial(ParticleMatSmoke[math.random(1,#ParticleMatSmoke)])

    local i = 1

    if delayParticle < RealTime() then
        delayParticle = RealTime() + math.Rand(0.025,0.04)
        particleCount = 0
    end

    while true do
        local point = list[i]
        if not point then break end

        local maxdis = point.dis
        local maxParticleDis = point.emitDis
        local delay = point.delay
        local dis = (1 - (point.time + delay - CurTime()) / delay) * maxdis
        
        if dis >= maxdis then
            if point.emit then point.emit:Finish() end

            table.remove(list,i)

            continue
        end

        local pos = point.pos

        local size = 25 * dis / 100
        local max = 25 --dis / 15
    
        local k = 1 - (dis / (maxdis - 100))
    
        local dis2 = dis / 25
    
        local stops = point.stops
    
        for i = 1,max * 2 do
            local count = i
            if stops[count] then continue end
    
            i = i / max * 3.14
            --i = i * (i % 1 == 0 and -1 or 1)
            
            vec[1] = pos[1] + cos(i) * dis + Rand(-1,1) * dis2
            vec[2] = pos[2] + sin(i) * dis + Rand(-1,1) * dis2
            vec[3] = pos[3]
    
            vec2:Set(vec)
            vec2[3] = vec[3] - 512
    
            tr.start = vec
            tr.endpos = vec2
    
            local result = TraceLine(tr)
            if result.StartSolid then stops[count] = true continue end
    
            local color = colors[result.SurfaceProps] or white
            color.a = 50 * k
    
            DrawSprite(result.HitPos,size,size,color)

            if point.emit and dis <= maxParticleDis and particleCount < particleLimit and math.random(1,2) == 2 then
                local k = (dis / maxParticleDis)

                local part = point.emit:Add(ParticleMatSmoke[math.random(1,#ParticleMatSmoke)],result.HitPos + Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(25,125)))
                part:SetDieTime(math.random(3,4))
                part:SetColor(color)

                part:SetStartAlpha(math.random(55,75))
                part:SetEndAlpha(0)

                part:SetStartSize(math.random(55,75))
                part:SetEndSize(math.random(25 + 100 * k,750 + 250 * k))

                part:SetVelocity((vec - pos):GetNormalized():Mul(100 + 250 * k))
                particleCount = particleCount + 1
            end
        end

        i = i + 1
    end
end)

concommand.Add("hg_getsurfaceprops",function()
    local tr = {
        start = EyePos(),
        endpos = EyePos() - Vector(0,0,1000),
        filter = LocalPlayer()
    }

    PrintTable(TraceLine(tr))
end)