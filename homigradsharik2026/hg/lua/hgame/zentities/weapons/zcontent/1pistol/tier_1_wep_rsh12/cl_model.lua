local SWEP = oop.Get("wep_rsh12")
if not SWEP then return end

function SWEP:SetupModelPost(wm)
    if not IsValid(self) or not wm.isWorldModel or wm:GetPos():Distance(EyePos()) > 256 then return end

    local sequenceObject = self:GetSequenceData()

    if sequenceObject and sequenceObject.SetupModelPost then
        sequenceObject:SetupModelPost(wm)
    else
        for i = 1,self:GetAnimIterationMax() do
            wm:SetBodygroup(self.wmData.chamberBodygroup + (i - 1),self:GetChamberCount() >= i and 1 or 0)
        end
    end
end

function SWEP:OnChamberChange() end