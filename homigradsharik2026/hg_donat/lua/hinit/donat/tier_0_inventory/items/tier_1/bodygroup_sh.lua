local ITEM = inventoryManager:ItemReg("bodygroup",{"base","base_count"})
if not ITEM then return end

ITEM.category = "2_accessories"

local bodygroups = {
    {
        name = "Bodygroup 1",
        desc = "donat_item_bodygroup1_desc",
        raryType = "uncommon",
        xp = 100
    },
    {
        name = "Bodygroup 5",
        desc = "donat_item_bodygroup2_desc",
        raryType = "rary",
        xp = 500
    },
    {
        name = "Bodygroup 10",
        desc = "donat_item_bodygroup3_desc",
        raryType = "legendary",
        xp = 1000
    },
    {
        name = "Bodygroup 100",
        desc = "donat_item_bodygroup4_desc",
        raryType = "epic",
        xp = 10000
    }
}

function ITEM:GetInfo()
    return bodygroups[tonumber(self.type or 1) or 1] or bodygroups[1]
end

function ITEM:GetDesc()
    return self:GetInfo().desc
end

function ITEM:GetPrintName()
    return self:GetInfo().name
end

function ITEM:GetRaryType()
    return self:GetInfo().raryType
end

//

function ITEM:DrawObject(w,h,panel,desc)
    local mdl = self:GetCSM("models/combine_helicopter/helicopter_bomb01.mdl",desc)

    self:OpenScene(w,h,panel,20)
        mdl:SetAngles(Angle(-20,-45,-30))
        mdl:SetPos(Vector(10,0,0))
        mdl:DrawModel()
    self:CloseScene(w,h,panel)

    self:DrawCount(w,h,panel,desc)
end