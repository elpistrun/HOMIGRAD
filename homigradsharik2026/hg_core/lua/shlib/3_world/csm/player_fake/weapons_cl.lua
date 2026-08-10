local PLY = oop.Get("player_fake")
if not PLY then return end

PLY:Event_Add("Create","Weapons",function(self)
    self.weapons = {}
end)

function PLY:GetWeapons() return self.weapons end

function PLY:GetActiveWeapon() return self.activeWeapon end
function PLY:SetActiveWeapon(wep) return wep end

function PLY:AddWeapon(wep)
    self.weapons[#self.weapons+1] = wep
end

function PLY:ClearWeapons()
    for k in pairs(self.weapons) do self.weapons[k] = nil end
end