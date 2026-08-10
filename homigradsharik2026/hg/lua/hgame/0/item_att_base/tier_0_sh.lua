local ENT = oop.Reg("item_att_base","base_entity",true)
if not ENT then return INCLUDE_BREAK end

function ENT:Initialize() end

function ENT:GetConfig() return _G[self.CONFIG[1]][self.CONFIG[2]] end

function ENT:SetupDataTables()
	self:NetworkVar("String","AttachmentName")
end

function ENT:GetInvName(item)
	local config = self:GetConfig()[item.data.attachmentName]

	return config and config.printName or config.name or item.spawnname
end

function ENT:invUI_Draw(panel,item)
	local config = self:GetConfig()[item.data.attachmentName or "null"]
	if not config then draw.SimpleText(item.data.attachmentName or "null att name",nil,nil,nil,Color(255,0,0)) return end

	local w,h = panel:W(),panel:H()

	surface.SetMaterial(Material(config.icon))
	local size = h - 14 + (panel.hovered or 0) * 5

	surface.SetDrawColor(255,255,255)
	surface.DrawTexturedRect(w / 2 - size / 2 + 1,h / 2 - size / 2 + 1,size,size)
end

local color = Color(255,255,255)

function ENT:HUDTarget(ent,k,w,h)
	local config = self:GetConfig()[self:GetAttachmentName()]
	if not config then return end
	
	HUDTargetRenderText(config.printName or config.name or item.spawnname,k,color)
end
