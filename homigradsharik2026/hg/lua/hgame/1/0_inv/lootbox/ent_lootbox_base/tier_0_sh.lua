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