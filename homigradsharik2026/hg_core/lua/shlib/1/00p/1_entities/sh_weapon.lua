local SWEP,CLASS = oop.Reg("base_weapon",{"lib_event","lib_duplicate"})
if not SWEP then return end

CLASS.NonRegisterGMOD = true

SWEP.Base = "weapon_base"

SWEP.Primary = {}
SWEP.Secondary = {}

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:CanPrimaryAttack() return true end
function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end
function SWEP:Reload() end

function SWEP:Deploy() end
function SWEP:Holster() return true end

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"

local ActIndex = {
	[ "pistol" ]		= ACT_HL2MP_IDLE_PISTOL,
	[ "smg" ]			= ACT_HL2MP_IDLE_SMG1,
	[ "grenade" ]		= ACT_HL2MP_IDLE_GRENADE,
	[ "ar2" ]			= ACT_HL2MP_IDLE_AR2,
	[ "shotgun" ]		= ACT_HL2MP_IDLE_SHOTGUN,
	[ "rpg" ]			= ACT_HL2MP_IDLE_RPG,
	[ "physgun" ]		= ACT_HL2MP_IDLE_PHYSGUN,
	[ "crossbow" ]		= ACT_HL2MP_IDLE_CROSSBOW,
	[ "melee" ]			= ACT_HL2MP_IDLE_MELEE,
	[ "slam" ]			= ACT_HL2MP_IDLE_SLAM,
	[ "normal" ]		= ACT_HL2MP_IDLE,
	[ "fist" ]			= ACT_HL2MP_IDLE_FIST,
	[ "melee2" ]		= ACT_HL2MP_IDLE_MELEE2,
	[ "passive" ]		= ACT_HL2MP_IDLE_PASSIVE,
	[ "knife" ]			= ACT_HL2MP_IDLE_KNIFE,
	[ "duel" ]			= ACT_HL2MP_IDLE_DUEL,
	[ "camera" ]		= ACT_HL2MP_IDLE_CAMERA,
	[ "magic" ]			= ACT_HL2MP_IDLE_MAGIC,
	[ "revolver" ]		= ACT_HL2MP_IDLE_REVOLVER
}

local stupidRubat = {}

for t,index in pairs(ActIndex) do
	local tbl = {}
	tbl[ ACT_MP_STAND_IDLE ]					= index
	tbl[ ACT_MP_WALK ]						= index + 1
	tbl[ ACT_MP_RUN ]						= index + 2
	tbl[ ACT_MP_CROUCH_IDLE ]				= index + 3
	tbl[ ACT_MP_CROUCHWALK ]					= index + 4
	tbl[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= index + 5
	tbl[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= index + 5
	tbl[ ACT_MP_RELOAD_STAND ]				= index + 6
	tbl[ ACT_MP_RELOAD_CROUCH ]				= index + 6
	tbl[ ACT_MP_JUMP ]						= index + 7
	tbl[ ACT_RANGE_ATTACK1 ]					= index + 8
	tbl[ ACT_MP_SWIM ]						= index + 9


	if t == "normal" then
		tbl[ACT_MP_JUMP] = ACT_HL2MP_JUMP_SLAM
	end

	stupidRubat[index] = tbl
end

local string_lower = string.lower

function SWEP:SetWeaponHoldType(t)
	if self.ActivityHoldType == t then return end--shut the fuck up!

	if self:GetOwner():IsNPC() then
		self:SetupWeaponHoldTypeForAI(t)

		self.ActivityTranslate = self.ActivityTranslateAI
	else
		self.ActivityTranslate = stupidRubat[ActIndex[t]]
	end

	self.ActivityHoldType = t
end

local empty = {}--WTTTFF

function SWEP:TranslateActivity(act)
	return (self.ActivityTranslate or empty)[act] or -1
end

SWEP:Event_Add("Construct","register",function(class)
    local content = class[1]
    if content.NonRegisterGMOD or class[2].NonRegisterGMOD then return end

    weapons.Register(content,content.ClassName)

    timer.Simple(0,function()
        for i,ent in pairs(ents.FindByClass(class[1].ClassName)) do
            ent:Event_Call("Construct Object",class)
        end
    end)
end,10)

function SWEP:SetupDataTables()
	self:Event_Call("SetupDataTables")
end

function SWEP:InheritFromScriptedEnt(class)
    local content = oop.FirstInheritEnts[class]

    if not content then
        content = scripted_ents.Get(class)
        if not content then return false end
        
        oop.FirstInheritEnts[class] = content
    end

    util.tableLink(self,content)

    return true,content
end

function SWEP:Deploy(wep) return true end
function SWEP:Holster(wep) return true end

if CLIENT then
	function SWEP:GetViewModelPosition(Pos,Ang) return Pos,Ang end
	function SWEP:DrawWorldModel() self:DrawModel() end
	function SWEP:DrawWorldModelTranslucent() self:DrawModel() end
end