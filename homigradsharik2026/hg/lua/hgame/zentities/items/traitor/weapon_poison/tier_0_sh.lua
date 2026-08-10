local SWEP = oop.Reg("weapon_poison","hg_wep_base",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = L("weapon_poison")

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = L("weapon_category_traitor")

SWEP:TableLink("wmFastData",{model = "models/weapons/w_models/w_syringe_proj.mdl"})
function SWEP:DrawFromPlayer() end

SWEP.ShouldDropOnDie = false
SWEP.Charges = 3

SWEP.HoldType = "normal"

SWEP.EnableTransformModel = true

SWEP.wmVector = Vector(4,2,-3)
SWEP.wmAngle = Angle(0,-90,0)

SWEP.dwsPos = Vector(-1,-23,-1)
SWEP.dwiSelectPos = Vector(-1,-200,-1)
SWEP.dwsAng = Angle(45,180,0)

hook.Add("RenderScreenspaceEffects","Poison",function()
	local ply = LocalPlayer()
	if not ply:Alive() then return end

	if hook.Run("Should Draw Screenspace") == false then return end

    local k = ply:GetNWFloat("PoisonValue",0)
    k = math.Clamp(math.max(k - 0.25,0) * 5,0,1)

    if k <= 0 then return end

    k = k / 3

    DrawMotionBlur(0.4 - k / 10,0.1 + k,0.15)
end)

function SWEP:DoBones() end

if SERVER then return end

local color_red = Color(255,0,0)

function SWEP:DrawHUD()
    local tr = LocalPlayer():EyeTrace(PlayerDisUse)
    if not tr then return end

    local ent = tr.Entity
    if not IsValid(ent) then return end

    local pos = (ent:GetPos():Add(ent:OBBCenter():Rotate(ent:GetAngles()))):ToScreen()

    draw.SimpleText("ОТРАВИТЬ ПРЕДМЕТ","HS.18",pos.x,pos.y,color_red,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end