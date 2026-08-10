armorGame:Event_Add("OnChangeEntity","Render",function(ply,armor)
	armorGame.InitWorldModel(ply,nil,ply.Armors)
end)

local empty = {}

modelSetting_ArmorOffset = modelSetting_ArmorOffset or {}

local vecZero,vecFull = Vector(),Vector(1,1,1)

function armorGame.InitWorldModel(ent,tag,Armors)
	local isWorld = not tag

	local container = CSM.GetContainer(ent.csmParentTag .. "_armorGame_" .. (tag or ""),ent)
	container.frame = FrameNumber()
	
	ent.armorContainer = container
	container.Clear()

	for armorName,data in pairs(Armors.native) do
		local config = armorGame.GetConfig(data)

		local mdl = container.GetByID(config.model,armorName,isWorld)

		mdl:SetMaterial(config.mat or "")
		mdl:SetSkin(config.skin or 0)

		for id,set in pairs(config.bodygroups or empty) do mdl:SetBodygroup(id,set) end

		if not isWorld then mdl:SetNoDraw(true) end
		
		local addSize = vecZero
		local info = modelSetting_ArmorOffset[entModel]

		if info then
			info = info[config.bone]
			addSize = info and info.size or vecZero
		end

		mdl:EnableMatrixScale((config.size or vecFull) + addSize)

		local col = data.color or color_white

		mdl.r = col.r / 255
		mdl.g = col.g / 255
		mdl.b = col.b / 255
		
		mdl.isFace = data.isFace
		mdl.isBody = data.isBody
		mdl.config = config
		mdl.armorName = armorName

		mdl.container = CSM.GetContainer(mdl.csmContainerTag .. mdl.csmTag,mdl)
		mdl.container.Clear()
		
		mdl.childrens = mdl.container.childrens
		--mdl:SetParent(ent)

		if data.attachments then
			mdl.attachments = {}

			for path,key in pairs(data.attachments) do
				attachmentGame.CreateAttachmentModel(data,mdl,path,key)
			end
		end
	end

	container.maxChildrens = #container.childrens
end

local GetPos = armorGame.GetPosByEntity

local color_white = Color(255,255,255)

local render_SetColorModulation = render.SetColorModulation

cvars.CreateOption("hg_draw_armor","1",function(value)
	if tonumber(value) > 0 then
		function PlayerBones_Armor(ent,tag,link)
			link = link or ent

			if not link.Armors or not ent.armorContainer then return end

			local childrens = ent.armorContainer and ent.armorContainer.childrens

			if not childrens or ent.armorContainer.maxChildrens != #childrens or (link.armorContainer and ent.armorContainer.frame != link.armorContainer.frame) then
				armorGame.InitWorldModel(ent,tag,link.Armors)

				childrens = ent.armorContainer.childrens
			end

			local passSetupBone = link.renderLOD2 or (link.renderLOD2_5 and RenderHighPass(ent,50,60)) or RenderHighPass(ent,40,50)
			if not passSetupBone then return end

			local renderLOD2 = link.renderLOD2

			local entModel = ent:GetModel()

			for i = 1,#childrens do
				local mdl = childrens[i]
				if not IsValid(mdl) then ent.armorContainer.Clear() return end--error

				local Pos,Ang = GetPos(ent,entModel,mdl.config)
				
				if not Pos then return end

				if not tag and link.Armors.native[mdl.armorName] then
					link.Armors.native[mdl.armorName].wm = mdl
				end

				mdl:SetPos(Pos)
				mdl:SetAngles(Ang)

				if renderLOD2 then
					local childrens = mdl.childrens

					for i = 1,#childrens do
						local mdlAtt = childrens[i]
						if not IsValid(mdlAtt) then ent.armorContainer.Clear() return end--error

						local Pos,Ang = LocalToWorld(mdlAtt.localPos,mdlAtt.localAng,Pos,Ang)

						mdlAtt:SetPos(Pos)
						mdlAtt:SetAngles(Ang)
					end
				end
			end
		end

		function RenderPlayer_Armor(ent,tag,link,flags)
			link = link or ent
			
			local childrens = ent.armorContainer and ent.armorContainer.childrens
			if not childrens then return end

			local isMe = not tag and ent.r_headPop
			local renderLOD2 = link.renderLOD2
			
			for i = 1,#childrens do
				local mdl = childrens[i]
				if not IsValid(mdl) then ent.armorContainer.Clear() break end--error
				
				if isMe and mdl.isFace then continue end

				if mdl.r then render_SetColorModulation(mdl.r,mdl.g,mdl.b) end

				mdl:DrawModel()

				if renderLOD2 then
					local childrens = mdl.childrens

					for i = 1,#childrens do
						childrens[i]:DrawModel()
					end
				end
			end

			render_SetColorModulation(1,1,1)
		end
	else
		function PlayerBones_Armor() end
		function RenderPlayer_Armor() end
	end
end)