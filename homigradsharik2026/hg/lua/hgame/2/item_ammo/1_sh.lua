local ENT,CLASS = oop.Reg("item_ammo",{"ent_resource_base"},true)
if not ENT then return INCLUDE_BREAK end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "hg_ammo_base"
ENT.Category = L("weapon_category_ammo")
ENT.Spawnable = true

ENT.itemType = "ammo"

ENT.InvCountLimit = 120

ENT:Event_Add("SetupDataTables","Ammo",function(self)
    self:NetworkVar("String","AmmoName")
end)

function ammoGame.GetTipText(item,config)
    local text = ""

    if config.Speed then text = text .. "Начальная скорость: " .. config.Speed .. " м/c\n" end
    if config.Mass then text = text .. "Вес: " .. config.Mass .. " грамм\n" end
    if config.Hardness then text = text .. "Твёрдость: " .. config.Hardness .. "\n" end

    if config.Diameter then text = text .. "Диаметр: " .. config.Diameter .. " мм\n" end
    if config.DragCoefficient then text = text .. "Балистический коофицент: " .. config.DragCoefficient .. "\n" end

    if config.Count and config.Count > 1 then text = text .. "Количество пуль в гильзе: " .. config.Count end

    return text
end

function ENT:InvSelectPanelDrawOver(w,h,icon,item)
    local config = ammoGame.config[item.data.ammoName]
    if not config then return end
    
    local text = ammoGame.GetTipText(item,config.bulletInfo)

    icon:DrawTip(text)
end

local white = Color(255,255,255)

function ENT:HUDTarget(ply,k,w,h)
    white.a = 255 * k * (1 - inventoryGame.InterfaceAnim)

    local config = ammoGame.config[self:GetAmmoName()]

    draw.SimpleText(L(config.printname) .. " " .. (self.InvCountLimit and self:GetInvCount()),"H.18",w / 2,h / 2 - 50 * (1 - k),white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end

function ENT:GetInvName(item)
    local config = ammoGame.config[item.data.ammoName]
    if not config then return item.data.ammoName end

    return config.printname
end

function ENT:GetInvSnd(item)
    local config = ammoGame.config[item.data.ammoName]
    if not config then return end

    return ammoGame.uiInvUse[ammoGame.config[item.data.ammoName].ShellSound]
end