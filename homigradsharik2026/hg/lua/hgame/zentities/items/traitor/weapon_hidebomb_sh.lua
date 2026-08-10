local SWEP = oop.Reg("weapon_hidebomb","hg_wep_base")
if not SWEP then return end

SWEP.PrintName 				= L("weapon_hidebomb")
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= L("weapon_hidebomb_desc")
SWEP.Category 				= L("weapon_category_traitor")

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

SWEP.Slot					= 4
SWEP.SlotPos				= 2
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP:TableLink("wmFastData",{model = "models/props_junk/cardboard_box004a.mdl",scale = Vector(0.5,0.5,0.5),vec = Vector(5,-3,0)})

SWEP.dwsPos = Vector(0,30,0.3)
SWEP.dwsAng = Angle(0,25,30)

SWEP.itemType = "other"

SWEP.EnableTransformModel = true

SWEP.HoldType = "normal"

SWEP.HolsterTime = 0
SWEP.DeployTime = 0

function SWEP:Reload() end
function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end
function SWEP:DrawFromPlayer() end

if SERVER then
    local function Bomb(ent,att)
        ent:RemoveCallOnRemove("hidebomb")

        Explosive("explosive_hidebomb",ent:GetPos() + ent:OBBCenter(),ent,att)
    end

    SWEP:Event_Add("Init","Normal",function(self)
        self:SetHoldType("normal")
        self:SetNWBool("HaveBomb",true)
    end)

    --local cyka = {}

    function SWEP:PrimaryAttack()
        if IsValid(self.bomb) then return end

        local owner = self:GetOwner()

        local tr = {}
        tr.start = owner:GetAttachment(owner:LookupAttachment("eyes")).Pos
        local dir = Vector(1,0,0)
        dir:Rotate(owner:EyeAngles())
        tr.endpos = tr.start + dir * 75
        tr.filter = owner

        local traceResult = util.TraceLine(tr)
        local ent = traceResult.Entity

        if not IsValid(ent) then
            ent = ents.Create("prop_physics")
            ent:SetModel("models/props_junk/cardboard_box004a.mdl")

            ent:SetPos(traceResult.HitPos)
            ent:Spawn()
            ent.doNotDropLoot = true
        end

        self.bomb = ent
        ent.parentBomb = self

        ent:CallOnRemove("hidebomb",Bomb,owner)
        sound.Emit(ent:EntIndex(),"buttons/button24.wav",60,0.7,50)

        self:SetNWBool("HaveBomb",false)
    end

    function SWEP:SecondaryAttack()
        if not IsValid(self.bomb) then return end

        local ent = self.bomb

        sound.Emit(ent:EntIndex(),"snds_jack_gmod/plunger.ogg",75,1)

        local att = self:GetOwner()
		timer.Simple(math.Rand(0.3,0.4),function() Bomb(ent,att) end)

        self.bomb = nil
        self:Remove()
    end

    SWEP:Duplicate("Bomb",
    function(self,data)
        data.bomb = IsValid(self.bomb) and self.bomb:EntIndex()
    end,function(self,data)
        self.bomb = data.bomb and Entity(data.bomb)
    end)
else
    function SWEP:ShouldRender() return self:GetNWBool("HaveBomb") end
    
    function SWEP:DrawHUD()
        local owner = self.Owner
        local tr = {}
        tr.start = owner:GetAttachment(owner:LookupAttachment("eyes")).Pos
        local dir = Vector(1,0,0)
        dir:Rotate(owner:EyeAngles())
        tr.endpos = tr.start + dir * 75
        tr.filter = owner

        local traceResult = util.TraceLine(tr)
        local ent = traceResult.Entity

        if not IsValid(ent) then
            local hit = traceResult.Hit and 1 or 0
            local frac = traceResult.Fraction
            surface.SetDrawColor(Color(255, 255, 255, 255 * hit))
            draw.NoTexture()
            Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, 5 / frac, 32)
        else
            local frac = traceResult.Fraction
            surface.SetDrawColor(Color(255, 255, 255, 255))
            draw.NoTexture()
            Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, 5 / frac, 32)
            draw.DrawText(L("weapon_hidebomb_claim") .. " " .. tostring((util.GetSurfaceIndex(ent:GetBoneSurfaceProp(0)) == 3 or util.GetSurfaceIndex(ent:GetBoneSurfaceProp(0)) == 66) and L("weapon_hidebomb_metal") or ""), "TargetID", traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y - 40, color_white, TEXT_ALIGN_CENTER )
        end
    end
end