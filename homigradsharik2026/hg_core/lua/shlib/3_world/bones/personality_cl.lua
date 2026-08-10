local vecZero,vecInf,vecFull = Vector(0,0,0),Vector(0/0,0/0,0/0),Vector(1,1,1)

local matrix = Matrix()
matrix:SetTranslation(vecInf)

FindMetaTable("Entity").SetHeadMatrixScale = function(self,value,bone)
	if not value then return end
	
	bone = bone or self:LookupBone("ValveBiped.Bip01_Head1")
	if not bone then return end

	if value then
		self:SetBoneMatrixNow(bone,matrix)
	end

	local childrens = BonesManager_GetChildren(self,bone)

	for i = 1,#childrens do
		self:SetHeadMatrixScale(value,childrens[i])
	end
end

local validBones = {
	["ValveBiped.Bip01_L_Clavicle"] = true,
	["ValveBiped.Bip01_L_UpperArm"] = true,
	["ValveBiped.Bip01_L_Forearm"] = true,
	["ValveBiped.Bip01_L_Hand"] = true,
	["ValveBiped.Bip01_L_Finger4"] = true,
	["ValveBiped.Bip01_L_Finger41"] = true,
	["ValveBiped.Bip01_L_Finger42"] = true,

	["ValveBiped.Bip01_L_Finger3"] = true,
	["ValveBiped.Bip01_L_Finger31"] = true,
	["ValveBiped.Bip01_L_Finger32"] = true,

	["ValveBiped.Bip01_L_Finger2"] = true,
	["ValveBiped.Bip01_L_Finger21"] = true,
	["ValveBiped.Bip01_L_Finger22"] = true,

	["ValveBiped.Bip01_L_Finger1"] = true,
	["ValveBiped.Bip01_L_Finger11"] = true,
	["ValveBiped.Bip01_L_Finger12"] = true,

	["ValveBiped.Bip01_L_Finger0"] = true,
	["ValveBiped.Bip01_L_Finger01"] = true,
	["ValveBiped.Bip01_L_Finger02"] = true,

	["ValveBiped.Bip01_R_Clavicle"] = true,
	["ValveBiped.Bip01_R_UpperArm"] = true,
	["ValveBiped.Bip01_R_Forearm"] = true,
	["ValveBiped.Bip01_R_Hand"] = true,
	["ValveBiped.Bip01_R_Finger4"] = true,
	["ValveBiped.Bip01_R_Finger41"] = true,
	["ValveBiped.Bip01_R_Finger42"] = true,

	["ValveBiped.Bip01_R_Finger3"] = true,
	["ValveBiped.Bip01_R_Finger31"] = true,
	["ValveBiped.Bip01_R_Finger32"] = true,

	["ValveBiped.Bip01_R_Finger2"] = true,
	["ValveBiped.Bip01_R_Finger21"] = true,
	["ValveBiped.Bip01_R_Finger22"] = true,

	["ValveBiped.Bip01_R_Finger1"] = true,
	["ValveBiped.Bip01_R_Finger11"] = true,
	["ValveBiped.Bip01_R_Finger12"] = true,

	["ValveBiped.Bip01_R_Finger0"] = true,
	["ValveBiped.Bip01_R_Finger01"] = true,
	["ValveBiped.Bip01_R_Finger02"] = true,

	["ValveBiped.Bip01_Pelvis"] = true,

	["ValveBiped.Bip01_R_Calf"] = true,
	["ValveBiped.Bip01_R_Thigh"] = true,
	["ValveBiped.Bip01_R_Foot"] = true,
	["ValveBiped.Bip01_R_Toe0"] = true,

	["ValveBiped.Bip01_L_Calf"] = true,
	["ValveBiped.Bip01_L_Thigh"] = true,
	["ValveBiped.Bip01_L_Foot"] = true,
	["ValveBiped.Bip01_L_Toe0"] = true,
}

local vecZero = Vector(0/0,0/0,0/0)

FindMetaTable("Entity").SetOnlyHandsMatrixScale = function(self)
	for i = 0,self:GetBoneCount() - 1 do
		if validBones[self:GetBoneName(i)] then continue end

		local matrix = self:GetBoneMatrixNow(i)
		matrix:Scale(vecZero)

		self:SetBoneMatrixNow(i,matrix)
	end
end