local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

function SWEP:SetupBones_WorldModel_ByHand(ent,link)
	local veryFast = not ent:IsTPIKAviable()
	local data = veryFast and self.wmVeryFastData or self.wmFastData
	
    local wm = self:GetWorldModel(data)
	if not IsValid(wm) then return end
	
	wm:SetSequence(0)

    local Pos,Ang = self:Transform_GetFromRagdoll(ent,data.vec:Clone(),data.ang:Clone())
    if not Pos then return end--lol

	self:Transform_GetCenter(Pos,Ang,data)

    wm:SetPos(Pos)
    wm:SetAngles(Ang)
    if CLIENT then self:RenderSetupBones(wm) end
end

function TPIK_Weapon(ply,link,tpikMatrix)
	if not IsValid(link) or not link:IsPlayer() then return end
	
	local wepSecondary = link:GetActiveSecondaryWeapon()

	if IsValid(wepSecondary) and wepSecondary.DoTPIK then
		wepSecondary:DoTPIK(ply,link,tpikMatrix)
	end

	local wep = link:GetActiveWeapon()

	if IsValid(wep) and wep.DoTPIK and IsFirstFrame(wep,"DoTPIKFrame") then
		wep:DoTPIK(ply,link,tpikMatrix)
	end
end

function SWEP:DoTPIK(ent,link,tpikMatrix)
    if link:InFakeDeath() then return end---WTTTTFFF

	if self.DoBones then self:DoBones(ent,link,tpikMatrix) end
	
	self:SetupBones_WorldModel_ByHand(ent,link)
end

function TPIKFast_Weapon(ply,link,tpikMatrix)
	if not IsValid(link) or not link:IsPlayer() then return end

	local wep = link:GetActiveWeapon()

	if IsValid(wep) and wep.DoTPIKFast and IsFirstFrame(wep,"DoTPIKFrame") then
		wep:DoTPIKFast(ply,link,tpikMatrix)
	end
end

function SWEP:DoTPIKFast(ent,link,tpikMatrix)
	if self.DoBones then self:DoBones(ent,link,tpikMatrix) end
	
	self:SetupBones_WorldModel_ByHand(ent,link)
end

SWEP:Event_Add("Construct","wmFastData",function(self)
	local content = self[1]

	content.WorldModel = (content.wmDropData and content.wmDropData.model) or (content.wmData and content.wmData.model) or (content.wmFastData and content.wmFastData.model) or (content.wmVeryFastData and content.wmVeryFastData.model)
end)

function SWEP:DoBones() end