event.Add("Player Spawn","Armor",function(ply)
	armorGame:Event_Call("OnChangeEntity",ply,ply.Armors)
end)

FindMetaTable("Entity").OnNWTable_Armor = function(self,tbl)
	if not self.Armors then armorGame.Create(self) end
	
	for armorName in pairs(self.Armors.native) do
		if tbl[armorName] then continue end

		self.Armors.native[armorName] = nil
	end

	for armorName in pairs(self.Armors.slots) do self.Armors.slots[armorName] = nil end

	for armorName,data in pairs(tbl) do
		armorGame.Give(self.Armors,armorName,data,"server")
	end
	
	armorGame:Event_Call("OnChangeEntity",self,self.Armors)
end

armorGame:Event_Add("Update","CSM Chache Clear",function()
	RunConsoleCommand("hg_csm_chache_clear")
end)

local renderOrderCameraArmor = {}

event.Add("PreRender","renderOrderCameraArmor",function()
	for i = 1,#renderOrderCameraArmor do renderOrderCameraArmor[i] = nil end
end)

armorGame:Event_Add("OnChangeEntity","Camera",function(ply)
	if ply != GetViewEntity() then return end
	
	for slotName,armorName in pairs(ply.Armors.slots) do
		CSM.Delete(CSM.tagIndex["CameraArmor_" .. slotName])
	end
end)

event.Add("PreCalcView","Armor Head",function(ply,view)
	if not ply:Alive() then return end

	ExtinguishGunShoot = false
	
	for slotName,armorName in pairs(ply.Armors.slots) do
		if slotName != "head" and slotName != "headset" and slotName != "mask" then continue end

		local data = ply.Armors.native[armorName]

		local config = armorGame.GetConfig(data)
		if config.ExtinguishGunShoot then ExtinguishGunShoot = true end

		if not config.cameraVec then continue end

		local mdl,isCreate = CSM.GetByID(config.model,"CameraArmor_" .. slotName,true)

		if isCreate then
			mdl:EnableMatrixScale(config.cameraSize)
		end

		renderOrderCameraArmor[#renderOrderCameraArmor+1] = mdl

		local Pos,Ang = LocalToWorld(config.cameraVec,config.cameraAng,view.vec,view.ang)
		mdl:SetPos(Pos)
		mdl:SetAngles(Ang)

		local entModel = ply:GetModel()

		if data.attachments then
			local container = CSM.GetContainer(mdl.csmTag .. "_camera",mdl)
			mdl.container = container
			mdl.attachments = {}

			if #container.childrens == 0 then
				for path,key in pairs(data.attachments) do
					local configAtt = armorGame.GetConfigAttachment(key[1])
					if not configAtt or not configAtt.cameraVec or not configAtt.model then continue end
					
					local mdl = attachmentGame.CreateAttachmentModel(data,mdl,path,key)
					mdl:EnableMatrixScale(configAtt.cameraSize)
				end
			end

			for i = 1,#container.childrens do
				local mdl = container.childrens[i]
				if not IsValid(mdl) then container.Clear() break end--Error

				local configAtt = armorGame.GetConfigAttachment(mdl.key[1])

				local Pos,Ang = LocalToWorld(configAtt.cameraVec,configAtt.cameraAng,Pos,Ang)
				mdl:SetPos(Pos)
				mdl:SetAngles(Ang)

				renderOrderCameraArmor[#renderOrderCameraArmor+1] = mdl
			end
		end
	end
end,100)

function RenderPlayer_Armor_Camera(ent,tag,link,flags)
	if not RenderIsMe() or GetViewEntity() != link then return end
	
	for i = 1,#renderOrderCameraArmor do
		renderOrderCameraArmor[i]:DrawModel()
	end
end

hook.Add("PreDrawHUD","Armor Head",function()
	local ply = GetViewEntity()
	if not ply.Armors or not ply:Alive() then return end

	if GetViewEntity() != ply or not ply.headPop then return end

	for slotName,armorName in pairs(ply.Armors.slots) do
		if slotName != "head" and slotName != "headset" and slotName != "mask" then continue end

		local config = armorGame.GetConfig(ply.Armors.native[armorName])
		if not config.drawOverlayFunction then continue end

		render.ClearDepth()

		cam.Start2D()

		config.drawOverlayFunction()

		cam.End2D()
	end
end)

armorGame:Event_Add("Give","Attachments",function(Armor,armorName,data,typeCall)
	if not data.attachmentsInput then return end
	
	local existsData = Armor.native[armorName]

	if not existsData.attachments then
		attachmentGame.Init(existsData,attachmentGame.config)

		existsData.MainAttachment = armorGame.config[armorName].MainAttachment
		attachmentGame.InitParse(existsData)
	end

	existsData.MainAttachment = armorGame.config[armorName].MainAttachment
	
	attachmentGame.InputPkgData(existsData,data.attachmentsInput)
end)

armorGame:Event_Add("Update","Attachments Update",function()--DEV
	for armorName,data in pairs(LocalPlayer().Armors.native) do
		if not data.attachments then continue end

		data.MainAttachment = armorGame.config[armorName].MainAttachment
		
		for path,slot in SortedPairs(data.attachments) do
			data:AttachmentSet(path,slot[1])
		end
	end
end)--DEV