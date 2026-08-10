local SWEP = oop.Get("wep_m60")
if not SWEP then return end

function SWEP:InitWorldModelMagazine(wm,tag,typeDraw)

end

local list = {
    "patron_001",
    "patron_002",
    "patron_003",
    "patron_004",
    "patron_005",
    "patron_006",
    "patron_007",
    "patron_008",
    "patron_009",
    "patron_010",
    "patron_011",
    "patron_012",
}

local vecFull = Vector(1,1,1)
local vecZero = Vector(0 / 0,0 / 0,0 / 0)

function SWEP:SetupModelPost(wm)
    if IsValid(self) and wm.isWorldModel then
        if wm:GetPos():Distance(RenderView.origin) > RenderLOD0_Distance then return end

        local sequenceObject = self:GetSequenceData("start")
        
        if sequenceObject then
            if sequenceObject.drawAmmo then
                local should = sequenceObject:GetMark("drawAmmo")

                for i = 1,#list do
                    local bone = wm:LookupBone(list[i])

                    wm:ManipulateBoneScale(bone,should and vecFull or vecZero)
                end
            end
        else
            for i = 1,#list do
                local bone = wm:LookupBone(list[i])

                wm:ManipulateBoneScale(bone,self:Clip1() >= i and vecFull or vecZero)
            end
        end

        if sequenceObject and sequenceObject.magazineDraw then
            if sequenceObject:GetMark("magazineDraw") then
                wm:SetBodygroup(2,1)
                wm:SetBodygroup(3,1)
                wm:SetBodygroup(11,1)
            else
                wm:SetBodygroup(2,0)
                wm:SetBodygroup(3,0)
                wm:SetBodygroup(11,0)
            end
        else
            if self:GetMagazineItem() then
                wm:SetBodygroup(2,1)
                wm:SetBodygroup(3,1)
                wm:SetBodygroup(11,1)
            else
                wm:SetBodygroup(2,0)
                wm:SetBodygroup(3,0)
                wm:SetBodygroup(11,0)
            end
        end
    else
        if self:GetMagazineItem() then
            wm:SetBodygroup(2,1)
            wm:SetBodygroup(3,1)
            wm:SetBodygroup(11,1)
        else
            wm:SetBodygroup(2,0)
            wm:SetBodygroup(3,0)
            wm:SetBodygroup(11,0)
        end
    end
end