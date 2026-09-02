local ENT = oop.RegConnect("fake_ragdoll")
if not ENT then return end

ENT:Event_Add("Init","Main",function(self)
    self:SetupNWTable("Armor")

    self:SetWeapons({})
    self:SetupNWTable("Weapons")
end)

function ENT:GetActiveWeapon() end
function ENT:GetActiveSecondaryWeapon() end
function ENT:GetWeapons() return self.weapons end

function ENT:SetWeapons(itemList)
    local new = {}

    for i,item in pairs(itemList) do
        local class = GetClassFromName(item.spawnname)

        if not class or not class.CreateFakeSelfFromItem then continue end

        new[i] = fakeObject.CreateFakeObject(class,item).fake
    end

    self.weapons = new
    self.weaponsItems = itemList
end