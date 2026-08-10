local ENT = oop.Reg("ent_lootbox_granade","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Granade"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/homigrad/creates/supply2.mdl"
ENT.WorldSkin = 1

ENT.Name = "lootbox_granade"
ENT.w = 2
ENT.h = 2

local random = {
    "wep_gnade_f1",
    "wep_gnade_rgd5",
    "wep_gnade_f1",
    "wep_gnade_rgd5",
    "wep_gnade_f1",
    "wep_gnade_rgd5",
    "wep_gnade_f1",
    "wep_gnade_rgd5",
    "wep_gnade_molotov"
}

function ENT:GetRandom() return random[math.random(1,#random)] end
function ENT:GetRandomCount() return math.random(3,4) end