local ENT = oop.Reg("ent_lootbox_medical","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Medical"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/items/healthkit.mdl"

ENT.Name = "lootbox_medical"
ENT.w = 3
ENT.h = 2

local random = {
    "med_painkiller","med_kit","med_needle","med_kit"
}

function ENT:GetRandom() return random[math.random(1,#random)] end
function ENT:GetRandomCount() return math.random(6,9) end