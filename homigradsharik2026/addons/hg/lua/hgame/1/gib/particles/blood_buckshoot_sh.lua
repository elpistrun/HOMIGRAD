temporary.Create("blood_buckshoot",
function(data)
	net.WriteVector(data[1])
	net.WriteVector((data[2] or Vector()):GetNormalized())
end,
function(data)
	data[1] = net.ReadVector()
	data[2] = net.ReadVector()
end,function(data)
	gibParticles.bloodBuckShootCreate(data[1],data[2])
end)

if SERVER then
	function gibParticles.bloodBuckShootCreate(pos,dir)
		temporary.Output("blood_buckshoot",pos,dir)
	end

	return
end

local Rand,random = math.Rand,math.random

function gibParticles.bloodBuckShootCreate(pos,dir)
	local l1,l2 = pos - dir / 2,pos + dir / 2

	local r = random(15,25)

	local emitter = ParticleEmitter(pos)

	local unlitGeneric = gibParticles.bloodDrop.unlitGeneric

	timer.GameSimple(0.016,function()
		local emitter = ParticleEmitter(pos)
		
		for i = 1,r do//smokes
			local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
			if not part then continue end

			part:SetColor(125,0,0)
			part:SetDieTime(Rand(0.5,1))

			part:SetStartAlpha(random(100,200)) part:SetEndAlpha(0)
			part:SetStartSize(Rand(10,15)) part:SetEndSize(Rand(64,64))

			part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodSeparate.CollidePart)

			local dir = dir:Clone():Mul(1000 * Rand(0.5,1.5))
			dir:Rotate(Angle(Rand(-35,35) * Rand(0.9,1.1),Rand(-35,35) * Rand(0.9,1.1)))
			dir:Mul(Rand(0.9,1.1))

			part:SetRoll(Rand(-360,360))
			part:SetVelocity(dir) part:SetAirResistance(225)
			part:SetGravity((pos - (pos + dir)):Mul(0.33))
			part:SetPos(LerpVector(i / r * Rand(0.9,1.1),l1,l2))
		end

		for i = 1,r do//smokes
			local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos)
			if not part then continue end

			part:SetColor(64,0,0)
			part:SetDieTime(Rand(0.5,1))

			part:SetStartAlpha(random(66,128)) part:SetEndAlpha(0)
			part:SetStartSize(Rand(10,15)) part:SetEndSize(Rand(64,100))

			part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodSeparate.CollidePart)

			local dir = dir:Clone():Mul(1000 * Rand(0.5,1.5))
			dir:Rotate(Angle(Rand(-35,35) * Rand(0.9,1.1),Rand(-55,55) * Rand(0.9,1.1)))
			dir:Mul(Rand(0.4,0.5))

			part:SetRoll(Rand(-360,360))
			part:SetVelocity(dir) part:SetAirResistance(100)
			part:SetPos(LerpVector(i / r * Rand(0.9,1.1),l1,l2))
		end

		emitter:Finish()
	end)

	r = random(25,35)

	for i = 1,r do//strine
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		part:SetColor(125,0,0)
		part:SetDieTime(Rand(0.5,0.5))

        part:SetStartAlpha(random(255,255)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(10,15)) part:SetEndSize(Rand(15,15))

        part:SetGravity(ParticleGravity)
        part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodDrop.CollidePart)

		local dir = dir:Clone():Mul(1000 * Rand(0.25,1))
		dir:Rotate(Angle(Rand(-25,25) * Rand(0.9,1.1),Rand(-55,55) * Rand(0.9,1.1)))
		dir:Mul(Rand(0.9,1.1))

		part:SetStartLength(dir:Length() / 10)--wooooooow
		part:SetEndLength(0)

		part:SetVelocity(dir) part:SetAirResistance(25)
		part:SetPos(LerpVector(i / r * Rand(0.9,1.1),l1,l2))
	end

	emitter:Finish()
	
	if TEMPORARY then return end

	sound.Emit(nil,"physics/flesh/flesh_bloody_break.wav",75,0.5,75,pos)
	sound.Emit(nil,"physics/flesh/flesh_bloody_break.wav",75,0.25,100,pos)
	sound.Emit(nil,"physics/flesh/flesh_strider_impact_bullet3.wav",75,1,75,pos)
	for i = 1,3 do sound.Emit(nil,"homigrad/blood_splash.wav",75,1,100,pos) end
end