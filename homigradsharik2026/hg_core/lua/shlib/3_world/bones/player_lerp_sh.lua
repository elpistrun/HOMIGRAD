local clamp = math.Clamp

local matrixRespect,matrixRespectInverse = Matrix(),Matrix()

function PlayersBones_MatrixRespect(ply)
    if IsFirstFrame(ply,"r_fMatrixRespect") then
        local Pos,Ang = ply:Eye()

        matrixRespect:SetAngles(Ang)
        matrixRespect:SetTranslation(Pos)

        matrixRespectInverse:SetAngles(Ang)
        matrixRespectInverse:SetTranslation(Pos)
        matrixRespectInverse:Invert()
        
        ply.matrixRespect = matrixRespect
        ply.matrixRespectInverse = matrixRespectInverse
    end

    return ply.matrixRespect,ply.matrixRespectInverse
end

local FrameTime = FrameTime
local min = math.min

local pairs = pairs--ну это бред

local VMatrixSet = Matrix()

function TPIKLerp_DoSolveEntity(ent,matrixRespect,matrixRespectInverse,reset,interpolationValue)
    if not ent.bones_matrix_lerp then
        ent.bones_matrix_lerp = {}
        ent.bones_matrix_lerp_set = {}
    end

    local bones_matrix_lerp = ent.bones_matrix_lerp
    local bones_matrix_lerp_set = ent.bones_matrix_lerp_set
    
    local bones_matrix = ent.bones_matrix

    interpolationValue = interpolationValue or TPIK_DEFAULT_INTERPOLATION

    if interpolationValue != 1 then interpolationValue = math.Clamp(interpolationValue * GetFT(),0,1) end

    if reset then
        for boneID in pairs(bones_matrix_lerp_set) do
            bones_matrix_lerp_set[boneID]:Zero()
        end

        for boneID,matrix in pairs(bones_matrix) do
            VMatrixSet:Set(matrixRespectInverse)
            VMatrixSet:Mul(matrix)

            if bones_matrix_lerp_set[boneID] then
                bones_matrix_lerp_set[boneID]:Set(VMatrixSet)
            else
                bones_matrix_lerp_set[boneID] = VMatrixSet:Clone()
            end

            if not bones_matrix_lerp[boneID] then
                bones_matrix_lerp[boneID] = bones_matrix_lerp_set[boneID]:Clone()
            end
        end
    end

    if interpolationValue == 1 then
        for boneID,matrix in pairs(bones_matrix_lerp) do
            local matrixSet = bones_matrix_lerp_set[boneID]
            if not matrixSet or matrixSet:IsZero() then continue end

            VMatrixSet:Set(matrixRespect)
            VMatrixSet:Mul(matrixSet)

            if not bones_matrix[boneID] then
                bones_matrix[boneID] = VMatrixSet:Clone()
            else
                bones_matrix[boneID]:Set(VMatrixSet)
            end
        end
    else
        for boneID,matrix in pairs(bones_matrix_lerp) do
            local matrixSet = bones_matrix_lerp_set[boneID]
            if not matrixSet or matrixSet:IsZero() then continue end

            matrix:Lerp(interpolationValue,matrixSet)

            VMatrixSet:Set(matrixRespect)
            VMatrixSet:Mul(matrix)

            if not bones_matrix[boneID] then
                bones_matrix[boneID] = VMatrixSet:Clone()
            else
                bones_matrix[boneID]:Set(VMatrixSet)
            end
        end
    end
end