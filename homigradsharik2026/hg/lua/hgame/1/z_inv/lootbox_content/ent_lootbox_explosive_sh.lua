local ENT = oop.Reg("ent_lootbox_explosive","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Explosive"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/homigrad/creates/big.mdl"
ENT.WorldSkin = 1

ENT.Name = "lootbox_explosive"
ENT.w = 2
ENT.h = 2

local random = {
    "ent_jack_gmod_eztimebomb"
}

function ENT:GetRandom() return random[math.random(1,#random)] end
function ENT:GetRandomCount() return 4 end