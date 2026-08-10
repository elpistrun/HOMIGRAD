local ENT = oop.RegConnect("fake_ragdoll")
if not ENT then return end

function ENT:HUDTarget(_,k,w,h)
    return false
end

function ENT:OnNWTable_Weapons(tbl)
    self:SetWeapons(tbl)
end