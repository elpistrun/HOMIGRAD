local ENT = oop.Reg("item_armor","item_att_base",true)
if not ENT then return INCLUDE_BREAK end

inventoryGame.DelayArmor = 0.5

ENT.Category = "Снарежение"
ENT.Spawnable = true

ENT.IsArmor = true
ENT.itemType = "armor"

ENT.CONFIG = {"armorGame","config"}

function ENT:GetInvName(item)
	local config = armorGame.config[item.data.armorName]

	return config and config.printName or item.spawnname
end

if SERVER then
	function ENT:SetArmorWorldModel(armorName)
		local config = armorGame.config[armorName]
		if not config then return end

		self:SetModel(config.model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(20)
			phys:Wake()
		end
	end

	function ENT:Initialize()
		local n = self:GetAttachmentName()
		if n and n != "" then self:SetArmorWorldModel(n) end
	end

	function ENT:OnNWTable_AttachmentName(armorName)
		if armorName and armorName != "" then
			self:SetArmorWorldModel(armorName)
		end
	end

	return
end

function ENT:Initialize()
	self:SetupNWTable("Attachments")
end

function ENT:invUI_Draw(panel,item)
	local config = self:GetConfig()[item.data.armorName or "null"]
	if not config then draw.SimpleText(item.data.armorName or "null armor name",nil,nil,nil,Color(255,0,0)) return end

	local w,h = panel:W(),panel:H()

	surface.SetMaterial(Material(config.icon))
	local size = h - 14 + (panel.hovered or 0) * 5

	surface.SetDrawColor(255,255,255)
	surface.DrawTexturedRect(w / 2 - size / 2 + 1,h / 2 - size / 2 + 1,size,size)
end

local list = {
	list = {},
	volume = 1,
	pitch = 120
}

function ENT:GetInvSnd(item,soundName)
	local config = armorGame.config[item.data.armorName]

	if soundName == "InvMoveFromSnd" then
		list.list[1] = config.soundDrop
		list.pitch = 120
	else
		list.pitch = 255
		list.list[1] = config.soundPickup
	end

	return list
end

function ENT:InvGetColorType(item)
	local color = armorGame.config[item.data.armorName].invColor

	if TypeID(color) == TYPE_FUNCTION then return color(self,item) end
	
	return color
end

function armorGame.GetTipText(item,config)
	local text = ""

	if config.ratedJoules then text = text .. "Эмкость в джоулях: " .. config.ratedJoules .. "\n" end
	if config.hardness then text = text .. "Твёрдость: " .. config.hardness .. "\n" end
	if config.hardness then text = text .. "Убовляемая прочность от урона: " .. config.brittleness * 100 .. "%\n" end
	if config.atletichTier then text = text .. "Нагрузка: " .. armorGame.ArmorAtletichIndex[config.atletichTier].name .. "\n" end
	if config.loadCapacity then text = text .. "Множитель передвежения от груза: " .. config.loadCapacity * 100 .. "%\n" end

	if config.desc then text = text .. config.desc .. "\n" end

	if item then
		if item.integrity then text = text .. "\nПрочность: " .. math.floor(item.integrity * 100) .. "%\n" end
	end
	
	return text
end

local color_gray = Color(128,128,128,128)

function ENT:InvSelectPanelDrawOver(w,h,icon,item)
	local config = armorGame.config[item.data.armorName]

	if config.armorTier then
		draw.SimpleText(armorGame.ArmorTierIndex[config.armorTier].name,"HS.18",w/2,12,nil,TEXT_ALIGN_CENTER)
	end

	icon:DrawTip(armorGame.GetTipText(item.data,config))

	if icon.OnMouse then
		if icon:IsHovered() then
			surface.SetDrawColor(255,255,255,5)
			surface.DrawRect(0,0,w,h)
		end

		DisableClipping(true)
		draw.SimpleText("НАЖМИТЕ ЧТО-БЫ МОДИФИЦИРОВАТЬ","H.12",w/2,h + 6,color_gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
		DisableClipping(false)
	end
end

function armorGame.ConstructTogglePanel(panel,item,config)
	local wide = attachmentGame.iconSize
	panel:setW(panel:H() + 32 + wide)
end

function ENT:invUI(panel,item)
	local w,h = panel:W(),panel:H()

	panel:setW(h)

	local config = armorGame.config[item.data.armorName]
	if config.MainAttachment then self:invUI_Attachment(panel,item) return end
	if config.invUI then config.invUI(self,panel,item) return end
	
	if not config.toggle then panel:setW(h) return end

	armorGame.ConstructTogglePanel(panel,item,config)
end

function ENT:invUI_Attachment(panel,item)
	local armorData = item.inv.parent.Armors.native[item.data.armorName]
	if not armorData then return end

	panel.icon.OnMouse = function(_,key,value)
		if not value or key != MOUSE_LEFT then return end

		scoreboard:Close()
		RunConsoleCommand("hg_armor_attachment_menu",item.data.armorName)
	end

	local size = attachmentGame.iconSize
	local wide = size

	panel:setW(panel:H() + 64 + wide * 2)
	panel.icon:setPos(wide + 16,0)
	
	local attachments = armorData.attachments

	local x,y = 0,0

	local panelVariants = vCreate("v_panel",panel):setPos(panel.icon.x + panel.icon:W(),0)
	panelVariants:setSize(wide + 16,panel:H())

	for path,key in pairs(attachments) do
		local attConfig = attachmentGame.config[key[2][1]]
		if not attConfig or (not attConfig.toggle and not attConfig.OnToggle) then continue end

		local variant = vCreate("v_button",panelVariants):setSize(size,size):setPos(16 + x,16 + y)

		function variant:Draw(w,h)
			draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackground)
			if self:IsHovered() then draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackgroundHovered2) end

			surface.SetMaterial(MaterialHash(attConfig.icon))
			surface.SetDrawColor(255,255,255)
			surface.DrawTexturedRectRotated(w/2,h/2,h*0.98,h*0.98,0)

			if attConfig.ToggleDraw then attConfig.ToggleDraw(self) end
		end

		function variant:OnClick()
			if attConfig.OnToggle then
				attConfig.OnToggle(item)
			else
				RunConsoleCommand("hg_armor_attachment_set_toggle",item.data.armorName,path,key[1].toggle and 0 or 1)
			end
		end

		if x + variant:W() >= wide then
			x = 0
			y = y + 16 + variant:H()
		end
	end
