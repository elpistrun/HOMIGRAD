local ENT = oop.Reg("ent_lootbox_small_ammo","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Small Ammo"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/homigrad/creates/supply1.mdl"
ENT.WorldSkin = 1

ENT.Name = "lootbox_small_ammo"
ENT.w = 3
ENT.h = 1

function ENT:GetRandom() return "" end
function ENT:GetRandomCount() return 0 end
