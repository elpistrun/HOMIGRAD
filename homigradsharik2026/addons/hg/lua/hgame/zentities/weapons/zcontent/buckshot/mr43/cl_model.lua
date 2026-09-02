local SWEP = oop.Get("wep_mr43")
if not SWEP then return end

function SWEP:SetupModelPost(wm)
    if not IsValid(self) or not wm.isWorldModel or wm:GetPos():Distance(EyePos()) > 256 then return end

    local sequenceObject = self:GetSequenceData()

    if sequenceObject and sequenceObject.SetupModelPost then
        sequenceObject:SetupModelPost(wm)
    else
        wm:SetBodygroup(4,self.chamber1 and 1 or 0)
        wm:SetBodygroup(5,self.chamber2 and 1 or 0)
    end
end