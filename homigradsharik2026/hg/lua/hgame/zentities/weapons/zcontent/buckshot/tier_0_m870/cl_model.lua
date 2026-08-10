local SWEP = oop.Get("wep_m870")
if not SWEP then return end

function SWEP:SetupModelPost(wm)
    if not IsValid(self) or not wm.isWorldModel or wm:GetPos():Distance(EyePos()) > 256 then return end

    local sequenceObject = self:GetSequenceData()

    if sequenceObject and sequenceObject.SetupModelPost then
        sequenceObject:SetupModelPost(wm)
    end
end