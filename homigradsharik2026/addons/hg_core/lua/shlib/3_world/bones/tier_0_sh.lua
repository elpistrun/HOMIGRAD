--!!МАКСИМАЛЬНАЯ ОПТИМИЗАЦИЯ!!! УРОВЕНЬ ПОТУЖНОСТИ 100000%%%%!! https://music.youtube.com/watch?v=1x2P0UMfE2s

local ENTITY = FindMetaTable("Entity")

if not HGetBoneMatrix then HGetBoneMatrix = ENTITY.GetBoneMatrix end
local HGetBoneMatrix = HGetBoneMatrix

if not HSetBoneMatrix then HSetBoneMatrix = ENTITY.SetBoneMatrix end
local HSetBoneMatrix = HSetBoneMatrix

if not HCopyBoneMatrix then HCopyBoneMatrix = ENTITY.CopyBoneMatrix end
local HCopyBoneMatrix = HCopyBoneMatrix

function ENTITY:SetBoneMatrix(boneID,matrix)--лутче не юзать
    if self.bones_matrix then
        self.bones_matrix[boneID] = matrix
    else
        HSetBoneMatrix(self,boneID,matrix)
    end
end

function ENTITY:SetBoneMatrixNow(bone,matrix)
    if not isnumber(bone) or bone < 0 or bone >= self:GetBoneCount() then return false end
    if not matrix or self:GetBoneName(bone) == "__INVALIDBONE__" then return false end
    if not HGetBoneMatrix(self,bone) then return false end

    if self.GetBoneFlags and BONE_USED_BY_ANYTHING then
        local flags = self:GetBoneFlags(bone)
        if flags and bit.band(flags,BONE_USED_BY_ANYTHING) == 0 then return false end
    end

    HSetBoneMatrix(self,bone,matrix)
    return true
end

local matrix_zero = Matrix()

function ENTITY:GetBoneMatrix(boneID)
    if not boneID then return matrix_zero end--wtf

    local matrixs = self.bones_matrix
    
    if matrixs then
        local bones_matrix_frametime = self.bones_matrix_frametime

        local matrix = matrixs[boneID]

        if not matrix then
            matrix = Matrix()

            matrixs[boneID] = matrix
        end

        if (bones_matrix_frametime[boneID] or 0) < FRAME_NUMBER then
            bones_matrix_frametime[boneID] = FRAME_NUMBER

            HCopyBoneMatrix(self,boneID,matrix)
        end

        return matrix
    else
        return HGetBoneMatrix(self,boneID)
    end
end

local GetBoneMatrix = ENTITY.GetBoneMatrix
local CopyBoneMatrix = ENTITY.CopyBoneMatrix

function ENTITY:CopyBoneMatrixHash(boneID,matrix)
    if not boneID then return end--wtf

    if self.bones_matrix then
        matrix:Set(GetBoneMatrix(self,boneID))
    else
        CopyBoneMatrix(self,boneID,matrix)
    end
end

function ENTITY:GetBoneMatrixNow(boneID)
    return HGetBoneMatrix(self,boneID)
end

function ENTITY:PasteBoneMatrix(boneID,matrix)
    if not boneID then return end--wtf
    
    if self.bones_matrix then
        GetBoneMatrix(self,boneID):Set(matrix)
    else
        self:SetBoneMatrix(boneID,matrix)
    end
end

local cached_children = {}

local BonesManager_RecursiveGetChildren
BonesManager_RecursiveGetChildren = function(ent,bone,bones,endbone)
    local children = ent:GetChildBones(bone)
    if #children == 0 then return end

    local id

    for i = 1,#children do
        id = children[i]
        if id == endbone then continue end

        BonesManager_RecursiveGetChildren(ent,id,bones,endbone)
        table.insert(bones,id)
    end
end
_G.BonesManager_RecursiveGetChildren = BonesManager_RecursiveGetChildren

local GetModel = ENTITY.GetModel

