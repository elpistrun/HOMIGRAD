local ITEM = inventoryManager:ItemReg("icon_true_old","base")
if not ITEM then return end

ITEM.type = "3_icons"
ITEM.cantTrade = true

function ITEM:GetDesc()
    return "Выдано тем наиграл 100 часов до появления донат инвентаря\nНастоящий поцык! красавчик!\nНельзя обменять."
end

function ITEM:GetPrintName()
    return "Настоящий old!"
end

function ITEM:GetRaryType()
    return "epic"
end
//

function ITEM:DrawObject(w,h,panel,desc)
    local mdl,create = CSM.GetByID("models/pwb/weapons/w_hk416.mdl",tostring(self))
    if create then mdl:SetNoDraw(false) end

    self:OpenScene(w,h,panel,20)
        mdl:SetAngles(Angle(-45,-90,0))
        mdl:SetPos(Vector(0,-8,0))
        mdl:DrawModel()
    self:CloseScene(w,h,panel)
end