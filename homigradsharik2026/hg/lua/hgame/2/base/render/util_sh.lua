local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

SWEP.wmBone = "ValveBiped.Bip01_R_Hand"

function SWEP:Transform_GetFromRagdoll(ent,wmVector,wmAngle)
    if not IsValid(ent) or not wmVector or not wmAngle then return self:GetPos(),self:GetAngles() end

    local bone = ent:LookupBone(self.wmBone)
    if not bone then return self:GetPos(),self:GetAngles() end
    
    local matrix = ent:GetBoneMatrix(bone)
    if not matrix then return end--;c;;c;c;c

    local Pos,Ang = matrix:GetTranslation(),matrix:GetAngles()
    if not Pos then return end

    Pos,Ang = LocalToWorld(wmVector,wmAngle,Pos,Ang)
    
    return Pos,Ang
end

function SWEP:Transform_GetFromEye(ent,wmVector,wmAngle,SetAng)
    if not IsValid(ent) or not ent.Eye then return self:GetPos(),self:GetAngles() end

    local Pos,Ang = ent:Eye()
    if not Pos then return end

    Ang = SetAng or Ang

    wmVector = wmVector or self.wmVector:Clone()
    wmAngle = wmAngle or self.wmAngle:Clone()

    wmAngle:Lerp(math.abs(Ang[1] / 90),Angle())

    Pos,Ang = LocalToWorld(wmVector,wmAngle,Pos,Ang)

    return Pos,Ang
end

function SWEP:GetWorldModelName() return self.WorldModel end
function SWEP:GetWorldModel(data)--notag, is world, is not hand model
    local owner = self:GetOwner()

    data = data or self.curretWMData
    self.curretWMData = data
    if not data then return end

    local depth = data.depth

    if not IsValid(owner) then
        local wm,isCreate = self:InitWorldModel(nil,true,depth,data)
        self.wm = wm

        return wm,isCreate
    else
        if depth == nil then
            if not owner:IsTPIKAviable() then depth = 0 end
        end

        local wm,isCreate = self:InitWorldModel(nil,true,depth,data)
        self.wm = wm

        return wm,isCreate
    end

    return self.wm
end

SWEP.WorldModelCenter = {Vector(0,0,0),Angle(0,0,0)}

local MatrixWorld,MatrixLocal = Matrix(), Matrix()

function SWEP:Transform_GetCenter(Pos,Ang,data)
    data = data or self.wmData
    if not data.center then return Pos,Ang end--wtf
    
    local localPos,localAng = data.center[1],data.center[2]

    MatrixLocal:Identity()
    MatrixLocal:SetTranslation(data.center[1])
    MatrixLocal:SetAngles(data.center[2])

    MatrixWorld:Identity()
    MatrixWorld:SetTranslation(Pos)
    MatrixWorld:SetAngles(Ang)

    MatrixWorld:Mul(MatrixLocal)

    MatrixWorld:SetXYZ_PYR(Pos,Ang)
    
    return Pos,Ang
end