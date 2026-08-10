local SWEP = oop.Get("tpik_animate")
if not SWEP then return end


local vec = Vector(0,0,0)

function SWEP:IsTPIKLeftInputBusy() return not self.IsSecondaryWeapon and IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetActiveSecondaryWeapon()) end
function SWEP:IsTPIKRightInputBusy() end

if SERVER then
    SWEP.TPIKBonesL = {
        {"ValveBiped.Bip01_L_Hand","ValveBiped.Bip01_L_Hand"},
    }

    SWEP.TPIKBonesR = {
        {"ValveBiped.Bip01_R_Hand","ValveBiped.Bip01_R_Hand"},
    }
else
    SWEP.TPIKBonesL = {
        {"ValveBiped.Bip01_L_Hand","ValveBiped.Bip01_L_Hand"},
        {"ValveBiped.Bip01_L_Finger4","ValveBiped.Bip01_L_Finger4"},
        {"ValveBiped.Bip01_L_Finger41","ValveBiped.Bip01_L_Finger41"},
        {"ValveBiped.Bip01_L_Finger42","ValveBiped.Bip01_L_Finger42"},
        {"ValveBiped.Bip01_L_Finger3","ValveBiped.Bip01_L_Finger3"},
        {"ValveBiped.Bip01_L_Finger31","ValveBiped.Bip01_L_Finger31"},
        {"ValveBiped.Bip01_L_Finger32","ValveBiped.Bip01_L_Finger32"},
        {"ValveBiped.Bip01_L_Finger2","ValveBiped.Bip01_L_Finger2"},
        {"ValveBiped.Bip01_L_Finger21","ValveBiped.Bip01_L_Finger21"},
        {"ValveBiped.Bip01_L_Finger22","ValveBiped.Bip01_L_Finger22"},
        {"ValveBiped.Bip01_L_Finger1","ValveBiped.Bip01_L_Finger1"},
        {"ValveBiped.Bip01_L_Finger11","ValveBiped.Bip01_L_Finger11"},
        {"ValveBiped.Bip01_L_Finger12","ValveBiped.Bip01_L_Finger12"},
        {"ValveBiped.Bip01_L_Finger0","ValveBiped.Bip01_L_Finger0"},
        {"ValveBiped.Bip01_L_Finger01","ValveBiped.Bip01_L_Finger01"},
        {"ValveBiped.Bip01_L_Finger02","ValveBiped.Bip01_L_Finger02"},
    }

    SWEP.TPIKBonesR = {
        {"ValveBiped.Bip01_R_Hand","ValveBiped.Bip01_R_Hand"},
        {"ValveBiped.Bip01_R_Finger4","ValveBiped.Bip01_R_Finger4"},
        {"ValveBiped.Bip01_R_Finger41","ValveBiped.Bip01_R_Finger41"},
        {"ValveBiped.Bip01_R_Finger42","ValveBiped.Bip01_R_Finger42"},
        {"ValveBiped.Bip01_R_Finger3","ValveBiped.Bip01_R_Finger3"},
        {"ValveBiped.Bip01_R_Finger31","ValveBiped.Bip01_R_Finger31"},
        {"ValveBiped.Bip01_R_Finger32","ValveBiped.Bip01_R_Finger32"},
        {"ValveBiped.Bip01_R_Finger2","ValveBiped.Bip01_R_Finger2"},
        {"ValveBiped.Bip01_R_Finger21","ValveBiped.Bip01_R_Finger21"},
        {"ValveBiped.Bip01_R_Finger22","ValveBiped.Bip01_R_Finger22"},
        {"ValveBiped.Bip01_R_Finger1","ValveBiped.Bip01_R_Finger1"},
        {"ValveBiped.Bip01_R_Finger11","ValveBiped.Bip01_R_Finger11"},
        {"ValveBiped.Bip01_R_Finger12","ValveBiped.Bip01_R_Finger12"},
        {"ValveBiped.Bip01_R_Finger0","ValveBiped.Bip01_R_Finger0"},
        {"ValveBiped.Bip01_R_Finger01","ValveBiped.Bip01_R_Finger01"},
        {"ValveBiped.Bip01_R_Finger02","ValveBiped.Bip01_R_Finger02"},
    }

    SWEP.TPIKBonesLFast = {
        {"ValveBiped.Bip01_L_Hand","ValveBiped.Bip01_L_Hand"},
    }

    SWEP.TPIKBonesRFast = {
        {"ValveBiped.Bip01_R_Hand","ValveBiped.Bip01_R_Hand"},
    }
