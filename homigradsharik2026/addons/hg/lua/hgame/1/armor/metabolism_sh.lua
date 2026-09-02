local function Update(Armor)
    local subStamina,subSpeed = 1,1

    for armorName,armorData in pairs(Armor.native) do
        local config = armorGame.GetConfig(armorData)

        if config.subStamina then subStamina = subStamina - config.subStamina end
        if config.subSpeed then subSpeed = subSpeed - config.subSpeed end
    end

    Armor.parent.armor_subStamina = subStamina
    Armor.parent.armor_subSpeed = subSpeed
end

armorGame:Event_Add("Give","Stamina",function(Armor,armorName,data,callType)
    Update(Armor)
end,10)

armorGame:Event_Add("Remove","Stamina",function(Armor,armorName,data,callType)
    Update(Armor)
end,10)

event.Add("Stamina Sub","Armor",function(ply,value)
    local subStamina = (ply.armor_subStamina or 1)

    value[1] = value[1] * subStamina
end)

event.Add("Move","Armor",function(ply,mv)
    local subSpeed = (ply.armor_subSpeed or 1)

    if ply:IsSprinting() then
        local maxspeed = mv:GetMaxSpeed()

        maxspeed = maxspeed * subSpeed
        
        mv:SetMaxSpeed(maxspeed)
        mv:SetMaxClientSpeed(maxspeed)
    end
end)