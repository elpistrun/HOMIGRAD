local ENT = oop.Reg("item_att_weapon","item_att_base",true)
if not ENT then return INCLUDE_BREAK end

ENT.CONFIG = {"attachmentGame","config"}

ENT.Spawnable = true
ENT.Category = "Оружие: Модули"

ENT.InvSnd = {list = {"homigrad/inventory/attachment_use.wav"},pitch = 200,volume = 0.2}

function ENT:InvSelectPanelDrawOver(w,h,icon,item)
    local config = attachmentGame.config[item.data.attachmentName]
    
    icon:DrawTip(config.desc or "")
end