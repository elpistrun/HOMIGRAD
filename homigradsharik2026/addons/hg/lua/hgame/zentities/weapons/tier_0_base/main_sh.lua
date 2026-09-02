local SWEP = oop.Get("hg_wep")
if not SWEP then return end

SWEP:Event_Add("Init","Clip",function(self)
    self:SetClip1(self:GetMaxClip1())
    if self.GetMagazineItem then self:SetMagazineItem({path = self.Primary.MagazineModel}) end
    self:SetGateDelay(false)

    self.chamber = true
    self:SetAmmoClass(ammoGame.callibreIndex[self.Primary.AmmoCalibre])
end,-10)

SWEP:Event_Add("Action","Stop",function(self,cmd)
    if cmd.name != "stop" or not self.sequenceObject or not self.sequenceObject.canInputStop then return end

    self:ResetAnimation()

    return true
end,-2)

local action = SWEP:CreateAction("fire_empty")

function action.Start(self,cmd)
    self:EmitLocalSound(self.Primary.SoundEmpty,75,1,100,self:GetPos())

    self:AttackEmptyAnimation()
    if SERVER then self:SyncAnimation() end

    return true
end

function SWEP:CanPrimaryAttack(cmd)
    if self:IsCooldown("Primary",self:GetOwner()) then return false,"firerate" end
    if not self:CanFight("attack",cmd and cmd.startTime) then return false end

    if self:Clip1() <= 0 or not self:CanPrimaryAttackChamber() then return false,"empty" end

    return true
end

function SWEP:CanPrimaryAttackChamber() return self.chamber == true end

SWEP.startFireTime = 0
SWEP.resetFireTime = 0

local action = SWEP:CreateAction_Attack()

action.Start = function(self,cmd)
    if not self:CanPrimaryAttack(cmd) then return end

    if self.resetFireTime < RealTime() then
        self.startFireTime = RealTime()
    end

    self:SetCooldown("Primary",self.Primary.Delay)

    self.resetFireTime = RealTime() + self.Primary.Delay * 1.25

    if self:AttackAnimation() == false then return end

    cmd.silence = self.Primary.Silence
    
    self:FireBullet(cmd)

    return true
end

function SWEP:AttackAnimation()
    if self.clientClip == 1 and self.AnimationList.fire_last then
        self:PlayAnimation("fire_last")
    else
        self:PlayAnimation("fire")
    end
end

function SWEP:AttackEmptyAnimation()
    self:PlayAnimation("fire_empty")
end

SWEP.MuzzleAng = Angle(0,0,0)
SWEP.MuzzlePos = Vector(0,0,0)
SWEP.MuzzlePosStart = Vector(0,0,0)

SWEP:AttUpdate("Muzzle",function(self,class)
    self.MuzzlePos = class.MuzzlePos:Clone()
    self.MuzzlePosStart = class.MuzzlePos:Clone()
    
    self.Primary.Silence = class.Primary.Silencer
end,function(self,att,slot)
    if att.MuzzlePos then  self.MuzzlePos:Add(att.MuzzlePos) end
    if att.Silencer then self.Primary.Silence = true end
end)

SWEP.MuzzleShootAttachment = 1

function SWEP:GetShootMatrix(wm,isCamera)
    local wm = wm or self:GetWorldModel()
    if not wm then return self:GetPos(),self:GetAngles() end

    local att = wm:GetAttachment(self.MuzzleShootAttachment)
    if not att then return self:GetPos(),self:GetAngles() end

    local pos,ang = att.Pos,att.Ang

    ang[3] = 0

    if isCamera then
        return LocalToWorld(self.MuzzlePosStart,self.MuzzleAng,pos,ang)
    else
        return LocalToWorld(self.MuzzlePos,self.MuzzleAng,pos,ang)
    end
end