temporary.Create("blood_fall",
function(data)
	net.WriteVector(data[1])
	net.WriteVector((data[2] or Vector()):GetNormalized())
end,
function(data)
	data[1] = net.ReadVector()
	data[2] = net.ReadVector()
end,
function(data)
	gibParticles.bloodFallCreate(data[1],data[2])
end) 

if SERVER then
	concommand.Add("blood_test2",function()
		gibParticles.bloodFallCreate(Vector(499.780853, -149.713257 ,90.956863),Vector(0,0,1))
	end)
end

if SERVER then
	function gibParticles.bloodFallCreate(pos,dir)
		temporary.Output("blood_fall",pos,dir)
	end

	return
end

local Rand,random = math.Rand,math.random

function gibParticles.bloodFallCreate(pos,dir)
	local r = random(10,15)

	local emitter = ParticleEmitter(pos)

	local unlitGeneric = gibParticles.bloodDrop.unlitGeneric

	for i = 1,r do//smoke
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		part:SetColor(125,0,0)
		part:SetDieTime(Rand(2,3))

        part:SetStartAlpha(random(25,55)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(33,45)) part:SetEndSize(Rand(75,90))

        part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodDrop.CollidePart)

		local dir = dir:Clone():Mul(400 * Rand(0.25,1))
		dir:Rotate(Angle(Rand(-45,45) * Rand(0.9,1.1),Rand(-45,45) * Rand(0.9,1.1)))
		dir:Mul(Rand(0.9,1.1))

		part:SetRoll(Rand(-360,360))
		part:SetVelocity(dir) part:SetAirResistance(5)
		part:SetGravity(ParticleGravity)
	end

	for i = 1,random(5,6) do//smoke lite
		local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos)
		if not part then continue end

		part:SetDieTime(Rand(0.7,1))

        part:SetStartAlpha(random(15,25)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(10,15)) part:SetEndSize(Rand(300,400))

        part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodDrop.CollidePart)
		part:SetColor(125,0,0)

		local dir = dir:Clone():Mul(4000 * Rand(0.25,1))
		dir:Rotate(Angle(Rand(-45,45) * Rand(0.9,1.1),Rand(-45,45) * Rand(0.9,1.1)))
		dir:Mul(Rand(0.9,1.1))

		part:SetVelocity(dir) part:SetAirResistance(1000)
		part:SetPos(pos)
	end

	for i = 1,r do//strine
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		part:SetColor(125,0,0)
		part:SetDieTime(Rand(2,3))

        part:SetStartAlpha(random(155,175)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(5,8)) part:SetEndSize(Rand(15,15))

        part:SetGravity(ParticleGravity)
        part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodDrop.CollidePart)

		local dir = dir:Clone():Mul(1000 * Rand(0.25,1))
		dir:Rotate(Angle(Rand(-45,45) * Rand(0.9,1.1),Rand(-90,90) * Rand(0.9,1.1)))
		dir:Mul(Rand(0.9,1.1))

		part:SetStartLength(dir:Length() / 8 * Rand(0.5,1))--wooooooow
		part:SetEndLength(0)

		part:SetVelocity(dir) part:SetAirResistance(25)
		part:SetPos(pos)
	end

	for i = 1,random(25,30) do//strine up
		local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
		if not part then continue end

		part:SetDieTime(Rand(10,15))

        part:SetStartAlpha(random(125,200)) part:SetEndAlpha(0)
        part:SetStartSize(Rand(12,14)) part:SetEndSize(Rand(25,37))

		part:SetGravity(ParticleGravity)
        part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodPoint.CollidePart)
		part:SetColor(125,0,0)

		part:SetPos(pos + dir:Clone():Rotate(Angle(Rand(80,89),Rand(-180,180),0)):Mul(Rand(15,25)))

		local dir = dir:Clone():Mul(Rand(75,400))
		dir:Rotate(Angle(Rand(-5,5) * Rand(0.9,1.1),Rand(-2,2) * Rand(0.25,1.1)))

		part:SetStartLength(dir:Length() / 23 * Rand(0.7,1.75))--wooooooow
		part:SetEndLength(0)

		part:SetVelocity(dir)
	end

	for i = 1,10 do//circle strine
		timer.Simple(i / 75,function()
			local emitter = ParticleEmitter(pos)

			for i = 1,random(1,3) do//strine
				local part = emitter:Add(unlitGeneric[random(1,#unlitGeneric)],pos)
				if not part then continue end
		
				part:SetColor(125,0,0)
				part:SetDieTime(Rand(2,3))
		
				part:SetStartAlpha(random(155,175)) part:SetEndAlpha(0)
				part:SetStartSize(Rand(5,8)) part:SetEndSize(Rand(15,15))
		
				part:SetGravity(ParticleGravity)
				part:SetCollide(true) part:SetCollideCallback(gibParticles.bloodDrop.CollidePart)
		
				local dir = dir:Clone():Mul(1000 * Rand(0.25,1))
				dir:Rotate(Angle(90 + Rand(-10,-2) * Rand(0.9,1.1),Rand(-180,180) * Rand(0.9,1.1)))
				dir:Mul(Rand(0.9,1.1))
		
				part:SetStartLength(dir:Length() / 8 * Rand(0.5,1))--wooooooow
				part:SetEndLength(0)
		
				part:SetVelocity(dir) part:SetAirResistance(25)
				part:SetPos(pos)
			end

			emitter:Finish()
		end)
	end

	emitter:Finish()

	if TEMPORARY then return end
	
	sound.Emit(nil,"homigrad/player/headshot/headshot_tp_" .. random(1,4) .. ".ogg",80,1,70,pos)
	sound.Emit(nil,"homigrad/player/headshot/headshot_tp_pumpkin_" .. random(1,9) .. ".ogg",80,1,70,pos)
	sound.Emit(nil,"homigrad/player/headshot/headshot" .. random(1,4) .. ".ogg",80,1,70,pos)
	
end