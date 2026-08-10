function net.CooldownInit(self)
    self.cooldownStart = self.cooldownStart or {}
    self.cooldownDelay = self.cooldownDelay or {}
end

function net.SetCooldown(self,name,delay)
    if not self.cooldownStart then net.CooldownInit(self) end
    
    self.cooldownStart[name] = UnPredictedCurTime()
    self.cooldownDelay[name] = delay
end

function net.GetCooldownStart(self,name)
    return self.cooldownStart[name] or 0
end

function net.GetCooldownDelay(self,name)
    return self.cooldownDelay[name] or 0
end

local max = math.max

function net.GetCooldownAnimK(self,name)
    local delay = self.cooldownDelay[name]
    
    return max((self.cooldownStart[name] or 1) - delay) / delay
end

if CLIENT then
    function net.IsCooldown(self,name)
        return (self.cooldownStart[name] or 0) + (self.cooldownDelay[name] or 0) > UnPredictedCurTime()
    end

    local PLAYER = FindMetaTable("Player")

    PLAYER.SetCooldown = net.SetCooldown
    PLAYER.IsCooldown = net.IsCooldown
end

event.Add("Player Spawn","Cooldowm",function(ply)
    ply.cooldownStart = nil
    ply.cooldownDelay = nil
    
    net.CooldownInit(ply)
end)