local SWEP = oop.Get("hg_wep")
if not SWEP then return end

local data = {}

net.Receive("hg_wep_shoot",function()
    local class,ammoBulletName,renderTime,spread,silence = net.ReadString(),net.ReadString(),net.ReadDouble(),net.ReadString(),net.ReadBool()

    data.renderTime = renderTime
    data.ammoBulletName = ammoBulletName
    data.spread = tonumber(spread)
    data.silence = silence

    local entIndex,pos,ang = net.ReadInt(14),net.ReadVector(),net.ReadAngle()
    class = GetClassFromName(class)
    local ent = Entity(entIndex)

    data.entIndex = entIndex
    data.pos = pos
    data.ang = ang

    if IsValid(ent) and ent.CreateBullet then
        ent:CreateBullet(data)
    else
        class:CreateBullet(data)
    end
end)

local settings = {}

SWEP.MuzzleGasTime = 1
SWEP.MuzzleGasForward = 1
SWEP.MuzzleGasSide = 1

SWEP.MuzzleGasAround = 0.2
SWEP.MuzzleGasBack = 0

SWEP.MuzzleFlashScale = 1
SWEP.MuzzleGasShell = 1

SWEP:AttUpdate("Muzzle Effect",function(self,class)
    self.MuzzleGasTime = class.MuzzleGasTime
    self.MuzzleGasForward = class.MuzzleGasForward

    self.MuzzleGasSide = class.MuzzleGasSide
    self.MuzzleGasAround = class.MuzzleGasAround
    self.MuzzleGasBack = class.MuzzleGasBack

    self.MuzzleFlashScale = class.MuzzleFlashScale
    self.MuzzleGasShell = class.MuzzleGasShell

    self.Primary.Sound = class.Primary.Sound
end,function(self,att,key)
    if att.MuzzleGasTime != nil then self.MuzzleGasTime = att.MuzzleGasTime end
    if att.MuzzleGasForward != nil then self.MuzzleGasForward = att.MuzzleGasForward end

    if att.MuzzleGasSide != nil then self.MuzzleGasSide = att.MuzzleGasSide end

    if att.MuzzleGasAround != nil then self.MuzzleGasAround = att.MuzzleGasAround end
    if att.MuzzleGasBack != nil then self.MuzzleGasBack = att.MuzzleGasBack end

    if att.MuzzleFlashScale != nil then self.MuzzleFlashScale = att.MuzzleFlashScale end
    if att.MuzzleGasShell != nil then self.MuzzleGasShell = att.MuzzleGasShell end

    if att.PrimarySound != nil then self.Primary.Sound = att.PrimarySound end
end)

function SWEP:ShootEffect(pos,ang)
    local color = Color(255,225,125)

    local dir = Vector(1,0,0):Rotate(ang)

    self:ShootLight(pos,dir,color)

    settings.gasTimeScale = self.MuzzleGasTime
    settings.gasForwardScale = self.MuzzleGasForward
    settings.gasSideScale = self.MuzzleGasSide
    
    settings.gasAround = self.MuzzleGasAround
    settings.gasAroundBack = self.MuzzleGasBack

    settings.flashScale = self.MuzzleFlashScale
    settings.shellScale = self.MuzzleGasShell

    self:ShootEffect_Manual(pos,dir,color,settings)
end

local Rand = math.Rand

function SWEP:CreateBullet(data)
    local ammoBulletName = data.ammoBulletName or self:GetAmmoClass()
    local bulletInfo = ammoGame.config[ammoBulletName].bulletInfo or {}

    local count = bulletInfo.Count or 1

    --debugoverlayNet.BoxAngles(pos,-Vector(1,1,1),Vector(1,1,1),ang,1,Color(255,125,0,0))

    local renderTime = tonumber(data.renderTime)
    local pos,ang = data.pos,data.ang

	for i = 1,count do
		local bullet = customEnts.Create("bullet")
		bullet.pos = pos:Clone()

        local ang = ang

        if bulletInfo.Spray then
            local spread = bulletInfo.Spray

            ang = ang:Clone()
            ang:RotateAroundAxis(ang:Up(),FakeRandom(renderTime .. i,-spread,spread))
            ang:RotateAroundAxis(ang:Right(),FakeRandom(renderTime .. i * 2,-spread,spread))
        end

        local speed = bulletInfo.Speed or 676
        
		bullet:SetDir(Vector(speed,0,0):Rotate(ang))
        bullet:SetAngularDir(Vector(speed,0,0):Rotate(ang))

		bullet.startTime = UnPredictedCurTime()
		
		bullet.attacker = IsValid(self) and self:GetOwner()
		bullet.weapon = self

        bullet:SetClassBullet(ammoBulletName)
        
		bullet.doNotCrack = GetViewEntity() == bullet.attacker

        if IsValid(self) then
            local owner = self:GetOwner()

            if IsValid(owner) then
                bullet.filterTrace = {
                    [self:GetOwner():GetDummy()] = true,
                }
            end
            
            local fakeEnt = self:GetNWEntity("Fake")
            if fakeEnt then bullet.filterTrace[fakeEnt] = true end
        end
        
		bullet:Spawn()
	end

    --

    if IsValid(self) then
        self:SetupAttackVars()
        self:ShootEffect(pos,ang)
        if self.Primary.ChamberAuto and not self.CustomRejectShell then self:RejectShell() end
    end

    self:ShootSound(pos,ang,data.entIndex or self:EntIndex(),data.silence)
end