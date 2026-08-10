local SWEP = oop.Get("hg_wep")
if not SWEP then return end

local iconSize = 64
local corner = vgui.corner

local color_gray = Color(128,128,128,128)

function SWEP:invUI(panel,item)
    panel:setW(panel:H() + iconSize * 2 + corner * 2)
    panel.icon:setX(iconSize + corner)

    --self:invUI_Ammo(panel,item)
end

function SWEP:invUI_Ammo(panel,item)
    local button = vCreate("v_button",panel):ad(function(self,w,h) self:setPos(iconSize + corner + panel:H() + corner,0):setSize(iconSize,iconSize) end)
    
    local ent = LocalPlayer():GetWeapon(item.spawnname)
    if not IsValid(ent) then return end
    
    local AmmoCalibre = self.Primary.AmmoCalibre

    function button:Draw(w,h)
        draw.RoundedBox(6,0,0,w,h,vgui.cBackground)

        local grabSlot = vgui.GetHoveredPanel() == self and inventoryGame.GrabSlot
        local grabItem = grabSlot and grabSlot:GetItem()
        
        local ammoClass = ent:GetAmmoClass()

        if ammoClass then
            ammoClass = ammoGame.config[ammoClass]

            local size = iconSize * (0.9 + self.hovered * 0.3)

            surface.SetDrawColor(255,255,255)
            surface.SetMaterial(MaterialHash(ammoClass.icon))
            surface.DrawTexturedRectRotated(w/2,h/2,size,size,math.cos(RealTime() * 10) * self.hovered)

            self:DrawTip("Нажмите что-бы разрядить оружие")
        else
            local canInput = grabItem and grabItem.data.ammoName and ammoGame.config[grabItem.data.ammoName].AmmoCalibre == AmmoCalibre
            
            ammoClass = ammoGame.config[ammoGame.callibreIndex[AmmoCalibre]]

            local size = iconSize * 0.9

            if grabItem and grabItem.data.ammoName then
                size = iconSize * (0.9 + self.hovered * 0.3)

                if canInput then
                    surface.SetDrawColor(255,255,255,128)
                    surface.SetMaterial(MaterialHash(ammoClass.icon))
                    surface.DrawTexturedRectRotated(w/2,h/2,size,size,math.cos(RealTime() * 10) * self.hovered * 12)
                else
                    surface.SetDrawColor(255,0,0,128)
                    surface.SetMaterial(MaterialHash(ammoClass.icon))
                    surface.DrawTexturedRectRotated(w/2,h/2,size,size,math.cos(RealTime() * 10) * self.hovered * 12)
                end
            else
                surface.SetDrawColor(0,0,0,128)
                surface.SetMaterial(MaterialHash(ammoClass.icon))
                surface.DrawTexturedRectRotated(w/2,h/2,size,size,0)
            end

            self:DrawTip(grabItem and (canInput and "Вставить этот патрон" or "Калибр неправильный") or "Оружие пустое")
        end
        
        DisableClipping(true)
        draw.SimpleText("КАЛИБР " .. AmmoCalibre,"H20",w + corner,h/2,color_gray,nil,TEXT_ALIGN_CENTER)
        DisableClipping(false)
    end

    function button:OnClick()
        if ent:GetAmmoClass() then
            ent:DoAction({name = "unload"})
        end
    end

    function button:CanMoveItem(grabSlot)
        local item = grabSlot:GetItem()

        ent:DoAction({name = ent.AnimationList.insert and "insert" or "load_magazine",ammoClient = {inv = item.inv.id,x = item.x,y = item.y,depth = item.depth}})

        return false
    end
end