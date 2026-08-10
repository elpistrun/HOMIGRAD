local ENT = oop.Reg("ent_handcuffs",{"base_entity"})
if not ENT then return end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "handcuffs"

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/freeman/flexcuffs.mdl")
        self:SetBodygroup(1,1)

        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(true)
        self:SetUseType(SIMPLE_USE)
    
        //self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

        self:SetHealth(25)
    end
    
    function ENT:Kill()//tier_0_damage core
        sound.Emit(nil,"weapons/clipempty_pistol.wav",75,1,100,self:GetPos(),"0")

        self:Remove()
    end

    ENT.UsePreStop = true

    function ENT:Use(ply)
        if ply.fake or (self.delayUse or 0) > CurTime() then return end

        self.delayUse = CurTime() + math.Rand(0.1,0.2)

        ply:ViewPunch(Angle(1,0,0))
        
        sound.Emit(self:EntIndex(),"physics/metal/weapon_impact_hard" .. math.random(1,3) .. ".wav",75,1,100,nil,"0")

        self:SetHealth(self:Health() - 1)
        if self:Health() <= 0 then self:Kill() end
    end
else
    local white = Color(255,255,255)

    function ENT:HUDTarget(ply,k,w,h)
        white.a = 255 * k
    
        local v = self:Health()

        local text

        if v > 17 then
            text = L("handcuffs_hard")
        elseif v > 9 then
            text = L("handcuffs_medium")
        else
            text = L("handcuffs_easy")
        end

        draw.SimpleText(L("handcuffs_text",text),"H.18",w / 2,h / 2 - 50 * (1 - k),white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end    
end