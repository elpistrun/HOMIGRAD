local ENT,CLASS = oop.Reg("ent_lootbox_base","base_entity",true)
if not ENT then return INCLUDE_BREAK end

CLASS.NonRegisterGMOD = true

ENT.Type = "anim"
ENT.Author = "0oa"
ENT.Spawnable = true
ENT.AdminSpawnable = false

ENT.PrintName = "LootBox Base"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/homigrad/creates/low.mdl"
ENT.WorldSkin = 3

ENT.Name = "lootbox_low"
ENT.w = 4
ENT.h = 1

function ENT:GetRandomCount() return math.random(2,4) end

local fallbackModel = "models/props_junk/wood_crate001a.mdl"

function ENT:Initialize()
    local model = self.WorldModel

    if not model or not util.IsValidModel(model) then
        ErrorNoHalt("[HG] Invalid lootbox model for " .. tostring(self:GetClass()) .. ": " .. tostring(model) .. "; using " .. fallbackModel .. "\n")
        model = fallbackModel
    end

    self:SetModel(model)
    self:SetSkin(self.WorldSkin or 0)

    if self.WorldMaterial then self:SetMaterial(self.WorldMaterial) end
    if self.WorldScale then self:SetModelScale(self.WorldScale) end
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

--[[function ENT:Draw()
    self:DrawModel()
    render.DrawWireframeBox(self:GetPos(),self:GetAngles(),self.WorldPhysicsBox[1],self.WorldPhysicsBox[2])
end]]--
