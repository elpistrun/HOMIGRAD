local ENT = oop.Reg("ent_lootbox_low_food","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Small Food"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/homigrad/creates/low.mdl"
ENT.WorldSkin = 1

ENT.Name = "lootbox_low_food"
ENT.w = 4
ENT.h = 1

function ENT:GetRandom() return "" end
function ENT:GetRandomCount() return 0 end