function BonesManager_GetChildren(ent,bone,endbone)
    endBone = endBone or ""

    local chache = cached_children[GetModel(ent)]
    if chache and chache[bone] and chache[bone][endBone] then return chache[bone][endBone] end

    local bones = {}

    BonesManager_RecursiveGetChildren(ent,bone,bones,endbone)

    local model = GetModel(ent)
    
    cached_children[model] = cached_children[model] or {}
    cached_children[model][bone] = cached_children[model][bone] or {}
    cached_children[model][bone][endBone] = bones

    return bones
end

local VMatrixInverse = Matrix()
local VMatrixTranslate = Matrix()
local VMatrixSet = Matrix()

local Set = VMatrix_Set
local Mul = VMatrix_Mul
local Invert = VMatrix_Invert

local GetBoneMatrix = ENTITY.GetBoneMatrix

function BonesManager_ApplyMatrix(ent,bone,new_matrix,endbone)
    local matrix = GetBoneMatrix(ent,bone)
    if not matrix then return end
    
    local children = BonesManager_GetChildren(ent,bone,endbone)
    local max = #children

    if max == 0 then return end--ez

    VMatrixInverse:Set(matrix)
    VMatrixInverse:Invert()

    VMatrixTranslate:Set(new_matrix)
    VMatrixTranslate:Mul(VMatrixInverse)

    local bones_matrix = ent.bones_matrix

    local mat = bones_matrix[bone]

    if mat then
        mat:Set(new_matrix)
    else
        mat = new_matrix
        bones_matrix[bone]:Set(mat)
    end

    for i = 1,max do
        local bone = children[i]

        local mat = GetBoneMatrix(ent,bone)
        if not mat then continue end

        VMatrixSet:Set(VMatrixTranslate)
        VMatrixSet:Mul(mat)

        mat:Set(VMatrixSet)
    end
end

function BonesManager_Init(ent)
    if not ent.bones_matrix then ent.bones_matrix = {} end
    if not ent.bones_matrix_frametime then ent.bones_matrix_frametime = {} end
    if not ent.bones_matrix_render_bone then ent.bones_matrix_render_bone = {} end
    if not ent.bones_matrix_render then ent.bones_matrix_render = {} end
end

function BonesManager_Clear(ent)
    local bones_matrix = ent.bones_matrix
    local bones_matrix_frametime = ent.bones_matrix_frametime

    for boneID,time in pairs(bones_matrix_frametime) do bones_matrix_frametime[boneID] = 0 end
    for boneID,matrix in pairs(bones_matrix) do matrix:Zero() end
end

function BonesManager_SetupRender(ent)
    if not IsValid(ent) then return end
    
    local bones_matrix_render_bone,bones_matrix_render = ent.bones_matrix_render_bone,ent.bones_matrix_render
    if not ent.bones_matrix_render_bone then return end
    
    local iteration = 0

    for bone,matrix in pairs(ent.bones_matrix) do
        if ent:GetBoneName(bone) == "__INVALIDBONE__" or matrix:IsZero() then continue end
        
        iteration = iteration + 1
        
        bones_matrix_render_bone[iteration] = bone
        bones_matrix_render[iteration] = matrix
    end

    ent.bones_matrix_render_max = iteration
end

local SetupBones = FindMetaTable("Entity").SetupBones

function BonesManager_SetupMatrix(ent,tag,link)
    local bones_matrix_render_bone = ent.bones_matrix_render_bone
    local bones_matrix_render = ent.bones_matrix_render

    local max = ent.bones_matrix_render_max

    for i = 1,max do
        --if ent:GetBoneName(bone) == "__INVALIDBONE__" then continue end

        HSetBoneMatrix(ent,bones_matrix_render_bone[i],bones_matrix_render[i])
    end

    if ent.r_headPop then ent:SetHeadMatrixScale(true) end
    if ent.r_onlyHands then ent:SetOnlyHandsMatrixScale() end
end
