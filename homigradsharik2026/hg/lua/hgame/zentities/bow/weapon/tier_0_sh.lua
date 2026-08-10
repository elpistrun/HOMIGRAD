local SWEP = oop.Reg("wep_bow",{"hg_wep_base","tpik_animate","wep_lib_camera"},true)--пашол нахуй
if not SWEP then return INCLUDE_BREAK end

SWEP.SupportCustomAttack = true
SWEP.BlockSecondaryWeapon = true

SWEP.Primary.AmmoCalibre = "arrow"

SWEP.PrintName = "Лук"
SWEP.Author 				= "0oa"
SWEP.Category 				= L("weapon_category_item")

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.WorldModel = "models/weapons/v_farcrybow.mdl"
SWEP.PhysicsBox = {-Vector(5,16,1),Vector(3,16,1)}

SWEP:TableLink("wmData",{model = "models/weapons/v_farcrybow.mdl",vec = Vector(14,-2,-7),ang = Angle(-2,0,-20),center = {Vector(-21.5,-1,7.6),Angle(0,0,15)}})
SWEP:TableLink("wmFastData",{model = "models/weapons/v_farcrybow.mdl",vec = Vector(13,-2,0),ang = Angle(0,0,-70),center = {Vector(-21.5,-1,7.6),Angle(0,0,15)}})

SWEP.CorrectiveDropInfo = {
    bone = "bone_bow",

    ang = Angle(0,0,180),
    vec = Vector(0,0,0)
}

SWEP.TPIKLerpWhitelist["bone_bow"] = true
SWEP.TPIKLerpWhitelist["bone_arrow"] = true
SWEP.TPIK_TwistOffset = 90

SWEP.ImmersiveAngleSetMul = 0
SWEP.ImmersiveAngleMul = 0
SWEP.ImmersiveCameraMul = 0

SWEP.Slot = 2
SWEP.SlotPos = 100

SWEP.itemType = "weaponSecondary"

SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 0.76

SWEP.CameraPos = Vector(0,0,0)

SWEP.HoldType = "smg"

SWEP.vbwPos = Vector(0,0,-5)
SWEP.vbwAng = Angle(45,0,-90)

SWEP.dwsPos = Vector(11,-200,-10)
SWEP.dwiSelectPos = Vector(11,-400,-10)
SWEP.dwiPos = Vector(11,-130,-10)

SWEP.dwsAng = Angle(180 + 45,0,90)

function SWEP:CanPrimaryAttack()
    if self:Clip1() <= 0 then return false end

    return self:CanPrimaryAttackEx()
end

function SWEP:CanPrimaryAttackEx()
    if not self:CanFight() or (self:IsTPIKLeftInputBusy() or self:IsTPIKRightInputBusy()) then return false end

    return not self:IsCooldown("Attack",self:GetOwner())
end

SWEP.startFireTime = 0
SWEP.resetFireTime = 0
SWEP.attackCurTime = 0

local action = SWEP:CreateAction_Attack()

function action.Start(self,cmd)
	if not self:CanPrimaryAttack() then return end
	
	self:SetCooldown("Attack",self.Primary.Delay)
	
	self:SetClip1(0)
	
	self:PlayAnimation("fire")
	if SERVER then self:SyncAnimation() end

    self:FireBullet(cmd)

	return true
end

local vec_zero = Vector()
local muzzle_ang = Angle(0,90,0)

function SWEP:GetShootMatrix()
    local owner = self:GetOwner()
    if not owner then return self:GetPos(),self:GetAngles() end

	local wm = self.wm
	if not IsValid(wm) then return self:GetPos(),self:GetAngles() end

	local matrix = wm:GetBoneMatrix(44)
	if not matrix then return self:GetPos(),self:GetAngles() end

    return LocalToWorld(vec_zero,muzzle_ang,matrix:GetTranslation(),matrix:GetAngles())
end

function SWEP:GetArrowFromInv()
	for i,item in pairs(self:GetOwner():GetAutoItems()) do
		if item.spawnname != "item_ammo" or item.data.ammoName != "arrow" then continue end

		return item
	end

	return false
end

function SWEP:OnThink()
	local owner = self:GetOwner()

	if self:IsSequencePlaying("insert",true) == 1 then
		self:ResetAnimation()
		
		if CLIENT then self:SetCooldown("insert",0.1) end
		
		local item = self:GetArrowFromInv()

		if item then
			if SERVER then inventoryGame.TakeResource(item,1) end

			self:SetClip1(1)
		end
	end
	
	if owner:KeyDown(IN_ATTACK) then
		if not self:IsSequencePlaying("prefire",true) then
			if self:CanPrimaryAttackEx(true) and self:Clip1() <= 0 and not self:IsCooldown("insert") and not self:IsSequencePlaying("insert",true) then
				if not self:GetArrowFromInv() then return end

				self:PlayAnimation("insert")
				if SERVER then self:SyncAnimation() end
			end

			if self:CanPrimaryAttack(true) then
				self:PlayAnimation("prefire")
				if SERVER then self:SyncAnimation() end
			end
		end
	else
		local preFireCycle = self:IsSequencePlaying("prefire",true)

		if preFireCycle then
			if self.AnimationList.prefire.canFireCycle <= preFireCycle then
				if CLIENT then
					self:PrimaryAttack(true)
				end
			elseif not self:IsSequencePlaying("losefire",true) then
				self:PlayAnimation({name = "losefire",start = UnPredictedCurTime() - (1 - preFireCycle) * self.AnimationList.prefire.delay})
				if SERVER then self:SyncAnimation() end
			end
		end
	end
end

function SWEP:IsSprinting() return false end

if SERVER then return end

local cmdAction = {}

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() or not self:CanPrimaryAttack() then return end
	local cyclePreFire = self:IsSequencePlaying("prefire",true)
	
	if self.AnimationList.prefire.canFireCycle <= (cyclePreFire or 0) then
		local pos,ang = self:GetShootMatrix()

		cmdAction.name = "attack"
		cmdAction.renderTime = GetRenderTime()
		cmdAction.pos = pos
		cmdAction.ang = ang
			
		self:DoAction(cmdAction)
	end
end

function SWEP:CreateWorldModelPost(wm,tag,typeDraw,depth)
	local mdl = self:CreateModelForWM(wm,"models/props_c17/TrapPropeller_Lever.mdl","scope",typeDraw)
	mdl.followBone = wm:LookupBone("bone_bow")
	mdl.localPos = Vector(-0.2,4.71,-1.18)
	mdl.localAng = Angle(0,0,90)

	mdl:EnableMatrixScale(Vector(0.1,0.09,0.05))
end