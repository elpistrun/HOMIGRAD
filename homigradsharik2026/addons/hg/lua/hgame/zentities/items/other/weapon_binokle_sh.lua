local SWEP = oop.Reg("weapon_binokle","hg_wep_base")
if not SWEP then return end

SWEP.PrintName 				= L("weapon_binokle")
SWEP.Author 				= "Homigrad"
SWEP.Category 				= L("weapon_category_item")

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Slot					= 5
SWEP.SlotPos				= 2
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP:TableLink("wmFastData",{model = "models/maxofs2d/camera.mdl"})

SWEP.ViewBack = true
SWEP.ForceSlot1 = true

SWEP.dwsPos = Vector(0,-28,-2.5)
SWEP.dwiSelectPos = Vector(0,-70,-3)
SWEP.dwsAng = Angle(0,90,0)

SWEP.vbw = true
SWEP.vbwPistol = true
SWEP.vbwPos = Vector(9,-2,-1)
SWEP.vbwAng = Angle(0,0,0)
SWEP.vbwModelScale = Vector(0.8,0.8,0.8)

SWEP.InvMoveSnd = InvMoveSndPlastic

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

SWEP:Event_Add("Think","Main",function(self)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if SERVER then self:SetNWBool("Focus",owner:KeyDown(IN_ATTACK2)) end

    local isFocus = self:GetNWBool("Focus")

    local clientMoment = CLIENT and (owner ~= LocalPlayer() or GetViewEntity() ~= LocalPlayer())

    self:SetStandType(isFocus and "camera" or "slam")
end)

if SERVER then return end

local value = 0
event.Add("PreCalcView","Binokle",function(ply,view)
    local wep = ply:GetActiveWeapon()
    wep = IsValid(wep) and wep:GetClass() == "weapon_binokle" and ply:KeyDown(IN_ATTACK2)
    value = LerpFT(0.5,value,wep and 1 or 0) 
    view.fov = view.fov * (1 - value * 0.8)
end)

local white = Color(255,255,255)

hook.Add("HUDPaint","binokle",function()
    local have

    for i,wep in pairs(LocalPlayer():GetWeapons()) do
        if wep:GetClass() == "weapon_binokle" then have = true break end
    end

    if not have then return end

    local count = 36
    local step = 360 / count

    for i = 0,count - 1 do
        local dir = Vector(8000,0,0)
        dir:Rotate(Angle(0,i * step,0))

        local pos = LocalPlayer():GetPos() + dir
        pos = pos:ToScreen()

        local max = ScrW() / 4
        local a = math.max(max - math.abs(ScrW() / 2 - pos.x),0) / max

        a = math.max(a - 0.4,0) / 0.6
        white.a = a * 255

        draw.SimpleText(i * step,"DefaultFixedDropShadow",pos.x,25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end)

function SWEP:DrawWorldModel()
    local owner = self:GetOwner()
    if IsValid(owner) and self:GetNWBool("Focus") then return end

    self:DrawModel()
end

function SWEP:DrawFromPlayer() end