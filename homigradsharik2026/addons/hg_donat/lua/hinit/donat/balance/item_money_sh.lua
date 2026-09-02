local ITEM = inventoryManager:ItemReg("money","base")
if not ITEM then return end

ITEM.type = "accessories"

function ITEM:GetDesc()
    return "Бутафория"
end

function ITEM:GetPrintName()
    return tostring(self.data.money or 0)
end

function ITEM:GetRaryType()
    local money = self.data.money or 0

    if money <= 200 then
        return "uncommon"
    elseif money < 1000 then
        return "rary"
    else
        return "legendary"
    end
end

//

function ITEM:DrawObject(w,h,panel,desc)
    local mdl = self:GetCSM("models/props/cs_assault/money.mdl")

    self:OpenScene(w,h,panel,12)
        mdl:SetAngles(Angle(0,90,90) + Angle(0,-10,-20))
        mdl:SetPos(Vector(80,0,-0.5))
        mdl:DrawModel()
    self:CloseScene(w,h,panel)
end

--https://soundcloud.com/diklordefenil/ne-prichyom-karakuli-slump-chuchu