end

function ENT:OnNWTable_Attachments(tbl)
	if not self.attachments then attachmentGame.Init(self,attachmentGame.config) end

	self.MainAttachment = armorGame.config[self:GetAttachmentName()].MainAttachment

	attachmentGame.InputPkgData(self,tbl)
end

function ENT:RenderOverride()
	local passSetupBones = IsFirstFrame(self,"SetupBonesFrame")

	if passSetupBones then
		self.distanceEye = EyePos():Distance(self:GetPos())
	end

	if self.distanceEye > RenderLOD1_Distance then return end

	if not self.attachments or self.distanceEye > RenderLOD0_Distance then self:DrawModel() return end
	
	local wm,isCreate = CSM.GetByID(self:GetModel(),self:EntIndex(),true)
	
	if isCreate then
		wm.attachments = {}	
		wm.container = CSM.GetContainer(self:EntIndex(),wm)
		wm.childrens = wm.container.childrens

		wm.csmContainerTag = self:EntIndex()
		wm.csmTag = "armor"
	end

	local pos,ang = self:GetPos(),self:GetAngles()

	wm:SetPos(pos)
	wm:SetAngles(ang)
	wm:DrawModel()

	if self.attachments and (not wm.childrens or #wm.childrens == 0) then
		for path,key in pairs(self.attachments) do
			attachmentGame.CreateAttachmentModel(self,wm,path,key)
		end
	end

	for i = 1,#wm.childrens do
		local mdl = wm.childrens[i]

		local Pos,Ang = LocalToWorld(mdl.localPos,mdl.localAng,pos,ang)

		mdl:SetPos(Pos)
		mdl:SetAngles(Ang)
		mdl:DrawModel()
	end
end