local ENT = oop.Reg("ent_lootbox_armor","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Armor"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/homigrad/creates/medium.mdl"
ENT.WorldSkin = 1

ENT.Name = "lootbox_armor"
ENT.w = 3
ENT.h = 2

local random = {
    "vest_korundvm","vest_thor_crv","vest_slick_b",

    "updump_thunderbolt",

    "backpack_gr99_t30_b","backpack_dragon_egg_mk2",

    "mask_balistic",

    "headset_m32",

    "helmet_ops_fast_black","helmet_galvion_applique",

    "dump_plate_carrier"
}

function ENT:GetRandom() return random[math.random(1,#random)] end
function ENT:GetRandomCount() return 6 end