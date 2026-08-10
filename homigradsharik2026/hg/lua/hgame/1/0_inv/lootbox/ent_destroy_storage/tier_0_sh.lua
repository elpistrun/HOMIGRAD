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

if CLIENT then
    local white = Color(255,255,255)

    function ENT:HUDTarget(ply,k,w,h)
        white.a = 255 * k * (1 - inventoryGame.InterfaceAnim)

        draw.SimpleText(L(self:GetNWString("OverrideName",self.Name)),"HS.18",w / 2,h / 2 - 50 * (1 - k),white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end