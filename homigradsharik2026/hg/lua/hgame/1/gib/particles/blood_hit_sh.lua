temporary.Create("blood_hit",
function(data)
	net.WriteVector(data[1])
	net.WriteVector((data[2] or Vector()):GetNormalized())
	net.WriteEntity(data[3])
end,
function(data)
	data[1] = net.ReadVector()
	data[2] = net.ReadVector()
	data[3] = net.ReadEntity()
end,function(data)
	gibParticles.bloodHitCreate(data[1],data[2],data[3])
end)

if SERVER then
	function gibParticles.bloodHitCreate(pos,dir,ent)
		temporary.Output("blood_hit",pos,dir,ent)
	end

	return
end

local Rand,random = math.Rand,math.random

function gibParticles.bloodHitCreate(pos,dir,ent)
	local r = random(2,3)

	local unlitGeneric = gibParticles.bloodDrop.unlitGeneric

	local emitter = ParticleEmitter(pos)

	local dirAngle = dir:Angle()

	for i = 1,r do
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		part:SetColor(90,0,0)
		part:SetDieTime(Rand(2,3))

        part:SetStartAlpha(random(255,255)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(2,4)) part:SetEndSize(Rand(5,7))

        part:SetGravity(ParticleGravity)
        part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodPoint.CollidePart)
		local dir = dir:Clone():Mul(-75 * Rand(0.25,1))
		dir:Add(dirAngle:Right() * Rand(-1,1) * 45)
		dir:Add(dirAngle:Up() * Rand(-0.5,0.5) * 75)

		part:SetStartLength(12)--wooooooow
		part:SetEndLength(0)

		part:SetRoll(Rand(-360,360))
		part:SetVelocity(dir) part:SetAirResistance(55)
		part:SetPos(pos)
	end

	r = random(1,2)

	for i = 1,r do
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		part:SetDieTime(Rand(2,3))

        part:SetStartAlpha(random(255,255)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(2,4)) part:SetEndSize(Rand(2,4))

        part:SetGravity(ParticleGravity)
        part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodPoint.CollidePart)

		local dir = dir:Clone():Mul(-125 * Rand(0.25,1))
		dir:Add(dirAngle:Right() * Rand(-1,1) * 25)
		dir:Add(dirAngle:Up() * Rand(-0.5,0.5) * 125)

		part:SetRoll(Rand(-360,360))
		part:SetVelocity(dir) part:SetAirResistance(125)
		part:SetPos(pos)
		part:SetColor(75,0,0)
	end
	
	-- 

	r = random(1,2)

	for i = 1,r do--back strine power
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		part:SetColor(125,0,0)
		part:SetDieTime(Rand(2,3))

        part:SetStartAlpha(255) part:SetEndAlpha(0)
        part:SetStartSize(Rand(5,6)) part:SetEndSize(Rand(2,4))

        part:SetGravity(ParticleGravity)
        part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodPoint.CollidePart)

		local dir = dir:Clone():Mul(512 * Rand(0.75,1.25))
		dir:Add(dirAngle:Right() * Rand(-1,1) * 25)
		dir:Add(dirAngle:Up() * Rand(-0.5,0.5) * 125)

		part:SetStartLength(25)
		part:SetEndLength(0)

		part:SetRoll(Rand(-360,360))
		part:SetVelocity(dir) part:SetAirResistance(125)
		part:SetPos(pos)
	end

	r = random(1,2)

	for i = 1,r do--back strine down
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		part:SetColor(125,0,0)
		part:SetDieTime(Rand(2,3))

        part:SetStartAlpha(255) part:SetEndAlpha(0)
        part:SetStartSize(Rand(2,4)) part:SetEndSize(Rand(2,4))

        part:SetGravity(ParticleGravity)
        part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodPoint.CollidePart)

		local dir = dir:Clone():Mul(512 * Rand(0.25,0.5))
		dir:Add(dirAngle:Right() * Rand(-1,1) * 25)
		dir:Add(dirAngle:Up() * Rand(-0.5,0.5) * 125)

		part:SetStartLength(15)
		part:SetEndLength(0)

		part:SetRoll(Rand(-360,360))
		part:SetVelocity(dir) part:SetAirResistance(125)
		part:SetPos(pos)
	end

	-- Smoke

	for i = 1,random(2,3) do
		local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos)
		if not part then continue end

		part:SetDieTime(Rand(1,1.3))

        part:SetStartAlpha(random(75,125)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(2,4)) part:SetEndSize(Rand(25,35))

		part:SetGravity(ParticleGravity)
        part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodSeparate.CollidePart)

		part:SetColor(75,0,0)

		local dir = dir:Clone():Mul(512 * Rand(0.25,1))
		dir:Add(dirAngle:Right() * Rand(-1,1) * 25)
		dir:Add(dirAngle:Up() * Rand(-0.5,-0.25) * 25)

		part:SetRoll(Rand(-360,360))
		part:SetVelocity(dir) part:SetAirResistance(1024)
		part:SetPos(pos)
	end

	emitter:Finish()
	
	if TEMPORARY then return end
	
	--sound.Emit(ent,"eft/impact/body" .. math.random(1,6) .. ".wav",70,1,100,pos,nil,ent)
end