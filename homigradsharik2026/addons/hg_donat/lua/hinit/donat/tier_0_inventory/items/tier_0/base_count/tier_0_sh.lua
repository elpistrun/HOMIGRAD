local ITEM,NoInherit = inventoryManager:ItemReg("base_count",nil,true)
if not ITEM then return INCLUDE_BREAK end

NoInherit.doNotShowInUI = true

ITEM.MaxCount = 250

function ITEM:GetCount()
    return tonumber(self.data.count or 1)
end

if SERVER then return end

function ITEM:DrawCount(w,h,panel,desc)
    if desc then
        draw.SimpleText("количество " .. self:GetCount() .. "x","HS.25",w/2,h - 16,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
    elseif panel.type != "shop" then
        local count = self:GetCount()
        if count == 1 then return end
        
        draw.SimpleText(count,"HS.12",w/2,8,nil,TEXT_ALIGN_CENTER)
    end
end
