local EXP = oop.Reg("explosive_base",nil,true)
if not EXP then return INCLUDE_BREAK end

function EXP:SetPos(pos)
    self.pos = pos
end

function EXP:SetParent(ent)
    self.parent = ent
end

function EXP:SetAttacker(attacker)
    self.attacker = attacker
end

EXP.Power = 25
EXP.Damage = 50
EXP.RadiusDamage = 1000//наносит урон от взрывной волны
EXP.RadiusStun = 1500//оглушает взрывной волной

EXP.FragCount = 3000
EXP.FragDamage = 45
EXP.FragMaxDistance = 7000

// Client

EXP.SoundClose = {"weapons/m67/m67_detonate_01.wav","weapons/m67/m67_detonate_02.wav","weapons/m67/m67_detonate_03.wav"}
EXP.SoundDist = {"weapons/m67/m67_detonate_dist_01.wav","weapons/m67/m67_detonate_dist_02.wav","weapons/m67/m67_detonate_dist_03.wav"}
EXP.SoundFar = {"weapons/m67/m67_detonate_far_dist_01.wav","weapons/m67/m67_detonate_far_dist_02.wav","weapons/m67/m67_detonate_far_dist_03.wav"}

EXP.ParticleGround = "100lb_ground"
EXP.ParticleAir = "100lb_air"

EXP.Earrape = true
EXP.ExplosiveWave = true
