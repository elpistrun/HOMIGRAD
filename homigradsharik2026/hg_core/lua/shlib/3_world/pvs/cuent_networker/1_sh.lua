local ENT = oop.Get("custom_networker")
if not ENT then return end

ENT.InitPVS = pvsAuto.InitPVS
ENT.ProxyPVSVar = pvsAuto.ProxyPVSVar
ENT.CallProxyPVSVar = pvsAuto.CallProxyPVSVar
ENT.SetPVSVar = pvsAuto.SetPVSVar
ENT.GetPVSVar = pvsAuto.GetPVSVar

ENT:Event_Add("Create","InitPVS",function(self)
    self:InitPVS()
end)

if CLIENT then
    function ENT:IsValidAnyNetworker() return IsValid(self.sNetworker) or IsValid(self.cNetworker) end

    function ENT:SetPos(pos)
        self.pos:Set(pos)
        if IsValid(self.sNetworker) then self.sNetworker:SetPos(pos) end
        if IsValid(self.cNetworker) then self.cNetworker:SetPos(pos) end
    end

    function ENT:GetPos() return self.pos end

    function ENT:SetAngles(ang)
        self.ang:Set(ang)
        if IsValid(self.sNetworker) then self.sNetworker:SetAngles(ang) end
        if IsValid(self.cNetworker) then self.cNetworker:SetAngles(ang) end
    end

    function ENT:GetAngles() return self.ang end
else
    function ENT:IsValidAnyNetworker() return IsValid(self.networker) end

    function ENT:SetPos(pos)
        self.pos:Set(pos)
        if IsValid(self.sNetworker) then self.sNetworker:SetPos(pos) end
    end

    function ENT:GetPos() return self.pos end

    function ENT:SetAngles(ang)
        self.ang:Set(ang)
        if IsValid(self.sNetworker) then self.sNetworker:SetAngles(ang) end
    end

    function ENT:GetAngles() return self.ang end
end