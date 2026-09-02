local lply = LocalPlayer()
local IsValid = IsValid
local angle_zero = Angle(0,0,0)

hook.Add("PlayerFootstep", "CustomFootstep", function(ply)
	local rag = ply:GetDummy()
	return IsValid(rag) and rag ~= ply
end)

-- Finger joints (two per finger, three fingers, per hand).
-- Primary names follow the legacy zombie-style skeleton, with a
-- ValveBiped fallback so standard player models get the pose too.
local FingerParts = {
	{ "l_finger0", 	"ValveBiped.Bip01_L_Finger01" },
	{ "l_finger01",	"ValveBiped.Bip01_L_Finger02" },
	{ "l_finger1", 	"ValveBiped.Bip01_L_Finger2" },
	{ "l_finger11",	"ValveBiped.Bip01_L_Finger22" },
	{ "l_finger2", 	"ValveBiped.Bip01_L_Finger3" },
	{ "l_finger21",	"ValveBiped.Bip01_L_Finger32" },
	{ "r_finger0", 	"ValveBiped.Bip01_R_Finger01" },
	{ "r_finger01",	"ValveBiped.Bip01_R_Finger02" },
	{ "r_finger1", 	"ValveBiped.Bip01_R_Finger2" },
	{ "r_finger11",	"ValveBiped.Bip01_R_Finger22" },
	{ "r_finger2", 	"ValveBiped.Bip01_R_Finger3" },
	{ "r_finger21",	"ValveBiped.Bip01_R_Finger32" },
}

local GrabAngles = {
	Angle(0,20,0), Angle(0,20,0),
	Angle(0,-40,0), Angle(0,-80,0),
	Angle(0,-40,0), Angle(0,-80,0),
	Angle(0,20,0), Angle(0,20,0),
	Angle(0,-40,0), Angle(0,-80,0),
	Angle(0,-40,0), Angle(0,-80,0),
}

local function GetFingerBones(rag)
	if rag.FingerBonesCache then return rag.FingerBonesCache end

	local list = {}

	for i, pair in ipairs(FingerParts) do
		for _, name in ipairs(pair) do
			local id = rag:LookupBone(name)
			if id and id > 0 then
				list[i] = id
				break
			end
		end
	end

	rag.FingerBonesCache = list
	return list
end

local smallVec = Vector(0.001,0.001,0.001)

hook.Add("Player Think", "Player_Fake", function(ply)
	local rag = ply:GetDummy()
	if not IsValid(rag) or not rag:IsRagdoll() then return end

	local bones = GetFingerBones(rag)
	local left = ply:GetNWBool("LeftArm")
	local right = ply:GetNWBool("RightArm")

	for i = 1,12 do
		local bone = bones[i]
		if not bone then continue end

		-- ManipulateBoneAngles sets the pose (relative to the original bone
		-- angle), so feeding the same value every frame keeps fingers steady.
		local grabbed = (i <= 6 and left) or (i > 6 and right)
		rag:ManipulateBoneAngles(bone, grabbed and GrabAngles[i] or angle_zero)
	end

	if ply == LocalPlayer() and not rag.hgHeadHidden then
		local headBone = rag:LookupBone("ValveBiped.Bip01_Head1") or rag:LookupBone("bip_head")
		if headBone then
			rag:ManipulateBoneScale(headBone,smallVec)
			rag.hgHeadHidden = true
		end
	end
end)

hook.Add("Think", "Homigrad_Ragdoll_Color", function()
	for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
		if not IsValid(ent) or not ent:IsRagdoll() or ent.hgColorApplied then continue end

		-- Fake ragdolls already tint through ENT:GetPlayerColor (PVSVar
		-- "PlayerColor" set server-side); overriding their RenderOverride here
		-- would break the fake drawing path (weapon on hand, LOD blending).
		if ent:GetPVSVar("IsFakeRagdoll") or ent.GetPlayer then continue end

		local color = ent:GetNW2Vector("modelcolor")
		if not color or color == vector_origin then color = ent:GetNWVector("PlayerColor") end
		if not color or color == vector_origin then continue end

		ent.hgColorApplied = true
		ent.GetPlayerColor = function() return color end

		ent.RenderOverride = function(self)
			self:SetupBones()
			self:DrawModel()
		end
	end
end)

hook.Add("HUDPaint", "Shit123", function()
	if ROUND_NAME ~= "dr" then return end
	if not lply:GetNWBool("Fake") or not lply:Alive() then return end

	local remain = math.Clamp(math.Round(lply:GetNWFloat("TimeToDeath") - CurTime(),1),0,100000)

	draw.SimpleText(L("dr_youwilldiein",remain),"H.25",ScrW()/2,ScrH()/1.5,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end)