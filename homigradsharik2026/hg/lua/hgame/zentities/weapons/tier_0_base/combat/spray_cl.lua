local SWEP = oop.Get("hg_wep")
if not SWEP then return end

SWEP.SprayAng = Angle(1,0,0)
SWEP.SprayAngHorizontal = {-0.1,0.1}

SWEP:Event_Add("Init","Spray",function(self)
    self.sprayAngSlow = Angle()
    self.sprayAngSlowSet = Angle()
end)

local hg_dev_spray_disable

cvars.CreateDevOption("hg_dev_spray_disable","0",function(value)
    hg_dev_spray_disable = tonumber(value or 0) > 0
end,0,1)

function SWEP:ApplySpray()
    if hg_dev_spray_disable then return end
    
    local owner = self:GetOwner()

    local spray = -self.SprayAng

    local mul = 1

    if owner:InVehicle() then
        mul = 3
    end

    local horizontalSpray = math.Rand(self.SprayAngHorizontal[1],self.SprayAngHorizontal[2])

    spray[2] = spray[2] + horizontalSpray
    
    local sprayAngSlowSet = self.sprayAngSlowSet
    sprayAngSlowSet:Add(spray / 60)
    sprayAngSlowSet[2] = sprayAngSlowSet[2] + horizontalSpray / 12
    
    event.Call("Spray",LocalPlayer(),spray * mul)
end

SWEP:Event_Add("Think","Spray",function(self)
    if not self:IsLocal() then return end

    local sprayAngSlow,sprayAngSlowSet = self.sprayAngSlow,self.sprayAngSlowSet

    if sprayAngSlowSet:Length() == 0 or sprayAngSlowSet:Length() == 0 then return end

    sprayAngSlowSet:LerpFT(0.05)
    sprayAngSlow:LerpFT(0.3,sprayAngSlowSet)

    event.Call("Spray",LocalPlayer(),sprayAngSlow)
end)

event.Add("Spray","Default",function(ply,spray)
    if ply:InVehicle() then return end

    ply:SetEyeAngles(ply:EyeAngles() + spray)
end)