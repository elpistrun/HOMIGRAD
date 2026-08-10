local SWEP = oop.Reg("hg_wep_base",{"base_weapon"},true)
if not SWEP then return INCLUDE_BREAK end

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.CustomSpawnContentEnable = true

SWEP.wmBone = "ValveBiped.Bip01_R_Hand"

SWEP.wmData = {
    vec = Vector(),
    ang = Angle(),
	center = {Vector(),Angle()}
}

SWEP.wmFastData = {
    vec = Vector(),
    ang = Angle(),
	center = {Vector(),Angle()}
}

SWEP.wmVeryFastData = {
    vec = Vector(),
    ang = Angle(),
	center = {Vector(),Angle()},
    depth = 0
}

function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end
function SWEP:Reload() end

function SWEP:OnInit() end

function SWEP:OnThink() end
function SWEP:OnThinkOutside() end

--

if CLIENT then
	SWEP.InvMoveSnd = inventoryGame.soundUI.Weapon
	
	local WeaponIconMatrix = render.WeaponIconMatrix

	SWEP.DrawWeaponSelection = function(self,x,y,w,h)
		render.ClearWeaponIcon()

		WeaponIconMatrix.self = self
		WeaponIconMatrix.x = x
		WeaponIconMatrix.y = y
		WeaponIconMatrix.w = w
		WeaponIconMatrix.h = h
		WeaponIconMatrix.Pos = self.dwsPos
		WeaponIconMatrix.Ang = self.dwsAng

		render.DrawWeaponIcon()
	end
end

local err = function(err) ErrorNoHaltWithStack(err) end

SWEP.EnableThinkOutside = true

function SWEP:Initialize()
	self:DrawShadow(false)

    self:Event_Call("Init")
	self:OnInit()

	if self.EnableThinkOutside then
		local path = self:EntIndex()

		timer.Create(path,TickInterval(),0,function()
			if not IsValid(self) then timer.Remove(path) return end
			if self:IsDormant() or not self:IsActive() then return end

			if self:IsLocal() then
				if self.Think and IsValid(self:GetOwner()) and self:GetOwner():GetActiveSecondaryWeapon() == self then xpcall(self.Think,err,self) end
			else
				if self.ThinkOutside then xpcall(self.ThinkOutside,err,self) end
			end
		end)
	end
end

function SWEP:OnRemove()
	self:Event_Call("Remove")
end

function SWEP:Think()
	--if self.m_lastTick == TickCount() then return end
	--self.m_lastTick = TickCount()

	self:OnThink()

	self:Event_Call("Think")
end

function SWEP:ThinkOutside()
	--if self.m_lastTickOutSide == TickCount() then return end
	--self.m_lastTickOutSide = TickCount()

	self:OnThinkOutside()

	self:Event_Call("ThinkOutside")
end

SWEP.MoveMul = 1
SWEP.MoveMulEquip = 1

event.Add("Move","Homigrad Weapon Base",function(ply,mv)
	local wep = ply:GetActiveWeapon()

	local mul = wep.MoveMulEquip or 1

	for i,wep in pairs(ply:GetWeapons()) do
		mul = mul * (wep.MoveMul or 1)
	end

	local speed = mv:GetMaxSpeed() * mul
	mv:SetMaxSpeed(speed) 
	mv:SetMaxClientSpeed(speed)

	if wep.OnMove then wep:OnMove(ply,mv) end
end)

hook.Add("CreateMove","Homigrad Weapon Base",function(cmd)
	local wep = LocalPlayer():GetActiveWeapon()

	if wep.OnCreateMove then wep:OnCreateMove(cmd) end
end)

function SWEP:GetShootMatrix()
    local owner = self:GetOwner()
    if not owner then return self:GetPos(),self:GetAngles() end

    local pos,ang = owner:Eye()

    return pos,ang
end

function SWEP:CreateFakeSelfFromItem(item)
    self:Event_Call("CreateFakeSelfFromItem",item)
end

if SERVER then
    function SWEP:inv_NetData(item,pkg)
        self:Event_Call("inv_NetData",item,pkg)
    end
end