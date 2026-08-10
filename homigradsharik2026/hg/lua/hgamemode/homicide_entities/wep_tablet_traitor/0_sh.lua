local SWEP = oop.Reg("wep_tablet_traitor",{"hg_wep_base","tpik_animate"},true)
if not SWEP then return INCLUDE_BREAK end

SWEP:TableLink("wmData",{model = "models/homigrad/weapons/v_tablet.mdl",vec = Vector(-7,0,0),ang = Angle(-16,0,0),center = {Vector(0,0,0),Angle(0,0,0)}})

SWEP.WorldModel = "models/homigrad/weapons/w_tablet.mdl"
SWEP.Category = L("weapon_category_item")
SWEP.Spawnable = true
SWEP.HoldType = "slam"

SWEP.TPIK_TwistOffsetLeft = 0
SWEP.TPIK_TwistOffsetRight = 90

function SWEP:OnDeploy()
    self:PlayAnimation("deploy")
end

function SWEP:OnHolster()
    self:PlayAnimation("holster")
end

SWEP.CorrectiveDropInfo = {
    bone = "weapon",

    ang = Angle(0,0,0),
    vec = Vector(0,0,0)
}

function SWEP:OnThink()
    if not self.stateHandling then
        if not self:IsSequencePlaying("idle") then self:PlayAnimation("idle") end
    end
end

function SWEP:SetupBones_OnChange(tpikMatrix,Pos,Ang,wmVector,wmAngle)
    local k = self:GetStandAnimK()

    Ang[1] = Lerp(k,-66 * math.min(k,0.3) / 0.7,Ang[1])
end