local MatrixSet = Matrix()
local MatrixLocal = Matrix()

local VecSet,AngSet = Vector(),Angle()

function PlayerBackWeapons_Get(ent,wep)
    local mat
    
    if wep.vbwIsHolster then
        ent:CopyBoneMatrixHash(ent:LookupBone("ValveBiped.Bip01_Pelvis"),MatrixSet)
        if MatrixSet:IsZero() then return end
    else
        ent:CopyBoneMatrixHash(ent:LookupBone("ValveBiped.Bip01_Spine2"),MatrixSet)
        if MatrixSet:IsZero() then return end
    end

    MatrixLocal:Identity()
    MatrixLocal:SetTranslation(wep.vbwPos)
    if wep.vbwAng then MatrixLocal:SetAngles(wep.vbwAng) end

    MatrixSet:Mul(MatrixLocal)
    
    MatrixSet:SetXYZ_PYR(VecSet,AngSet)
    
    return VecSet,AngSet
end