local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

SWEP:Event_Add("Init","Cooldown",function(self)
    net.CooldownInit(self)
end)

SWEP.SetCooldown = net.SetCooldown

SWEP.GetCooldownStart = net.GetCooldownStart
SWEP.GetCooldownDelay = net.GetCooldownDelay
SWEP.GetCooldownAnimK = net.GetCooldownAnimK

SWEP.IsCooldown = net.IsCooldown