local ENT = oop.Reg("serverside_model",{"base_entity"})
if not ENT then return end

function ENT:Initialize()
    self:SetNoDraw(true)
    self:DrawShadow(false)

    self:PhysicsDestroy()
    self:SetSolid(SOLID_NONE)
    self:SetNotSolid(true)
    self:SetMoveType(MOVETYPE_NONE)
end

function ENT:Draw() self:DrawModel() end