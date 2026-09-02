local SWEP = oop.Get("hg_wep")
if not SWEP then return end

local hg_inv_ammo

cvars.CreateServerOption("hg_inv_ammo","0",function(value)
	hg_inv_ammo = tonumber(value or 0) > 0
end,0,1)

function SWEP:FireBullet(data,pos,ang)
	--debugoverlayNet.BoxAngles(pos,-Vector(1,1,1),Vector(1,1,1),ang,1,Color(255,255,255,0))

	if SERVER then
		self.clientClip = self:Clip1()
	else
		if self.lastShoot + 0.5 < RealTime() then
			self.clientClip = self:Clip1()
		end
	end

	if not GetConVar("hg_inv_ammo"):GetBool() then
		self.clientClip = self.clientClip - 1

		self:SetClip1(self.clientClip)
	end

	self.chamber = false

	self:CreateBullet(data,pos,ang)

	if self.clientClip <= 0 then
		if self.Primary.ChamberAuto then
			self.chamber = nil
			if self.Primary.ChamberAutoReload then self:SetGateDelay(true) end
		end

		self:SetAmmoClass()
	elseif self.Primary.ChamberAuto then
		self.chamber = true
	end
end

function SWEP:RejectShell(noFilter)
    if not self:IsLocal() or not self.Primary.AmmoCalibre then return end
	local wm = self.wm
	if not IsValid(wm) then return end

	local att = wm:GetAttachment(2)
	if not att then return end

	local owner = self:GetOwner()
	local velocity = IsValid(owner) and owner:GetVelocity() or vector_origin
	CreateShell(self.Primary.AmmoCalibre,att.Pos,velocity + self:GetShellDir():Rotate(att.Ang),not noFilter and owner)

	return att.Pos,att.Ang
end

function SWEP:GetShellDir()
	return Vector(math.Rand(200,300),math.Rand(75,200),math.Rand(-50,50))
end
