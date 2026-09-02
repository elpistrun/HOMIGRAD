temporary.Create("blood_headshoot",
function(data)
	net.WriteVector(data[1])
	net.WriteVector((data[2] or Vector()):GetNormalized())
end,
function(data)
	data[1] = net.ReadVector()
	data[2] = net.ReadVector()
end,function(data)
	gibParticles.bloodHeadShootCreate(data[1],data[2])
end)

if SERVER then
	function gibParticles.bloodHeadShootCreate(pos,dir)
		temporary.Output("blood_headshoot",pos,dir)
	end

	return
end

local Rand,random = math.Rand,math.random

function gibParticles.bloodHeadShootCreate(pos,dir)
	dir = dir or Vector()
	
	local l1,l2 = pos - dir / 2,pos + dir / 2

	local r = random(10,15)

	local unlitGeneric = gibParticles.bloodDrop.unlitGeneric

	local emitter = ParticleEmitter(pos)

	for i = 1,r do//back smoke
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		part:SetColor(125,0,0)
		part:SetDieTime(Rand(0.5,1))

        part:SetStartAlpha(random(255,255)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(8,9)) part:SetEndSize(Rand(12,12))

        part:SetGravity(ParticleGravity)
        part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodSeparate.CollidePart)

		local dir = dir:Clone():Mul(1000 * Rand(0.25,1))
		dir:Rotate(Angle(Rand(-35,35) * Rand(0.9,1.1),Rand(-35,35) * Rand(0.9,1.1)))
		dir:Mul(Rand(0.9,1.1))
		
		part:SetRoll(Rand(-360,360))
		part:SetVelocity(dir) part:SetAirResistance(25)
		part:SetPos(LerpVector(i / r * Rand(0.9,1.1),l1,l2))
	end

	for i = 1,r do//back strine
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		part:SetColor(125,0,0)
		part:SetDieTime(Rand(2,3))

        part:SetStartAlpha(random(155,175)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(12,14)) part:SetEndSize(19)

        part:SetGravity(ParticleGravity)
        part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodDrop.CollidePart)

		local dir = dir:Clone():Mul(1000 * Rand(0.25,1))
		dir:Rotate(Angle(Rand(-25,25) * Rand(0.9,1.1),Rand(-55,55) * Rand(0.9,1.1)))
		dir:Mul(Rand(0.9,1.1))

		part:SetStartLength(dir:Length() / 6)--wooooooow
		part:SetEndLength(0)

		part:SetVelocity(dir) part:SetAirResistance(25)
		part:SetPos(LerpVector(i / r * Rand(0.9,1.1),l1,l2))
	end

	for i = 1,random(5,7) do//center smoke
		local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos)
		if not part then continue end

		part:SetColor(125,0,0)
		part:SetDieTime(Rand(0.25,0.8))

        part:SetStartAlpha(random(33,45)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(10,15)) part:SetEndSize(Rand(25,75))

		local dir = dir:Clone():Mul(200)
		dir:Rotate(Angle(Rand(-15,15) * Rand(0.9,1.1),Rand(-125,125) * Rand(0.9,1.1) * math.randAbs()))

		part:SetVelocity(dir)
		part:SetPos(pos,l1,l2)
	end

	for i = 1,random(23,33) do//up strine
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		part:SetDieTime(Rand(10,15))

        part:SetStartAlpha(255) part:SetEndAlpha(0)
        part:SetStartSize(Rand(1,2)) part:SetEndSize(Rand(2,3))

		part:SetGravity(ParticleGravity)
        part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodPoint.CollidePart)
		part:SetColor(125,0,0)

		local dir = dir:Clone():Mul(75)
		dir:Rotate(Angle(Rand(-90,90) * Rand(0.9,1.1),Rand(90,230) * Rand(0.25,1.1) * math.randAbs()))
		dir[3] = dir[3] + Rand(75,333)

		part:SetStartLength(dir:Length() / 22)--wooooooow
		part:SetEndLength(0)

		part:SetVelocity(dir)
		part:SetPos(pos,l1,l2)
	end

	emitter:Finish()
	
	if TEMPORARY then return end

	sound.Emit(nil,"homigrad/player/headshot/headshot" .. math.random(1,5) .. ".ogg",75,1,100,pos)
	sound.Emit(nil,"homigrad/player/headshot/headshot_tp_" .. math.random(1,4) .. ".ogg",75,1,85,pos)
	sound.Emit(nil,"homigrad/player/headshot" .. math.random(1,2) .. ".ogg",75,0.5,100,pos)
end