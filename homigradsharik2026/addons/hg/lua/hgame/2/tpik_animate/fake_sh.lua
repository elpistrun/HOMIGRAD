local SWEP = oop.Get("tpik_animate")
if not SWEP then return end

function SWEP:IsGrabLeftHand()
    local sequenceObject = self:GetSequenceData()
    if sequenceObject and sequenceObject.grabLeftHand then return sequenceObject:GetMark("grabLeftHand") end

    return self:TPIK_CanUseLeftHand()
end

function SWEP:IsGrabRightHand()
    local sequenceObject = self:GetSequenceData()
    if sequenceObject and sequenceObject.grabRightHand then return sequenceObject:GetMark("grabRightHand") end

    return self:TPIK_CanUseRightHand()
end

function SWEP:GetDummy() return self:GetNWEntity("Fake",self) end

if SERVER then return end

function SWEP:CanDrawFromPlayer(ply,tag,link,flags)
    if link.InFakeDeath and link:InFakeDeath() then return false end

    return true
end