local ENT = oop.Get("custom_networker")
if not ENT then return end

function ENT:OnChangePVSVar(name,old,new)
    self:CallProxyPVSVar(name,old,new)
end

ENT:Event_Add("Sync","pvsNWVar",function(self,pkg)
    if pkg.pvsVars then
        for name,value in pairs(pkg.pvsVars) do
            self:SetPVSVar(name,value)
        end
    end

    if not pkg.pvsValueName then return end

    self:SetPVSVar(pkg.pvsValueName,pkg.pvsValue)
end,-100)