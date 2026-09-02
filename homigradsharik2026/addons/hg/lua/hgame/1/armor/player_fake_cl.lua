local function ConnectArmor()
    local PLY = oop.listClass["player_fake"] and oop.listClass["player_fake"][1]
    if not PLY then return end

    PLY:Event_Add("Create","Armor",function(self)
        armorGame.Create(self)
    end)

    PLY:Event_Construct()

    function PLY:UpdateArmors()
        if not IsValid(self.mdl) then return end

        armorGame.InitWorldModel(self.mdl,"player_fake",self.Armors)
    end

    PLY:Event_Add("Create Model","Armors",function(self)
        self:UpdateArmors()
    end)

    function PLY:GiveArmor(armorName,data,typeCall)
        if not self.Armors then armorGame.Create(self) end

        armorGame.Give(self.Armors,armorName,data,typeCall)

        self:UpdateArmors()
    end

    function PLY:RemoveArmor(armorName,typeCall)
        if not self.Armors then armorGame.Create(self) end

        armorGame.Remove(self.Armors,armorName,typeCall)

        self:UpdateArmors()
    end
end

if Initialize then
    ConnectArmor()
else
    event.Add("Initialize","Armor player_fake",ConnectArmor)
end