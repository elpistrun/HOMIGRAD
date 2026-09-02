local ENT = oop.Reg("ent_lootbox_rifle_high","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Rifle High"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/kali/props/cases/rifle case b.mdl"
ENT.WorldPhysicsBox = {Vector(-5,-22,-2),Vector(9,22,2)}

ENT.Name = "lootbox_high"
ENT.w = 2
ENT.h = 2

ENT.InvRandomLoot = {
    "wep_dvl10","wep_m60","wep_m32a1","wep_rsh12","wep_m32a1",

    "vest_hexgrid","helmet_devtac","wep_saiga12fa","headset_tagila_mask","wep_melee_hultafors","wep_melee_labris"
}

function ENT:GetRandomCount() return 4 end