local SWEP = oop.Get("tpik_animate")
if not SWEP then return end

SWEP.SupportFake = true

SWEP:Event_Add("SetupDataTables","TPIK",function(self,list)
    self:NetworkVar("Bool","EnableTPIKLeftHand")
    self:NetworkVar("Bool","EnableTPIKRightHand")

    self:SetEnableTPIKLeftHand(self.TPIK_UseLeftHand)
    self:SetEnableTPIKRightHand(self.TPIK_UseRightHand)
end)

SWEP.TPIK_UseLeftHand = true
SWEP.TPIK_UseRightHand = true

function SWEP:TPIK_CanUseLeftHand()
    if not self.TPIK_UseLeftHand then return false end
    
    local sequenceObject = self.sequenceObject

    local owner = self:GetOwner()
    if sequenceObject and sequenceObject.freeLHand then return sequenceObject:GetMark("freeLHand",sequenceObject.freeLHand) end

    if owner:InVehicle() then
        if sequenceObject and sequenceObject.grabLeftHand and not sequenceObject:GetMark("grabLeftHand",sequenceObject.grabLeftHand) then return true end

        return self.IsScope and self:IsScope() or false
    end

    if not self:GetEnableTPIKLeftHand() then return false end--выключается сервером

    return true
end

function SWEP:TPIK_CanUseRightHand()
    if not self.TPIK_UseRightHand then return false end
    if not self:GetEnableTPIKRightHand() then return false end

    return true
end