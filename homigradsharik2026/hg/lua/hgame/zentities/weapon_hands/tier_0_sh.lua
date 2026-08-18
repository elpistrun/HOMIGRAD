local SWEP = oop.Reg("weapon_hands",{"hg_wep_base","tpik_animate"},true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = L("weapon_hands")
SWEP.Author = "Homigrad"
SWEP.Category = L("weapon_category_item")
SWEP.Spawnable = true

SWEP.HoldType = "normal"
SWEP.HoldTypeCombat = "rpg"

SWEP.Slot = 0
SWEP.SlotPos = -100

SWEP.IconOverride = "homigrad/weapon_icon/hand.png"
SWEP.IconWeaponSelection = Material("homigrad/weapon_icon/hand.png","smooth")

SWEP:TableLink("wmData",{
    model = "models/weapons/v_punch.mdl",

    vec = Vector(-4,6,4),
    ang = Angle(10,-20,-20)
})

SWEP:Event_Remove("Holster","Snd")
SWEP:Event_Remove("Deploy","Snd")

SWEP.SupportCustomAttack = true

SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false

SWEP.Primary.Delay = 0.3
SWEP.Secondary.Delay = 0.375

function SWEP:GetShootMatrix() return self:GetOwner():Eye() end

function SWEP:PlayDeployAnimation()
    -- Hands used to deploy with FightState=false, while the left punch and
    -- stance explicitly require combat mode. Nothing ever enabled it.
    if not self:GetFightState() then
        self:SetFightState(true)
    else
        self:PlayAnimation({name = "deploy",start = 0})
        if SERVER then self:SyncAnimation() end
    end
end

function SWEP:PlayHolsterAnimation()

end

function SWEP:OnHolster()
    if self:GetFightState() then
        self:SetFightState(false)
        self:PlayAnimation("holster")
        if SERVER then self:SyncAnimation() end
    end

    self:SetFightBlockState(false)
end

function SWEP:Render(wm) wm:DrawModel() end

if CLIENT then
    function SWEP:DrawHUD()
        if self:GetFightState() or not GetViewEntity().EyeTrace then return end
        
        local tr = GetViewEntity():EyeTrace(PlayerDisUse)
        if not tr then return end

        local ent = tr.Entity
        if not IsValid(ent) or not ent:IsPlayer() then return end

        local Size = 1 - math.min(tr.StartPos:Distance(tr.HitPos) / PlayerDisUse,1)
        local col = ent:GetPlayerColor():ToColor()

        col.a = 255 * math.min(Size * 2,1)

        local pos = tr.HitPos:ToScreen()

        draw.DrawText(ent:Name(),"HS.45",pos.x,pos.y + ScrH() * 0.065,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local select

    event.Add("Think","Always Pickup Hand",function()
        if select then return end
        
        local ply = LocalPlayer()
        
        if not ply:Alive() then return end

        local wep = ply:GetWeapon("weapon_hands")
        if not IsValid(wep) then return end
    
        local activeWep = ply:GetActiveWeapon()

        if not IsValid(activeWep) then
            select = true

            timer.Simple(TickInterval(),function()
                select = nil

                if IsValid(wep) then input.SelectWeapon(wep) end
            end)
        end
    end)
end

function SWEP:DrawFromPlayer() end
