temporary.Create("blood_explode",
function(data)
	net.WriteVector(data[1])
	net.WriteVector((data[2] or Vector()):GetNormalized())
end,
function(data)
	data[1] = net.ReadVector()
	data[2] = net.ReadVector()
end,function(data)
	gibParticles.bloodExplodeCreate(data[1],data[2])
end)

local Rand,random = math.Rand,math.random

function gibParticles.bloodExplodeCreate(pos,posEmit)
	local dir = pos - posEmit
	dir:Normalize()

	if SERVER then
		local dir = dir:Clone():Mul(Rand(75,125))
		dir[3] = dir[3] + Rand(200,400)
		DropProp("models/Gibs/HGIBS.mdl",1,pos,Angle(),dir,Vector(Rand(-180,180),Rand(-180,180),Rand(-180,180)))
		for i = 1,2 do
			dir:Rotate(Angle(Rand(-75,75),Rand(-75,75),0))
			DropProp("models/Gibs/HGIBS_rib.mdl",1,pos,Angle(),dir,Vector(Rand(-180,180),Rand(-180,180),Rand(-180,180)))

			dir:Rotate(Angle(Rand(-75,75),Rand(-75,75),0))
			DropProp("models/Gibs/HGIBS_scapula.mdl",1,pos,Angle(),dir,Vector(Rand(-180,180),Rand(-180,180),Rand(-180,180)))
		end

		dir:Rotate(Angle(Rand(-75,75),Rand(-75,75),0))
		DropProp("models/Gibs/HGIBS_spine.mdl",1,pos,Angle(),dir,Vector(Rand(-180,180),Rand(-180,180),Rand(-180,180)))

		temporary.Output("blood_explode",pos,posEmit)

		return
	end

	local emitter = ParticleEmitter(pos)

	local unlitGeneric = gibParticles.bloodDrop.unlitGeneric

	for i = 1,random(25,30) do
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		local dir = dir:Clone():Mul(1000)
		dir:Rotate(Angle(Rand(-75,75),Rand(-125,125),0))

		part:SetColor(125,0,0)
		part:SetDieTime(Rand(0.5,1))

		part:SetStartAlpha(random(125,155)) part:SetEndAlpha(0)
		part:SetStartSize(Rand(10,15)) part:SetEndSize(Rand(125,175))

		part.Pos = pos
		part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodSeparate.CollidePart)

		part:SetRoll(Rand(-300,300))
		part:SetVelocity(dir) part:SetAirResistance(Rand(155,300))
		part:SetPos(pos)
	end

	for i = 1,random(5,7) do
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		local dir = dir:Clone():Mul(-1000)
		dir:Rotate(Angle(Rand(-75,15),Rand(-125,125),0))

		part:SetColor(125,0,0)
		part:SetDieTime(Rand(0.1,0.2))

		part:SetStartAlpha(random(125,155)) part:SetEndAlpha(0)
		part:SetStartSize(Rand(10,15)) part:SetEndSize(Rand(55,75))

		part.Pos = pos
		part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodSeparate.CollidePart)

		part:SetRoll(Rand(-300,300))
		part:SetVelocity(dir)
		part:SetPos(pos)
	end

	for i = 1,random(15,25) do
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		local dir = dir:Clone():Mul(1555)
		dir:Rotate(Angle(Rand(-90,15),Rand(-125,125),0))

		part:SetColor(125,0,0)
		part:SetDieTime(Rand(0.5,1))

		part:SetStartAlpha(random(125,155)) part:SetEndAlpha(0)
		part:SetStartSize(Rand(10,15)) part:SetEndSize(Rand(55,75))

		part.Pos = pos
		part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodSeparate.CollidePart)

		part:SetGravity(ParticleGravity)
		part:SetStartLength(dir:Length() / 10)
		part:SetEndLength(0)

		part:SetVelocity(dir)
		part:SetPos(pos)
	end

	for i = 1,random(15,25) do
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		local dir = dir:Clone():Mul(Rand(300,500))
		dir:Rotate(Angle(Rand(-90,15),Rand(-125,125),0))
		dir[3] = dir[3] + Rand(555,1000)

		part:SetColor(64,0,0)
		part:SetDieTime(Rand(3,4))

		part:SetStartAlpha(random(125,155)) part:SetEndAlpha(0)
		part:SetStartSize(Rand(10,15)) part:SetEndSize(Rand(55,75))

		part.Pos = pos
		part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodSeparate.CollidePart)

		part:SetGravity(ParticleGravity * 4)
		part:SetStartLength(dir:Length() / 25)
		part:SetEndLength(0)

		part:SetVelocity(dir)
		part:SetPos(pos)
	end

	for i = 1,random(25,30) do
		local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos)
		if not part then continue end

		local dir = dir:Clone():Mul(Rand(555,666))
		dir:Rotate(Angle(Rand(-75,75),Rand(-75,75),0))

		part:SetDieTime(Rand(2,3))

		part:SetStartAlpha(random(25,55)) part:SetEndAlpha(0)
		part:SetStartSize(Rand(25,55)) part:SetEndSize(Rand(125,175))

		part.Pos = pos
		part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodSeparate.CollidePart)
		part:SetColor(Rand(64,75),0,0)

		part:SetRoll(Rand(-300,300))
		part:SetVelocity(dir) part:SetAirResistance(Rand(200,300))
		part:SetPos(pos)
	end

	for i = 1,random(15,25) do
		local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos)
		if not part then continue end

		local dir = dir:Clone():Mul(-Rand(555,666))
		dir:Rotate(Angle(Rand(-75,75),Rand(-75,75),0))

		part:SetDieTime(Rand(2,3))

		part:SetStartAlpha(random(25,55)) part:SetEndAlpha(0)
		part:SetStartSize(Rand(25,55)) part:SetEndSize(Rand(125,175))

		part.Pos = pos
		part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodSeparate.CollidePart)
		part:SetColor(Rand(65,75),0,0)

		part:SetRoll(Rand(-300,300))
		part:SetVelocity(dir) part:SetAirResistance(Rand(200,300))
		part:SetPos(pos)
	end

	emitter:Finish()

	if not TEMPORARY then
		sound.Emit(nil,"physics/flesh/flesh_bloody_impact_hard1.wav",75,1,50,pos)
		sound.Emit(nil,"physics/flesh/flesh_bloody_break.wav",75,1,80,pos)
		sound.Emit(nil,"physics/flesh/flesh_strider_impact_bullet3.wav",75,1,100,pos)
	end
end