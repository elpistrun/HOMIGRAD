inventoryGame:Event_Add("PanelConstruct","Parse Inv",function(inv,panel)
    local parent = inv.parent

    if inv.ClassName == "inv_player" then
        parent.inv = inv
        inv:Event_Add("Remove",parent:EntIndex() .. "inv",function() parent.inv = nil end)
    end

    if inv.ClassName == "inv_armor" then
        parent.invArmor = inv
        inv:Event_Add("Remove",parent:EntIndex() .. "invArmor",function() parent.invArmor = nil end)
    end

    if inv.ClassName == "inv_dump" then
        parent.invDump = inv
        inv:Event_Add("Remove",parent:EntIndex() .. "invDump",function() parent.invDump = nil end)
    end

    if inv.ClassName == "inv_backpack" then
        parent.invBackpack = inv
        inv:Event_Add("Remove",parent:EntIndex() .. "invBackpack",function() parent.invBackpack = nil end)
    end
end,-100)