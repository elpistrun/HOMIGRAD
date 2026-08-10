ParticleGravitySet = Vector(0,0,-400)
ParticleGravityWind = Vector(0,0,0)

ParticleGravity = ParticleGravitySet:Clone()

ParticleMatSmoke = {}
for i = 1,6 do ParticleMatSmoke[i] = Material("particle/smokesprites_000" .. i) end
