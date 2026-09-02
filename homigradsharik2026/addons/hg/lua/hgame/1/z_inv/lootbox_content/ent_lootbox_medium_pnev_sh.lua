local ENT = oop.Reg("ent_lootbox_medium_pnev","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Meduim Pnev"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/kali/props/cases/hard case c.mdl"
ENT.WorldSkin = 2

ENT.Name = "lootbox_medium_pnev"
ENT.w = 2
ENT.h = 1

local random = {
    "wep_vector9",
    "wep_glock_17","wep_glock_18c",

    "ent_jack_gmod_ezammo"
}

function ENT:GetRandom() return random[math.random(1,#random)] end
function ENT:GetRandomCount() return 2 end