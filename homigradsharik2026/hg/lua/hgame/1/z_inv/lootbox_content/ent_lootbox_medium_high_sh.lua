local ENT = oop.Reg("ent_lootbox_medium_high","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Meduim High"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/kali/props/cases/hard case c.mdl"
ENT.WorldSkin = 1

ENT.Name = "lootbox_medium_high"
ENT.w = 2
ENT.h = 1

local random = {
    "wep_saiga12k","wep_asval","wep_vss",

    "ent_jack_gmod_ezammo"
}

function ENT:GetRandom() return random[math.random(1,#random)] end
function ENT:GetRandomCount() return 2 end