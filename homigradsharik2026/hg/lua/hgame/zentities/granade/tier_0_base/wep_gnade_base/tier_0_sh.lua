local SWEP,CLASS = oop.Reg("wep_gnade_base","hg_wep_base",true)
if not SWEP then return INCLUDE_BREAK end

CLASS.NonRegisterGMOD = true

SWEP.PrintName = "База Гаранаты"
SWEP.Author = "Homigrad"
SWEP.Purpose = ""
SWEP.Instructions = ""

SWEP.Slot = 4
SWEP.SlotPos = 0
SWEP.Spawnable = true

SWEP.Category = L("weapon_category_granades")

SWEP:TableLink("wmFastData",{model = "models/pwb/weapons/w_f1.mdl"})

SWEP.itemType = "granade"

SWEP.Granade = ""

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.dwsPos = Vector(0,100,0)
SWEP.dwiSelectPos = Vector(0,100,0)

SWEP.HoldType = "normal"
SWEP:Event_Add("Init","ArmThink",function(self)
    if not self.NeedArmThink then return end

    local path = tostring(self) .. "Think"
    
    timer.Create(path,0.1,0,function()
        if not IsValid(self) then timer.Remove(path) return end
        self:StepWorld()
    end)
end)

function SWEP:PrimaryAttack()
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
end

function SWEP:SecondaryAttack()
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
end

function SWEP:StepWorld()
    if self:GetNWBool("Arm") then self:ArmThink() end
end

SWEP:Event_Add("Think","Main",function(self)
    local owner = self:GetOwner()
    local hold = self:GetNWInt("Hold")

    if hold == 0 then return end

    if hold == 1 then
        self:SetStandType("melee")
        owner:SetAnimation(PLAYER_ATTACK1)
        
        if SERVER then
            if not owner:KeyDown(IN_ATTACK) then
                self:Throw(750)

                return
            end

            if owner:KeyDown(IN_ATTACK2) then
                if not self.ignoreAttack2 then
                    self.ignoreAttack1 = true self:SetNWInt("Hold",2)
                end
            else self.ignoreAttack2 = nil end
        end
    end

    if hold == 2 then
        self:SetStandType("knife")
        owner:SetAnimation(PLAYER_ATTACK1)

        if SERVER then
            if not owner:KeyDown(IN_ATTACK2) then
                self:Throw(250)

                return
            end

            if owner:KeyDown(IN_ATTACK) then
                if not self.ignoreAttack1 then
                    self.ignoreAttack2 = true self:SetNWInt("Hold",1)
                end
            else self.ignoreAttack1 = nil end
        end
    end

    if SERVER and self.NeedArmThink then self:StepWorld() end
end)

function SWEP:ArmThink() end

function SWEP:SetFakeWep()
    if self:GetNWInt("Hold") ~= 0 then
        local owner = self:GetOwner()

        self:Throw(0)
    else
        return false
    end
end

function SWEP:CanHUDTarget() return not self:GetNWBool("Arm") end

SWEP.InvMoveSnd = InvMoveSndGranade
SWEP.InvCount = 3