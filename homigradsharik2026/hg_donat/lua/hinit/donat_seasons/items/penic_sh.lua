local ITEM = inventoryManager:ItemReg("penic","base")
if not ITEM then return end

ITEM.type = "3_icons"

function ITEM:GetDesc()
    return "что-то очень стран0е<br>может пыть это потроны?.. а можэетэ этооою....<br>3008701283!!!!!11 XD"
end

function ITEM:GetPrintName()
    return "привлекательное"
end

function ITEM:GetRaryType()
    return "epic"
end
//

function ITEM:DrawObject(w,h,panel,desc)
    local mdl,create = CSM.GetByID("models/wierd/dildo.mdl",tostring(self))
    if create then mdl:SetNoDraw(false) end

    self:OpenScene(w,h,panel,15)
        mdl:SetAngles(Angle(0,-45,0))
        mdl:SetPos(Vector(0,0,-10))
        mdl:DrawModel()
    self:CloseScene(w,h,panel)
end

