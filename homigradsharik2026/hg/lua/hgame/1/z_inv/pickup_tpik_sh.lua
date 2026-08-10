HandModelConfig = HandModelConfig or {}
HandModelConfig["models/props_phx/misc/soccerball.mdl"] = {
    forceThrow = 10000,
    handPunchForce = 10000,
    footKickForce = 14000,
    handPunchFunction = function(self,ent)
        sound.Emit(ent:EntIndex(),"physics/rubber/rubber_tire_impact_hard" .. math.random(1,3) .. ".wav",75,1,100,ent:GetPos())
    end--идея хуйня, без лагкомпресии это бесмыслено
}

PickupTPIK_Lenght = 25

local filterEntity

local tr = {
    mask = MASK_ALL,
    filter = function(ent)
        return ent == filterEntity
    end
}

local MatrixLocalLeftHand = Matrix()
MatrixLocalLeftHand:SetAngles(Angle(0,-90,0))

local mat = Matrix()

local function setLeft(ply,tpikMatrix,HitPos,Normal,HitNormal,origin)
    HitPos:Add(Vector(0,3,-2):Rotate(HitNormal:Angle()))

    tpikMatrix.left = HitPos:NormalizeLengthOfSphere(18,origin) - Normal

    mat:Identity()
    mat:SetTranslation(tpikMatrix.left)
    mat:SetAngles(HitNormal:Angle())

    mat:Mul(MatrixLocalLeftHand)

    BonesManager_ApplyMatrix(ply,ply:LookupBone("ValveBiped.Bip01_L_Hand"),mat)
end

local MatrixLocalRightHand = Matrix()
MatrixLocalRightHand:SetAngles(Angle(0,90,180))

local mat = Matrix()

local function setRight(ply,tpikMatrix,HitPos,Normal,HitNormal,origin)
    HitPos:Add(Vector(0,-3,-2):Rotate(HitNormal:Angle()))

    tpikMatrix.right = HitPos:NormalizeLengthOfSphere(16,origin) - Normal

    mat:Identity()
    mat:SetTranslation(tpikMatrix.right)
    mat:SetAngles(HitNormal:Angle())

    mat:Mul(MatrixLocalRightHand)

    BonesManager_ApplyMatrix(ply,ply:LookupBone("ValveBiped.Bip01_R_Hand"),mat)
end

local function GetRelativeAngle(eyeAng, objAng)
    objAng:Normalize()

    local diff = eyeAng - objAng
    diff:Normalize()

    return diff[2]
end

local resultFake = {}

function TPIK_Hand_PickupObject(ply,link,tpikMatrix)
    local pickupObject = ply:GetPVSVar("holdPickupObject")

    pickupObject = pickupObject and Entity(pickupObject)

    if IsValid(pickupObject) then
        local pos,ang = pickupObject:GetPos(),pickupObject:GetAngles()

        local eyePos,eyeAng = ply:Eye()

        if pickupObject:IsRagdoll() then
            if CLIENT then pickupObject:SetupBones() end
            local matBone = pickupObject:GetBoneMatrixNow(pickupObject:TranslatePhysBoneToBone(ply:GetPVSVar("holdPickupObjectBone")))
            if not matBone then return end
            
            local pos = matBone:GetTranslation()

            setLeft(ply,tpikMatrix,pos,Vector(1,-2,0):Rotate(eyeAng),Vector(0,1,0):Rotate(eyeAng),eyePos)
            setRight(ply,tpikMatrix,pos,Vector(-3,4,0):Rotate(eyeAng),Vector(0,-1,0):Rotate(eyeAng),eyePos)
        else
            pos:Add(pickupObject:OBBCenter():Rotate(ang))

            local eyeForward = eyeAng:Forward()

            filterEntity = pickupObject

            local maxLen = math.max(pickupObject:OBBMins():Length(),pickupObject:OBBMaxs():Length()) + 20

            --

            local degress = math.abs(GetRelativeAngle(eyeAng,ang))

            local dir

            if degress > 160 then
                dir = Vector(0,maxLen,0)
            elseif degress > 60 then
                dir = Vector(maxLen,0,0)
            else
                dir = Vector(0,maxLen,0)
            end

            dir:Rotate(ang)

            tr.start = pos + dir
            tr.endpos = pos

            local cross = eyeForward:Cross((tr.start - eyePos):GetNormalized())[3]
            local result = util.TraceHull(tr)

            --debugoverlay.Sphere(result.HitPos,1,0.1,nil,true)

            if result.Entity == pickupObject then
                if cross <= 0 then
                    setRight(ply,tpikMatrix,result.HitPos,result.Normal,result.HitNormal,eyePos)
                else
                    setLeft(ply,tpikMatrix,result.HitPos,result.Normal,result.HitNormal,eyePos)
                end
            end

            --

            tr.start = pos - dir
            tr.endpos = pos

            local cross = eyeForward:Cross((tr.start - eyePos):GetNormalized())[3]
            local result = util.TraceHull(tr)

            --debugoverlay.Sphere(result.HitPos,1,0.1,nil,true)

            if result.Entity == pickupObject then
                if cross < 0 then
                    setRight(ply,tpikMatrix,result.HitPos,result.Normal,result.HitNormal,eyePos)
                else
                    setLeft(ply,tpikMatrix,result.HitPos,result.Normal,result.HitNormal,eyePos)
                end
            end
        end
    end
end