local ENT = oop.Reg("item_att_armor","item_att_base",true)
if not ENT then return INCLUDE_BREAK end

ENT.Category = "Снарежение: Модули"
ENT.Spawnable = true

ENT.CONFIG = {"attachmentGame","config"}

if SERVER then return end

function ENT:InvSelectPanelDrawOver(w,h,icon,item)
	local config = attachmentGame.config[item.data.attachmentName]

	if config.armorTier then
		draw.SimpleText(armorGame.ArmorTierIndex[config.armorTier].name,"HS.18",w/2,12,nil,TEXT_ALIGN_CENTER)
	end

	icon:DrawTip(armorGame.GetTipText(item.data,config))
end

function ENT:DrawInvPost(inv,panel,item)
	local config = attachmentGame.config[item.data.attachmentName]

	if config.DrawInvPost then config.DrawInvPost(self,panel,item) end
end

function ENT:invUI(panel,item)
	local w,h = panel:W(),panel:H()

	panel:setW(h)

    local itemArmor = item.inv.itemArmor
    if not itemArmor then return end

    local config = attachmentGame.config[item.data.attachmentName]

	if config.invUI then config.invUI(self,panel,item) return end
	
    armorGame.ConstructTogglePanel(panel,item,config)
end

local list = {
	list = {},
	volume = 1,
	pitch = 120
}

function ENT:GetInvSnd(item,soundName)
	local config = attachmentGame.config[item.data.attachmentName]

	if soundName == "InvMoveFromSnd" then
		list.list[1] = config.soundDrop
		list.pitch = 100
	else
		list.pitch = 100
		list.list[1] = config.soundPickup
	end

	return list
end