end

SWEP.ElbowLeftDown = 120
SWEP.ElbowRightDown = 120

SWEP.TPIK_TwistOffset = 0

function SWEP:DoTPIK(ent,link,tpikMatrix)
    if link:InFakeDeath() then return end---WTTTTFFF
    
    self:DoBones(ent,link,tpikMatrix)
    
    local wm,isCreate = self:GetWorldModel(self.wmData)
    if not IsValid(wm) then return end--lol

    tpikMatrix.rightDown = self.ElbowLeftDown
    tpikMatrix.leftDown = self.ElbowRightDown

    tpikMatrix.leftTwist = self.TPIK_TwistOffsetLeft or self.TPIK_TwistOffset
    tpikMatrix.rightTwist = self.TPIK_TwistOffsetRight or self.TPIK_TwistOffset

    tpikMatrix.wm = wm

    self:SetupBones_WorldModel_ByTPIK(tpikMatrix)

    local dontParseFingers = false--not ent.renderLOD0
    
    if not self:IsTPIKLeftInputBusy() and self:TPIK_CanUseLeftHand() then
        local wm = self:GetModelForTPIKLeftHand()

        if IsValid(wm) then
            local mat = self:DoTPIKLeftHandFingers(ent,wm,dontParseFingers)
            if mat then tpikMatrix.left:Set(mat:GetTranslation()) end
        end
    end

    if not self:IsTPIKRightInputBusy() and self:TPIK_CanUseRightHand() then
        local wm = self:GetModelForTPIKRightHand()

        if IsValid(wm) then
            local mat = self:DoTPIKRightHandFingers(ent,wm,dontParseFingers)
            if mat then tpikMatrix.right:Set(mat:GetTranslation()) end
        end
    end

    if self.DoIKPost then self:DoIKPost(ent,link,tpikMatrix) end
end

--

function SWEP:GetModelForTPIKLeftHand() return self.wm end
function SWEP:GetModelForTPIKRightHand() return self.wm end

function SWEP:DoTPIKLeftHandFingers(ply,wm,fast)
    local TPIKBonesL = fast and self.TPIKBonesLFast or self.TPIKBonesL

    local handmat

    for i = 1,#TPIKBonesL do
        local info = TPIKBonesL[i]
        local boneWM,bonePlayer = info[1],info[2]

        local wm_boneindex = wm:LookupBone(boneWM)
        if not wm_boneindex then continue end

        local wm_bonematrix = wm:GetBoneMatrix(wm_boneindex)
        if not wm_bonematrix then continue end

        wm_bonematrix:Set(wm_bonematrix)

        if i == 1 then
            handmat = wm_bonematrix

            if fast then continue end
        end

        local ply_boneindex = ply:LookupBone(bonePlayer)
        if not ply_boneindex then continue end

        local ply_bonematrix = ply:GetBoneMatrix(ply_boneindex)
        if not ply_bonematrix then continue end

        ply_bonematrix:Set(wm_bonematrix)
    end
    
    return handmat
end

function SWEP:DoTPIKRightHandFingers(ply,wm,fast)
    local TPIKBonesR = fast and self.TPIKBonesLRast or self.TPIKBonesR

    local handmat

    for i = 1,#TPIKBonesR do
        local info = TPIKBonesR[i]
        local boneWM,bonePlayer = info[1],info[2]

        local wm_boneindex = wm:LookupBone(boneWM)
        if not wm_boneindex then continue end

        local wm_bonematrix = wm:GetBoneMatrix(wm_boneindex)
        if not wm_bonematrix then continue end

        if i == 1 then
            handmat = wm_bonematrix
            
            if fast then continue end
        end

        local ply_boneindex = ply:LookupBone(bonePlayer)
        if not ply_boneindex then continue end

        local ply_bonematrix = ply:GetBoneMatrix(ply_boneindex)
        if not ply_bonematrix then continue end

        ply_bonematrix:Set(wm_bonematrix)
    end
        
    return handmat
end

