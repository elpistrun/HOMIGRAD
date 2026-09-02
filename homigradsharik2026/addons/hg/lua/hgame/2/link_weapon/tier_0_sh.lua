local ENT = oop.Reg("link_weapon",{"base_entity"},true)
if not ENT then return INCLUDE_BREAK end

ENT.cantPickup = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity","_Link")
end

function ENT:SetLink(ent)
    self:Set_Link(ent)
    ent:SetNWEntity("Fake",ent)
end

function ENT:GetLink() return self:Get_Link() end

function ENT:Initialize()
    local link = self:GetLink()

    self:SetModel(link:GetWorldModelName())

    if SERVER then
        if link.CreatePhysics then
            link:CreatePhysics(self)
        elseif link:GetSolid() == SOLID_VPHYSICS then
            self:PhysicsInit(SOLID_VPHYSICS)
        end

        self:GetCollisionGroup(COLLISION_GROUP_DEBRIS)
        self:GetPhysicsObject():SetMass(3)
    end

    self:SetNotSolid(true)

    self.RenderOverride = function(_,flags) self:RenderOverrideDraw(flags) end
end

function ENT:RenderOverrideDraw(flags)
    local link = self:GetLink()
    if not IsValid(link) then return end--WTF

    local dis = self:GetPos():Distance(EyePos())
    if dis > RenderLOD3_Distance then return end
    
    local data = dis <= RenderLOD0_Distance and link.wmData.model and link.wmData or link.wmVeryFastData

    local wm = link:GetWorldModel()
    if not IsValid(wm) then return end

    if IsFirstFrame(wm,"SetupBonesChildrenTime") then
        local Pos,Ang = link:Transform_GetCenter(self:GetPos(),self:GetAngles(),data)

        wm:SetSequence(0)
        wm:SetCycle(1)
        wm:SetPos(Pos)
        wm:SetAngles(Ang)
        link:SetupModel(wm)
    end

    link:Render(wm)
end