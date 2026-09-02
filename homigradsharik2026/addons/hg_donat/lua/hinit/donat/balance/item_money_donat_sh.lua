local ITEM = inventoryManager:ItemReg("money_donat","base")
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

local colorYellow = Color(255,255,0)

function ITEM:DrawObject(w,h,panel,desc)
    local mdl = self:GetCSM("models/jmod/resources/ingot001.mdl")

    self:OpenScene(w,h,panel,40)
        render.SetColorModulation(2,2,0.5)
        mdl:SetAngles(Angle(0,90,90) + Angle(0,-10,-20))
        mdl:SetPos(Vector(80,0,-2))
        mdl:DrawModel()
        render.SetColorModulation(1,1,1)
    self:CloseScene(w,h,panel)
end

--https://soundcloud.com/diklordefenil/ne-prichyom-karakuli-slump-chuchu