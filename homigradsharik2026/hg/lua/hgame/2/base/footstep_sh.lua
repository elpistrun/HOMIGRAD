weapons.SoundsSpinRifle = {
    list = {},
    volume = 0.1
}
for i = 1,9 do weapons.SoundsSpinRifle.list[i] = "weapons/spin/rifle_" .. i .. ".ogg" end

weapons.SoundsSpinPistol = {
    list = {},
    volume = 0.1
}
for i = 1,4 do weapons.SoundsSpinPistol.list[i] = "weapons/spin/pistol_" .. i .. ".ogg" end

weapons.SoundsSpinGeneric = {
    list = {},
    volume = 0.1
}
for i = 1,6 do weapons.SoundsSpinGeneric.list[i] = "weapons/spin/generic_" .. i .. ".ogg" end

weapons.SoundsSpinHeavy = {
    list = {},
    volume = 0.2
}
for i = 1,5 do weapons.SoundsSpinHeavy.list[i] = "weapons/eft/pkm/pk_gun_flip_" .. i .. ".ogg" end

event.Add("Footstep","Sound Weapon",function(ply,footSide,surfaceName,pos)
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    local FootstepSounds = wep.FootstepSounds
    if not FootstepSounds then return end

    wep:EmitLocalSound(FootstepSounds.list[math.random(1,#FootstepSounds.list)],70,FootstepSounds.volume * 0.3,100 + (footSide and -3 or 0))
end)

event.Add("Jump","Sound Weapon",function(ply)
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    local FootstepSounds = wep.FootstepSounds
    if not FootstepSounds then return end

    wep:EmitLocalSound(FootstepSounds.list[math.random(1,#FootstepSounds.list)],70,FootstepSounds.volume,100)
end)

event.Add("Landing","Sound Weapon",function(ply,inWater,onFloat,speed,surfaceName,pos)
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    local FootstepSounds = wep.FootstepSounds
    if not FootstepSounds then return end

    wep:EmitLocalSound(FootstepSounds.list[math.random(1,#FootstepSounds.list)],70,FootstepSounds.volume,100)
end)

weapons.SoundsAimRifle = {
    list = {},
    volume = 0.1
}
for i = 1,18 do weapons.SoundsAimRifle.list[i] = "weapons/ads/aim_on_rifle_" .. i .. ".wav" end

weapons.SoundsAimPistol = {
    list = {},
    volume = 0.1
}
for i = 1,8 do weapons.SoundsAimPistol.list[i] = "weapons/ads/aim_on_pistol_" .. i .. ".wav" end

weapons.SoundsAimPistolRifle = {
    list = {},
    volume = 0.1
}
for i = 1,11 do weapons.SoundsAimPistolRifle.list[i] = "weapons/ads/aim_on_smg_" .. i .. ".wav" end

weapons.SoundsAimMachineGun = {
    list = {},
    volume = 0.1
}
for i = 1,12 do weapons.SoundsAimMachineGun.list[i] = "weapons/ads/aim_on_machinegun_" .. i .. ".wav" end