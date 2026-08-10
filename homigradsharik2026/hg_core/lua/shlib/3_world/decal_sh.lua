if not HUtilDecalEx then HUtilDecalEx = util.DecalEx end

MAX_DECAL_ON_MODEL = 10
MAX_DECAL_ON_MODEL_RAGDOLL = 3

local filterEntity

local tr = {
    filter = function(ent)
        return ent == filterEntity
    end,
    ignoreworld = true,
    mask = MASK_ALL
}

local output = {}

tr.output = output

local matrixBone = Matrix()

function util.DecalEx(mat,ent,pos,normal,color,w,h)
    ent = IsValid(ent) and ent or game.GetWorld()
    
    local isWorld = ent == game.GetWorld()
    if not isWorld and not ent.m_decals then ent.m_decals = {} end

    decal = {mat,color,w or 1,h or 1}

    filterEntity = not isWorld and ent

    tr.start = pos + normal
    tr.endpos = pos - normal * 2

    util.TraceLine(tr)

    if not isWorld then
        local matrixDecal = Matrix()
        matrixDecal:SetTranslation(pos)
        matrixDecal:SetAngles(normal:Angle())

        if ent:GetBoneCount() == 0 then
            decal.bone = 0

            matrixBone:Identity()
            matrixBone:SetTranslation(ent:GetPos())
            matrixBone:SetAngles(ent:GetAngles())
        else
            local bone = math.max(ent:TranslatePhysBoneToBone(output.PhysicsBone) or 0,0)
            decal.bone = bone

            ent:CopyBoneMatrixHash(bone,matrixBone)
        end

        matrixBone:Invert()

        local matrixLocal = matrixBone * matrixDecal

        decal.localPos = matrixLocal:GetTranslation()
        decal.localAng = matrixLocal:GetAngles()
    else
        decal.localPos = pos
        decal.localAng = normal:Angle()

        if SERVER then temporary.Output("decal_world",decal[1]:GetName(),decal.localPos,decal.localAng,decal[2],decal[3],decal[4]) end
    end

    if not isWorld then
        ent.m_decals[#ent.m_decals+1] = decal

        if #ent.m_decals > (ent:IsRagdoll() and MAX_DECAL_ON_MODEL_RAGDOLL or MAX_DECAL_ON_MODEL) then
            table.remove(ent.m_decals,1)
        end
    end

    if CLIENT then
        pos:NonCrazy()
        normal:NonCrazy()
        normal:Normalize()
        
        HUtilDecalEx(mat,IsValid(ent) and ent or game.GetWorld(),pos,normal,color,w,h)
    else
        util.DecalExServer(ent,decal)
    end
end

local ENTITY = FindMetaTable("Entity")
if not HEntityRemoveAllDecals then HEntityRemoveAllDecals = ENTITY.RemoveAllDecals end

function ENTITY:RemoveAllDecals()
    local m_decals = self.m_decals

    if m_decals then
        for i = 1,#m_decals do m_decals[i] = nil end
    end

    HEntityRemoveAllDecals(self)
end

local MatrixLocal = Matrix()
local MatrixBone = Matrix()

local dirDefault = Vector(1,0,0)
local VecSet,AngSet,DirSet = Vector(),Angle(),Vector()

local ColorSet = Color(255,255,255)

function ENTITY:SetupDecals(decals)
    --[[timer.Simple(TickInterval() * 2,function()
        if not IsValid(self) then return end--sosi?
        
        for i = 1,#decals do
            local decal = decals[i]

            if not decal.localPos then continue end--wtf

            MatrixLocal:Identity()
            MatrixLocal:SetTranslation(decal.localPos)
            MatrixLocal:SetAngles(decal.localAng)

            if self:GetBoneCount() == 0 then
                MatrixBone:Identity()
                MatrixBone:SetTranslation(self:GetPos())
                MatrixBone:SetAngles(self:GetAngles())
            else
                self:CopyBoneMatrixHash(decal.bone,MatrixBone)
            end

            MatrixBone:Mul(MatrixLocal)
            MatrixBone:SetXYZ_PYR(VecSet,AngSet)

            DirSet:Set(dirDefault)
            DirSet:Rotate(AngSet)

            VecSet:NonCrazy()
            DirSet:NonCrazy()

            ColorSet.r = decal[2].r or 255
            ColorSet.g = decal[2].g or 255
            ColorSet.b = decal[2].b or 255

            HUtilDecalEx(decal[1],self,VecSet,DirSet,ColorSet,decal[3] or 1,decal[4] or 1)
        end

        self.m_decals = decalse
    end)]]--
end

local VecSet = Vector()
local vec_dir = Vector(1,0,0)

temporary.Create("decal_world",
function(data)
    net.WriteString(data[1])
    net.WriteVector(data[2])
    net.WriteAngle(data[3])
    net.WriteColor(data[4])
    net.WriteFloat(data[5])
    net.WriteFloat(data[6])
end,
function(data)
    data[1] = net.ReadString()
    data[2] = net.ReadVector()
    data[3] = net.ReadAngle()
    data[4] = net.ReadColor()
    data[5] = net.ReadFloat()
    data[6] = net.ReadFloat()
end,
function(data)
    util.DecalEx(Material(data[1]),nil,data[2],Vector(1,0,0):Rotate(data[3]),data[4],data[5],data[6])
end)