local EXP = oop.Reg("explosive_rgd5","explosive_base")
if not EXP then return end

EXP.Damage = 100
EXP.RadiusDamage = 1200//наносит урон от взрывной волны
EXP.RadiusStun = 500//оглушает взрывной волной

EXP.FragCount = 2500
EXP.FragDamage = 35
EXP.FragMaxDistance = 6000

// Client

EXP.ParticleGround = "pcf_jack_groundsplode_small"
EXP.ParticleAir = "100lb_air"

EXP.Earrape = true
EXP.ExplosiveWave = false
EXP.ExplosivePunch = true

EXP.Power = 0

function EXP:EmitSound()
    sound.Emit(nil,"weapons/m67/m67_detonate_0" .. math.random(1,3) .. ".wav",120,1,100,self.pos)
    sound.Emit(nil,"snd_jack_fragsplodeclose.wav",120,1,100,self.pos)
end