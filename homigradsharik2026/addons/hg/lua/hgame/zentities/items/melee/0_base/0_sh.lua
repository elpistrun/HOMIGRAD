local SWEP,CLASS = oop.Reg("wep_melee_base",{"tpik_animate"},true)
if not SWEP then return INCLUDE_BREAK end

CLASS.NonRegisterGMOD = true

SWEP.Spawnable = true
SWEP.Category = L("weapon_category_melee")

SWEP.Slot = 1
SWEP.SlotPos = 2

SWEP.SupportFake = true
SWEP.SupportCustomAttack = true
SWEP.itemType = "other"

SWEP.Primary.Delay = 0.5
SWEP.Primary.Force = 100
SWEP.Primary.Damage = 10

SWEP.Secondary.Delay = 0.5
SWEP.Secondary.Force = 100
SWEP.Secondary.Damage = 10

SWEP.CorrectiveDropInfo = {
    bone = "bone_mele",
    vec = Vector(0,0,0),
    ang = Angle(0,0,0)
}

SWEP.WorldModelContentLink_wmDropData = true
SWEP.SecondaryWeaponDontFollowHand = true
SWEP.weaponLimitType = "melee"
SWEP.AlwaysDeterminateUse = true -- Make stuck weapons always targetable

-- Make weapons on the ground targetable by HUD
function SWEP:DeterminateUse(ply,trace)
    -- Only targetable if not owned by anyone (on the ground/stuck in wall)
    return not IsValid(self:GetOwner())
end

SWEP:Event_Add("inv_NetData","isBlooded",function(self,item,pkg)
    pkg.isBlooded = IsValid(self) and self:GetPVSVar("IsBlooded") or (item.data and item.data.isBlooded)
end)

SWEP:Event_Add("CreateFakeSelfFromItem","isBlooded",function(self,item)--это многое говорить о нашем обществе...
    self:SetPVSVar("IsBlooded",item.data and item.data.isBlooded)
end)

local graph = {
    {0,0},
    {0.3,1},
    {0.7,1},
    {1,0}
}

function SWEP:OnMove(ply,mv)
    local sequenceObject = self.sequenceObject

    if sequenceObject and sequenceObject.movementMul then
        local lerp
        
        if sequenceObject.endless then
            lerp = Lerp(math.EvalGraph(math.min(sequenceObject:GetCycle(),0.7),sequenceObject.movementMulGraph or graph),1,sequenceObject.movementMul)
        else
            lerp = Lerp(math.EvalGraph(sequenceObject:GetCycle(),sequenceObject.movementMulGraph or graph),1,sequenceObject.movementMul)
        end

        mv:SetSideSpeed(mv:GetSideSpeed() * lerp)
        mv:SetForwardSpeed(mv:GetForwardSpeed() * lerp)
    end
end

function SWEP:OnDeploy()
    self:PlayDeployAnimation()
end

function SWEP:OnHolster()
    self:PlayHolsterAnimation()
end

SWEP.TPIKLerpWhitelist = {
    ["bone_mele"] = true
}

local delay = 2

function SWEP:SetupBones_OnChange(tpikMatrix,Pos,Ang,wmVector,wmAngle)
    local animK = (self:GetPVSVar("VibrationMetal",0) - CurTime() + delay) / delay

    if animK > 0 then
        local k = 1 * animK
        Pos:Add(VectorRand(-k,k))
    end
end

SWEP.ParseAnimationFlags.throw = {
    flags = {
        dontShake = true,
    },
    list = {
        "attack_throw_start"
    }
}

-- Pickup stuck weapons from the ground
if SERVER then
    function SWEP:Use(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        if not ply:Alive() or ply:InFake() then return end
        
        -- Check if player already has this weapon
        if self:GetOwner() == ply then return end
        
        -- Check if player already has this weapon class
        if ply:HasWeapon(self:GetClass()) then return end
        
        -- Get player's inventory
        local inv = ply.invPlayer
        if not IsValid(inv) then return end
        
        -- Find empty slot
        local slot = inventoryGame.ServerEmptySlot(inv)
        if not slot then return end
        
        -- Insert weapon into inventory
        inventoryGame.ServerInsertItem({spawnname = self:GetClass(), data = {}, ent = self}, slot)
        
        -- Remove the world entity
        self:Remove()
    end
else
    local white = Color(255,255,255)
    
    function SWEP:HUDTarget(ent,k,w,h)
        -- Only show pickup prompt if weapon is on the ground (no owner)
        if IsValid(self:GetOwner()) then return end
        
        HUDTargetRenderText("pickup",k,white)
        return true
    end
end