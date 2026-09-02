DeadBodys = DeadBodys or {}

function Create_RagdollFromData(data)
	local rag = ClientsideRagdoll(data.model)
	rag:SetNoDraw(false)
	rag:DrawShadow(true)

	rag.isFakeRagdoll = true
	
	rag:SetPos(data.pos,true)
	rag:SetAngles(data.ang)

    rag:SetSkin(data.skin)

	//if data.GetPlayerColor then rag:SetNW2Vector("modelcolor",data:GetPlayerColor()) end

	for id,value in pairs(data.bodygroups) do
		rag:SetBodygroup(id,value)
	end
	
	rag:Spawn()
	if not IsValid(rag:GetPhysicsObject()) then rag:Remove() return false end

	DeadBodys[rag] = true

	rag:GetPhysicsObject():SetMass(12.775918006897)
	rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	local physobj = rag:GetPhysicsObject()

 	for i = 0, data.bone_count do
		local physobj = rag:GetPhysicsObjectNum(i)

		local matrix = data.bone_matrix[i]
		if not matrix then continue end

		physobj:SetPos(matrix.pos,true)
		physobj:SetAngles(matrix.ang)

		physobj:AddVelocity(data.vel)
	end
	
	for k,v in pairs(oop.listClass["fake_ragdoll"][1]) do rag[k] = v end

    if data.Armors then rag:OnNWTable_Armor(data.Armors) end

	return rag
end

hook.Add("PreCleanupMap","Dead Bodys",function()
	for rag in pairs(DeadBodys) do
		if IsValid(rag) then rag:Remove() end
	end

	DeadBodys = {}
end)
