local INV = oop.RegConnect("inv_base")
if not INV then return end

if SERVER then
    INV:Event_Add("Sync","ArmorName",function(self,pkg,ply)
        pkg.armorName = self.armorName
    end)
else
    INV:Event_Add("Sync","ArmorName",function(self,pkg,ply)
        if pkg.armorName != nil then self.armorName = pkg.armorName end
    end)
end