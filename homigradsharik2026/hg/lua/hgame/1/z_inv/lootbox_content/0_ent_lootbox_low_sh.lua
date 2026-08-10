local ENT = oop.Reg("ent_lootbox_low","ent_lootbox_base",true)
if not ENT then return INCLUDE_BREAK end

ENT.Type = "anim"
ENT.Author = "0oa"
ENT.Spawnable = true
ENT.AdminSpawnable = false

ENT.PrintName = "LootBox Low"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/homigrad/creates/low.mdl"
ENT.WorldSkin = 3

ENT.Name = "lootbox_low"
ENT.w = 4
ENT.h = 2

ENT.InvRandomLoot = {
    "med_kit","med_band","med_band","med_band","med_band","med_painkiller",
    
    "wep_bow",

    "weapon_flashlight",

    "vest_paca",
    "helmet_un","helmet_achc_black",

    "backpack_forward",

    "weapon_handcuffs","weapon_transmitter","weapon_per4ik",

    "wep_food_juice","wep_food_water","wep_food_pepsi",

    "wep_food_canner","wep_food_cannerfish","wep_food_cannerburger",

    "wep_melee_dagger","wep_melee_bat_wood","wep_melee_bat_wood","wep_melee_6x5"
}

function ENT:GetRandomCount() return math.random(3,8) end