local ENT = oop.Reg("ent_lootbox_machine","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Machine"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/homigrad/creates/big.mdl"
ENT.WorldMaterial = "phoenix_storms/gear"

ENT.Name = "lootbox_machine"
ENT.w = 1
ENT.h = 1

local random = {
    "glide_repair","ent_jack_gmod_ezammo"
}

function ENT:GetRandom() return random[math.random(1,#random)] end
function ENT:GetRandomCount() return 1 end
