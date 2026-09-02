local EXP = oop.Get("explosive_base")
if not EXP then return end

net.Receive("explosive",function()
    local explosive = oop.Create(net.ReadString())

    explosive:Sync(net.ReadTable())
    explosive:Emit()
end)

function EXP:Sync(data)
    self:SetPos(data[1])
    self:SetParent(data[2])

    if IsValid(data[2]) and self.KeepExplosiveParent then
        data[2]:SetNoDraw(true)
    end
end

local repeatSound = 3

function EXP:EmitSound()
    local dis = EyePos():Distance(self.pos)

    if dis <= 2000 then
        if self.isGround then
            local r = math.random(1,#self.SoundClose)
            for i = 1,dis <= 1000 and repeatSound * 2 or repeatSound do sound.Emit(nil,self.SoundClose[r],130,1,100,self.pos) end
        else
            local r = math.random(1,#self.SoundDist)
            for i = 1,dis <= 1000 and repeatSound * 2 or repeatSound do sound.Emit(nil,self.SoundDist[r],130,1,100,self.pos) end
        end
    else
        if dis <= 6000 then
            local r = math.random(1,#self.SoundClose)
            for i = 1,repeatSound do sound.Emit(nil,self.SoundClose[r],130,1,100,self.pos,"0") end
        else
            local k = math.min((dis - 6000) / 1500,1)

            local r = math.random(1,#self.SoundDist)
            for i = 1,repeatSound do sound.Emit(nil,self.SoundDist[r],130,1 - k,100,self.pos,"0") end

            if self.SoundFar then
                local r = math.random(1,#self.SoundFar)
                for i = 1,repeatSound do sound.Emit(nil,self.SoundFar[r],130,k,100,self.pos,"0") end
            end
        end
    end

    sound.EmitGunShoot(self.pos,"explosive")
end

local hg_best_explosive
cvars.CreateOption("hg_best_explosive","2",function(value) hg_best_explosive = math.Clamp(tonumber(value or 0),0,2) end,2,2)

local vector_up,angle_up = Vector(0,0,1),Angle(0,0,0)

function EXP:EmitSpoon()
    for i = 1,math.Clamp(self.RadiusDamage / 200,1,15) do
        local tr = {
            start = self.pos,
            endpos = Vector(math.Rand(-1,1),math.Rand(-1,1),-2):Mul(self.RadiusDamage),
            filter = self.parent
        }

        tr = util.TraceLine(tr)

        if tr.Hit then
            util.Decal("Scorch",tr.HitPos + tr.HitNormal,tr.HitPos - tr.HitNormal)
        end
    end
end

function EXP:EmitParticleEffect()
    local name = self.isGround and self.ParticleGround or self.ParticleAir
    ParticleEffect(name,self.pos,angle_up)

    if self.isGround then self:EmitSpoon() end
end

function EXP:EmitEffect()
    self:EmitParticleEffect()

    local radius = self.RadiusStun > 500 and math.min(self.RadiusStun * 5,6000) or self.RadiusStun * 2

    if self.ExplosiveWave and hg_best_explosive > 0 then
        local tr = {
            start = self.pos,
            endpos = self.pos - Vector(0,0,self.RadiusStun * 0.75)
        }

        tr = util.TraceLine(tr)

        if tr.Hit then
            ExplosiveWave(tr.HitPos + Vector(0,0,15),radius,radius * UNITS_TO_METERS / SOUND_SPEED,hg_best_explosive == 2,radius / 3)
        end
    end

    if self.ExplosiveWave or self.ExplosivePunch then ExplosivePunch(self.pos,radius * UNITS_TO_METERS) end
    if self.Earrape then sound.GiveEarrapeOfPos(self.pos,radius) end

    --debugoverlay.Sphere(self.pos,self.RadiusDamage,1,Color(255,0,0,0))
    --debugoverlay.Sphere(self.pos,self.RadiusStun,1,Color(255,255,255,0))
end

function EXP:Emit()
    if IsValid(self.parent) then self.parent:SetNotSolid(true) end

    local tr = {
        start = self.pos,
        endpos = self.pos - Vector(0,0,self.RadiusDamage / 2)
    }

    self.isGround = util.TraceLine(tr).Hit
    
    self:EmitSound()
    sound.EmitGunShoot(self.pos,"explosive")

    self:EmitEffect()
    util.ScreenShake(self.pos,20,20,1,self.RadiusStun)
end