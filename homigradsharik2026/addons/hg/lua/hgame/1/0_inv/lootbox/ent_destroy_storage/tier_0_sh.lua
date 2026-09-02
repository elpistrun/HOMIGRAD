local ENT = oop.Reg("ent_destroy_storage","base_entity",true)
if not ENT then return INCLUDE_BREAK end

ENT.Type = "anim"
ENT.Author = "0oa"
ENT.Spawnable = true
ENT.AdminSpawnable = false

ENT.PrintName = "lootbox_destroy"

ENT.WorldModel = "models/homigrad/creates/supply1.mdl"
ENT.WorldSkin = 2
ENT.WorldColor = Color(255,0,0)

ENT.Name = "lootbox_destroy"

local fallbackModel = "models/props_junk/wood_crate001a.mdl"
    if not util.IsValidModel(fallbackModel) then fallbackModel = "models/error.mdl" end
function ENT:Initialize()
    local model = self.WorldModel
    if not model or not util.IsValidModel(model) then
        model = fallbackModel
    end
    self:SetModel(model)
    self:SetSkin(self.WorldSkin or 0)
    if self.WorldColor then self:SetColor(self.WorldColor) end
    if SERVER then
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
    end
    self:Event_Call("Init")
    if self.OnInit then self:OnInit() end
end

if CLIENT then
    local white = Color(255,255,255)

    function ENT:HUDTarget(ply,k,w,h)
        white.a = 255 * k * (1 - inventoryGame.InterfaceAnim)

        draw.SimpleText(L(self:GetNWString("OverrideName",self.Name)),"HS.18",w / 2,h / 2 - 50 * (1 - k),white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end