function TPIK_Lerp_Weapon(ent,link,interpMatrix)
	if not link then return end
	
	local wep = link:GetActiveWeapon()

	if IsValid(wep) and wep.DoTPIKLerp and link:IsPlayer() then
		wep:DoTPIKLerp(ent,link,interpMatrix)
	end

	local wepSecondary = link:GetActiveSecondaryWeapon()

	if IsValid(wepSecondary) and wepSecondary.DoTPIKLerp and link:IsPlayer() then
		wepSecondary:DoTPIKLerp(ent,link,interpMatrix)
	end
end

SWEP.TPIKLerpWhitelist = {
    ["weapon"] = true
}

for k,v in pairs(SWEP.TPIKBonesL) do SWEP.TPIKLerpWhitelist[v[2]] = true end
for k,v in pairs(SWEP.TPIKBonesR) do SWEP.TPIKLerpWhitelist[v[2]] = true end

SWEP.TPIKLerpInterpolation = 0.3

local VMatrixSet = Matrix()
local VMatrixSet2 = Matrix()
local VecSet,AngSet = Vector(),Angle()

local lerp = 0

function SWEP:DoTPIKLerp(ply,link,tpikMatrix)
    local wm = self:GetWorldModel()
    if not wm then return end

    local matrixRespect,matrixRespectInverse = PlayersBones_MatrixRespect(link)

    local interpolationValue = tpikMatrix.interp
    local reset = tpikMatrix.reset

    if reset then
        BonesManager_Clear(wm)
    else
        self:DoBones(ply,link,tpikMatrix)
    end
    
    if interpolationValue == 1 then
        matrixRespect:SetXYZ_PYR(VecSet,AngSet)

        if not wm.player_follow_pos or reset then
            wm.player_follow_pos = wm:GetPos():Sub(VecSet)
            wm.player_follow_ang = wm:GetAngles():Sub(AngSet)
        end

        wm:SetPos(VecSet:Add(wm.player_follow_pos))
        wm:SetAngles(AngSet:Add(wm.player_follow_ang))

        if CLIENT then self:SetupBonesChildrens(wm) end
        
        return
    end

    local set = self.sequenceObject and not self.sequenceObject.dontChangeTPIKLerp and 1 or 0

    lerp = LerpFT(set > lerp and 0.8 or 0.08,lerp,set)

    interpolationValue = Lerp(lerp,interpolationValue,self.TPIKLerpInterpolation)

    tpikMatrix.interp = interpolationValue

    local bones_matrix = wm.bones_matrix
    local bones_matrix_follow = wm.bones_matrix_follow
    
    if not bones_matrix_follow then
        bones_matrix_follow = {}
        wm.bones_matrix_follow = bones_matrix_follow
    end

    local TPIKLerpWhitelist = self.TPIKLerpWhitelist

    if reset then
        for i = 0,wm:GetBoneCount() - 1 do
            local name = wm:GetBoneName(i)
            if name == "__INVALIDBONE__" then continue end

            wm:CopyBoneMatrixHash(i,VMatrixSet2)
            if VMatrixSet2:IsIdentity() then continue end

            if not TPIKLerpWhitelist[name] then
                wm:CopyBoneMatrixHash(wm:GetBoneParent(i),VMatrixSet)
                if VMatrixSet:IsIdentity() then continue end

                VMatrixSet:Invert()
                VMatrixSet:Mul(VMatrixSet2)

                if bones_matrix_follow[i] then
                    bones_matrix_follow[i]:Set(VMatrixSet)
                else
                    bones_matrix_follow[i] = VMatrixSet:Clone()
                end
            else
                bones_matrix[i]:Set(VMatrixSet2)
            end
        end
    end

    TPIKLerp_DoSolveEntity(wm,matrixRespect,matrixRespectInverse,reset,interpolationValue)

    for boneID,matLocal in pairs(bones_matrix_follow) do
        wm:CopyBoneMatrixHash(wm:GetBoneParent(boneID),VMatrixSet)
        if VMatrixSet:IsIdentity() then continue end
        
        VMatrixSet:Mul(matLocal)
        
        if not bones_matrix[boneID] then
            bones_matrix[boneID] = VMatrixSet:Clone()
        else
            bones_matrix[boneID]:Set(VMatrixSet)
        end
    end

    if CLIENT then self:SetupBonesChildrens(wm) end
end