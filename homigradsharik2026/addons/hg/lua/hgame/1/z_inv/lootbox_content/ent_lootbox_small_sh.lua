local ENT = oop.Reg("ent_lootbox_small","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Small"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/homigrad/creates/supply1.mdl"
ENT.WorldSkin = 0

ENT.Name = "lootbox_small"
ENT.w = 3
ENT.h = 1

local random = {
    "weapon_flashlight","weapon_flashlight",
    "med_band","med_band","med_band",
    
    "weapon_handcuffs","weapon_per4ik",

    "wep_food_juice","wep_food_water","wep_food_pepsi"
}

function ENT:GetRandom() return random[math.random(1,#random)] end
function ENT:GetRandomCount() return math.random(2,3) end