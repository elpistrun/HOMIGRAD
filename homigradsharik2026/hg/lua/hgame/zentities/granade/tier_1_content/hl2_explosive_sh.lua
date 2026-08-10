local EXP = oop.Reg("explosive_hl2","explosive_base")
if not EXP then return end

EXP.Damage = 100
EXP.RadiusDamage = 500//наносит урон от взрывной волны
EXP.RadiusStun = 600//оглушает взрывной волной

EXP.FragCount = 800
EXP.FragDamage = 45
EXP.FragMaxDistance = 3500

// Client

EXP.ParticleGround = "100lb_air"
EXP.ParticleAir = "100lb_air"

EXP.Earrape = true
EXP.ExplosiveWave = false
EXP.ExplosivePunch = true

EXP.Power = 0

function EXP:EmitSound()
    sound.Emit(nil,"weapons/m67/m67_detonate_0" .. math.random(1,3) .. ".wav",120,1,100,self.pos)
    sound.Emit(nil,"snd_jack_fragsplodeclose.wav",120,1,100,self.pos)
end