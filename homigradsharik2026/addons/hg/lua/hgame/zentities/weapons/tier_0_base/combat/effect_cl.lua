local SWEP = oop.Get("hg_wep")
if not SWEP then return end

local random,Rand = math.random,math.Rand

local mat_smoke = Material("homigrad/shine")
local mat_smoke_alpha = Material("homigrad/shine")

local mat_smoke2 = {
	Material("particle/smokesprites_0009"),
	Material("particle/smokesprites_0010"),
	Material("particle/smokesprites_0011")
}

local mat_sprak = Material("sprites/spark")
local mat_muzzle = Material("homigrad/shine")
local cos,sin = math.cos,math.sin

local AlphaMul = 0.2

function SWEP:ShootEffect_Manual(pos,dir,colorMuzzle,settings)
	if not IsValid(self:GetOwner()) or not self:GetOwner().renderLOD2 then return end

	local vel = self:GetOwner():GetVelocity()

	settings = settings or {}

    local ang = dir:Angle()
	local emitter = ParticleEmitter(pos)


	local Time = RealTime()

	local flashScale = settings.flashScale
	
	if flashScale then
		for i = 1,random(2,3) do--sparks
			local part = emitter:Add(mat_muzzle,pos)
			if part then
				part:SetDieTime(Rand(1 / 28,1 / 30))

				part:SetColor(colorMuzzle.r,colorMuzzle.g,colorMuzzle.b)

				part:SetStartAlpha(Rand(75,155))
				part:SetEndAlpha(Rand(0,25))

				part:SetStartSize(Rand(5,10) * flashScale / 2)
				part:SetEndSize(Rand(30,35) * flashScale)
				part:SetRoll(Rand(-360,360))

				part:SetVelocity(vel + dir * Rand(300,500))

				part:SetAirResistance(Rand(1750,2000))
			end
		end

		for i = 1,random(6,8) do--sparks lebgth
			local ang = ang:Clone():Rotate(Angle(Rand(-180,180),Rand(-180,180)))

			local part = emitter:Add(mat_smoke_alpha,pos + Vector(Rand(0,1),0,0):Rotate(ang))
			if part then
				part:SetDieTime((1 / Rand(18,19)) * flashScale)

				part:SetColor(colorMuzzle.r,colorMuzzle.g,colorMuzzle.b)

				part:SetStartAlpha(Rand(225,255))
				part:SetEndAlpha(Rand(0,25) * flashScale)

				part:SetStartSize(Rand(0.1,0.175) * flashScale)
				part:SetEndSize(Rand(0.2,0.3) * flashScale)

				part:SetStartLength(Rand(2,4) * flashScale)
				part:SetEndLength(Rand(6,7) * flashScale)

				part:SetVelocity(vel + Vector(Rand(125,300),0,0):Rotate(ang))
			end
		end

		--

		local part = emitter:Add(mat_sprak,pos + Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1)))
		if part then--glow
			part:SetDieTime(0.075)
			part:SetColor(colorMuzzle.r,colorMuzzle.g,colorMuzzle.b)

			part:SetStartAlpha(15)
			
			part:SetStartSize(Rand(6,8))
			part:SetEndSize(random(45,55) * flashScale)

			part:SetRoll(Rand(360,-360))
			part:SetVelocity(vel + dir * 125)
		end

		local part = emitter:Add(mat_sprak,pos + Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1)))
		if part then--glow alpha
			part:SetDieTime(0.035)
			part:SetColor(colorMuzzle.r,colorMuzzle.g,colorMuzzle.b)

			part:SetStartAlpha(5)

			part:SetStartSize(Rand(12,13))
			part:SetEndSize(random(125,145) * flashScale)

			part:SetRoll(Rand(360,-360))
			part:SetVelocity(vel + dir * 75)
		end
	end

	--

	for i = 1,random(1,3) do--very alpha black smoke
		local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],(pos + Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
		if part then
			part:SetDieTime(Rand(0.5,1))

			local p = random(35,45)
			part:SetColor(p,p,random(25,35))

			part:SetStartAlpha(Rand(15,25))
			part.LightFlashMul = 0
			part:SetEndAlpha(0)

			part:SetStartSize(Rand(6,8))
			part:SetEndSize(12)
			part:SetRoll(Rand(128,360))

			part:SetVelocity(vel + (dir * Rand(5,10)):Rotate(Angle(0,cos(Time * 36) * 50,0)) + Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1)))
			part:SetGravity(ParticleGravityWind)
		end
	end

	local timeScale = settings.gasTimeScale or 1
	local gasSideScale = settings.gasSideScale

	if gasSideScale then
		for i = 1,random(1,3) do--side gas
			local part = emitter:Add(mat_smoke,pos + Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1)))
			if part then
				part:SetDieTime(Rand(0.5,1) * timeScale)

				local p = random(200,255)
				part:SetColor(p,p,p)

				part:SetStartAlpha(Rand(25,35) * AlphaMul)
				part.LightFlashMul = 0.5
				part:SetEndAlpha(0)

				part:SetStartSize(Rand(6,8))
				part:SetEndSize(Rand(75,90) * gasSideScale)

				part:SetStartLength(Rand(7,8))
				part:SetEndLength(Rand(45,85) * gasSideScale)

				part:SetAirResistance(Rand(500,750))

				local ang = ang:Clone()
				ang:RotateAroundAxis(ang:Up(),90 + cos(Time * 25) * 7 + cos(Rand(0,100)) * Rand(25,45))
				ang:RotateAroundAxis(ang:Right(),sin(Time * 25) * 7)

				part:SetVelocity(vel + Vector(Rand(75,300),0,0):Rotate(ang):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
				part:SetGravity(ParticleGravityWind)
			end

			local part = emitter:Add(mat_smoke,pos + Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1)))
			if part then
				part:SetDieTime(Rand(0.5,1) * timeScale)

				local p = random(200,255)
				part:SetColor(p,p,p)

				part:SetStartAlpha(Rand(25,35) * AlphaMul)
				part.LightFlashMul = 0.5
				part:SetEndAlpha(0)

				part:SetStartSize(Rand(6,8))
				part:SetEndSize(Rand(75,90) * gasSideScale)

				part:SetStartLength(Rand(7,8))
				part:SetEndLength(Rand(45,85) * gasSideScale)

				part:SetAirResistance(Rand(500,750))

				local ang = ang:Clone()
				ang:RotateAroundAxis(ang:Up(),-90 + cos(Time * 25) * 7 + cos(Rand(0,100)) * Rand(25,45))
				ang:RotateAroundAxis(ang:Right(),sin(Time * 25) * 7)

				part:SetVelocity(vel + Vector(Rand(75,300),0,0):Rotate(ang):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
				part:SetGravity(ParticleGravityWind)
			end
		end
	end

	local gasForwardScale = settings.gasForwardScale

	if gasForwardScale then
		for i = 1,random(3,4) do--forward gass
			local part = emitter:Add(mat_smoke,pos - dir:Clone():Mul(12):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
			if part then
				part:SetDieTime(Rand(0.25,0.5) * timeScale)

				local p = random(200,255)
				part:SetColor(p,p,p)

				part:SetStartAlpha(Rand(25,35) * AlphaMul)
				part:SetEndAlpha(0)

				part:SetStartSize(Rand(6,8))
				part:SetEndSize(Rand(30,45) * gasForwardScale)

				part:SetStartLength(Rand(4,5))
				part:SetEndLength(Rand(55,75) * gasForwardScale)

				part:SetAirResistance(Rand(1000,1750))

				local ang = ang:Clone()
				ang:RotateAroundAxis(ang:Up(),sin(Time * 75 + i) * Rand(0.5,1.5) * 8,0)
				ang:RotateAroundAxis(ang:Right(),cos(Time * 75 + i) * Rand(0.5,1.5) * 3)

				part:SetVelocity(vel + Vector(Rand(255,750),0,0):Rotate(ang):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
				part:SetGravity(ParticleGravityWind)
			end
		end
	end
	
	local shellScale = settings.shellScale or 1
	
	if self.Primary.ShellModel then
		local pos,ang = self:GetShootMatrix()

		if pos then
			local dirShell = Vector(1,0,0):Rotate(ang)

			local dirGravity = dir:Clone()
			dirGravity[3] = 0
			dirGravity:Normalize()

			for i = 1,random(3,4) do--shell gass fast
				local part = emitter:Add(mat_smoke,pos - dirShell:Clone():Mul(12):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
				if part then
					part:SetDieTime(Rand(0.1,0.2) * timeScale * shellScale)

					local p = random(200,255)
					part:SetColor(p,p,p)

					part:SetStartAlpha(Rand(35,90) * AlphaMul)
					part.LightFlashMul = 0.5
					part:SetEndAlpha(0)

					part:SetStartSize(Rand(6,8))
					part:SetEndSize(Rand(45,55))

					part:SetStartLength(Rand(30,35))
					part:SetEndLength(Rand(35,45))

					part:SetAirResistance(Rand(800,900))

					local ang = ang:Clone()
					ang:RotateAroundAxis(ang:Up(),sin(Time * 75 + i) * Rand(0.5,1.5) * 45,0)
					ang:RotateAroundAxis(ang:Right(),cos(Time * 75 + i) * Rand(0.5,1.5) * 6)

					part:SetVelocity(vel + Vector(Rand(255,400),0,0):Rotate(ang):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
					part:SetGravity(-dirGravity * 1000 + ParticleGravityWind)
				end
			end

			for i = 1,random(3,4) do--shell gas
				local part = emitter:Add(mat_smoke,pos + dirShell:Clone():Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
				if part then
					part:SetDieTime(Rand(0.5,1) * timeScale * shellScale)

					local p = random(200,255)
					part:SetColor(p,p,p)

					part:SetStartAlpha(Rand(25,35) * AlphaMul)
					part.LightFlashMul = 0.5
					part:SetEndAlpha(0)

					part:SetStartSize(Rand(1,2))
					part:SetEndSize(Rand(45,75))

					part:SetRoll(Rand(-1000,1000))

					part:SetAirResistance(Rand(150,250))

					local ang = ang:Clone()
					ang:RotateAroundAxis(ang:Up(),sin(Time * 75 + i) - 25 * Rand(0.9,1.1) + Rand(-25,75))
					ang:RotateAroundAxis(ang:Right(),cos(Time * 75 + i) - 25 * Rand(0.9,1.1) + Rand(-45,45))

					part:SetVelocity(vel + Vector(Rand(95,125),0,0):Rotate(ang):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
					part:SetGravity(-dirGravity * 250 + ParticleGravityWind)
				end
			end
		end
	end

	local gasAround = settings.gasAround

	if gasAround then
		for i = 1,random(6,8) do
			local part = emitter:Add(ParticleMatSmoke[math.random(1,#ParticleMatSmoke)],pos - dir:Clone():Mul(settings.gasAroundBack):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
			if part then
				part:SetDieTime(Rand(1,3) * timeScale * gasAround)

				local p = random(200,255)
				part:SetColor(p,p,p)

				part:SetStartAlpha(Rand(7,15) * AlphaMul)
				part:SetEndAlpha(0)

				part:SetStartSize(Rand(2,3))
				part:SetEndSize(Rand(15,25))

				part:SetAirResistance(Rand(25,75))

				local ang = ang:Clone()
				ang[2] = ang[2] + Rand(-90,90)
				ang[1] = ang[1] + Rand(-25,25)

				part:SetVelocity(vel + Vector(Rand(15,20),Rand(15,20),Rand(5,10)):Rotate(ang):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
				part:SetGravity(ParticleGravityWind)
			end
		end
	end

	emitter:Finish()
end