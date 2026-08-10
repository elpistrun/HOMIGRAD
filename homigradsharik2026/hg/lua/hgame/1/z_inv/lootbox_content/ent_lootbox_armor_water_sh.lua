local ENT = oop.Reg("ent_lootbox_armor_water","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Armor Water"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/props_c17/lockers001a.mdl"

ENT.Name = "lootbox_armor_water"
ENT.w = 2
ENT.h = 3

local random = {
    "ent_jack_gmod_ezarmor_ballon_o2","ent_jack_gmod_ezarmor_respirator",
}

function ENT:GetRandom() return random[math.random(1,#random)] end
function ENT:GetRandomCount() return 2 * 3 end