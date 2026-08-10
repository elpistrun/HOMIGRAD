local SWEP = oop.Get("hg_wep")
if not SWEP then return end

local cmdAction = {}

function SWEP:PrimaryAttack(force)
    if not force and not IsFirstTimePredicted() then return end

	local success,err = self:CanPrimaryAttack()

	if not success then
		if err == "empty" then
			self.Primary.Automatic = false

			self:DoAction({name = "fire_empty"})
		elseif err != "firerate" then
			self.Primary.Automatic = false

			if not self:DoAction({name = "stop"}) and not force then
				self:InputBufferAdd("primaryattack",function()
					if self:PrimaryAttack(true) then return true end
				end,0.05)
			end
		end

		return
	end

	self.Primary.Automatic = GetClassFromName(self:GetClass()).Primary.Automatic

    local pos,ang = self:GetShootMatrix()

	cmdAction.name = "attack"
	cmdAction.startTime = UnPredictedCurTime()
	cmdAction.renderTime = GetRenderTime()
	cmdAction.pos = pos
	cmdAction.ang = ang
	
    self:DoAction(cmdAction)

    self:ApplySpray()

	return true
end

function SWEP:PostRenderWM(wm)
    if IsValid(self) and EyePos():Distance(wm:GetPos()) <= 500 then self:DrawSmoke(wm) end

	self:PostRenderWM_Attachment(wm)
end

local white = Color(255,255,160)
local mat = Material("homigrad/shine")
local random,Rand = math.random,math.Rand

local cos = math.cos

function SWEP:DrawSmoke(wm)
	local Time = RealTime()
	if (self.delaySmoke or 0) > Time then return end
	self.delaySmoke = Time + 1 / 24

	local smoke = math.Clamp(self:GetNWFloat("Smoke",0) - CurTime(),0,3) / 3
	local k = math.max((self.lastShoot + 1 - CurTime()),0)

	smoke = smoke * (1 - k)
	if smoke <= 0 then return end

	local pos,ang = self:GetShootMatrix()

	local dir = Vector(1,0,0):Rotate(ang)

	local emitter = ParticleEmitter(pos)

	local part = emitter:Add(mat,pos:Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
	if part then
		part:SetDieTime(Rand(1,2))

		local p = random(200,255)
		part:SetColor(p,p,p)

		part:SetStartAlpha(Rand(15,25) * smoke)
		part:SetEndAlpha(0)

		part:SetStartSize(Rand(3,4))
		part:SetStartLength(Rand(4,8))
		part:SetEndLength(Rand(12,15))
		part:SetEndSize(Rand(8,14))

		part:SetVelocity(Vector(0.01,0,Rand(12,22)):Rotate(Angle(0,cos(Time * 3 + self:EntIndex()) * 7,0)):Add(Vector(Rand(-1,1),Rand(-1,1),Rand(-1,1))))
	end

	emitter:Finish()
end