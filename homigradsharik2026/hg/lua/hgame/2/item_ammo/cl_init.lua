local ENT = oop.Get("item_ammo")
if not ENT then return end

function ENT:invUI_Draw(panel,item)
	local w,h = panel:W(),panel:H()

	local config = ammoGame.config[item.data.ammoName]

	if not config or not config.icon then
		local x,y = panel:LocalToScreen()
                
		--DrawWeaponSelectionEX(self,x,y,w,h - 13,true,-slotPanel.hovered * 1)
	else
		local size = h - 14 + (panel.hovered or 0) * 5

		surface.SetMaterial(MaterialHash(config.icon))

		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRect(w / 2 - size / 2 + 1,h / 2 - size / 2 + 1,size,size)	
	end

	if not panel.drawtype then
		if item.data.count <= 0 then return end
		
		draw.SimpleText("x" .. item.data.count,"InvFont",4,2)
	end
end