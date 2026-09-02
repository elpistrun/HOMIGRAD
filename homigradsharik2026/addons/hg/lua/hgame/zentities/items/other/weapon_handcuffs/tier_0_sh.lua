local SWEP = oop.Reg("weapon_handcuffs","hg_wep_base",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = L("weapon_handcuffs")
SWEP.Author = "0oa"
SWEP.Instructions = L("weapon_handcuffs_desc")
SWEP.Category = L("weapon_category_item")

SWEP.Slot = 5
SWEP.SlotPos = 3
SWEP.Spawnable = true

SWEP:TableLink("wmFastData",{model = "models/freeman/flexcuffs.mdl",vec = Vector(4,-2,-0.6),ang = Angle(0,0,-45),bodygroups = {[1] = 1}})

SWEP.dwsPos = Vector(1,-40,1)
SWEP.dwiSelectPos = Vector(0,-120,1)
SWEP.dwsAng = Angle(0,90,-90 - 45)

SWEP.dwmForward = 3.5
SWEP.dwmRight = 1
SWEP.dwmUp = -1

SWEP.itemType = "other"
SWEP.InvCount = 4
SWEP.InvCountIgnoreLimit = true

SWEP.invNoDrawClip = true

SWEP.EnableTransformModel = true

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

if SERVER then
    util.AddNetworkString("cuff")
else
    net.Receive("cuff",function(len)
        local self = net.ReadEntity()
        self.CuffPly = net.ReadEntity()
        self.CuffTime = net.ReadFloat()
    end)
end

local function GetPly(tr)
    local ent = tr.Entity
    if not IsValid(ent) then return end

    local ent = (IsValid(ent:GetController()) and ent:GetController()) or ent
    
    if ent:GetNWBool("Cuffs",false) then return end
    if not ent:IsPlayer() then return ent:GetClass() == "prop_ragdoll" and ent end
    if not ent:GetNWBool("fake") or ent:HasGodMode() then return end

    return ent
end

local cuffTime = 2

if SERVER then
    event.Add("Player Spawn","Cuffs",function(ply)
        ply:SetNWBool("Cuffs",false)
    end)

    event.Add("PlayerSwitchWeapon","!Cuffs",function(ply,old,new)
        if ply:GetNWBool("Cuffs",false) then return false end
    end,-10)

    function SWEP:PrimaryAttack()
        if IsValid(self.CuffPly) then return end

        local owner = self:GetOwner()

        local tr = owner:EyeTrace(75)
        if not tr then return end

        local ply = GetPly(tr)

        if ply then
            owner:EmitSound("weapons/pinpull.wav")

            self.CuffPly = ply
            self.CuffTime = CurTime()

            self:SendCuff()
        end
    end
    
    SWEP.SecondaryAttack = SWEP.PrimaryAttack
    
    function SWEP:SendCuff()
        net.Start("cuff")
        net.WriteEntity(self)
        net.WriteEntity(self.CuffPly or Entity(-1))
        net.WriteFloat(self.CuffTime)
        net.Send(self:GetOwner())
    end

    function SWEP:OnThink()
        local cuffPly = self.CuffPly
        if not IsValid(cuffPly) then return end

        local owner = self:GetOwner()

        local tr = owner:EyeTrace(75)
        if not tr then return end
        
        local ply = GetPly(tr)

        if ply ~= cuffPly then
            self.CuffPly = nil
            
            self:SendCuff()

            return
        end

        if self.CuffTime + cuffTime <= CurTime() then
            if ply:IsPlayer() then ply = ply.fakeEnt end

            self:Cuff(ply)
        end
    end
end

if SERVER then return end

function SWEP:DrawHUD()
    local tr = self:GetOwner():EyeTrace(75)
    if not tr then return end
    
    local ply = GetPly(tr)

    local hit = tr.Hit and 1 or 0

    local pos = tr.HitPos:ToScreen()
    local x,y = pos.x,pos.y
    
    local frac = tr.Fraction * 100

    if ply then
        surface.SetDrawColor(Color(255, 255, 255, 255))
        draw.NoTexture()
        Circle(x, y, 5 / frac, 32)

        draw.DrawText(L("handcuffs_text_target"),"TargetID",x,y - 40,color_white,TEXT_ALIGN_CENTER)

        if IsValid(self.CuffPly) then
            local anim_pos = 1 - math.Clamp((self.CuffTime + cuffTime - CurTime()) / cuffTime,0,1)

            surface.DrawRect(x - 50,y + 50,anim_pos * 100,25)
        end
    else
        surface.SetDrawColor(Color(255, 255, 255, 255 * hit))
        draw.NoTexture()
        Circle(x, y, 5 / frac, 32)
    end
end

function SWEP:CreateWorldModelPost(wm,tag,typeDraw,depth)
    wm:SetBodygroup(1,1)
end