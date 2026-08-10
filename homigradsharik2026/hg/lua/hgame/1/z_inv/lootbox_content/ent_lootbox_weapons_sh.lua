local ENT = oop.Reg("ent_lootbox_weapons","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Weapons"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/homigrad/creates/big.mdl"
ENT.WorldSkin = 3

ENT.Name = "lootbox_weapons"
ENT.w = 2
ENT.h = 2

local random = {
    "wep_mp5","wep_mp9","wep_p90",
    
    "wep_m870","wep_ak74","wep_ar15","wep_saiga12k","wep_vpo215","wep_asval","wep_vss",

    "ent_jack_gmod_ezammo"
}

function ENT:GetRandom() return random[math.random(1,#random)] end
function ENT:GetRandomCount() return 4 end