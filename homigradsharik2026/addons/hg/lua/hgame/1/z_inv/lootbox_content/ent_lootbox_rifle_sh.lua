local ENT = oop.Reg("ent_lootbox_rifle","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Rifle"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/homigrad/creates/weapon.mdl"
ENT.WorldSkin = 1

ENT.Name = "lootbox_high"
ENT.w = 1
ENT.h = 1

ENT.InvRandomLoot = {
    "wep_ak74","wep_ar15","wep_m870"
}

function ENT:GetRandomCount() return 2 end