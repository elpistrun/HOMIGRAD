local PLY = oop.Get("player_fake")
if not PLY then return end

PLY:Event_Add("Create","Other",function(self)
    self.color = Vector(1,1,1)
    self.skin = 0
    self.bodygroups = {}
end)

PLY:Event_Add("Create Model","Other",function(self,mdl)
    mdl.GetPlayerColor = function() return self:GetPlayerColor() end

    for id,value in pairs(self.bodygroups) do mdl:SetBodygroup(id,value) end

    mdl:SetSkin(self.skin)

    local materials = mdl:GetMaterials()

    local link = self.link

    if link then
        --[[for i = 0,#link:GetMaterials() - 1 do
            mdl:SetSubMaterial(i,link:GetSubMaterial(i))
        end]]--
    end
end)

function PLY:SetPlayerColor(color) self.color = color end
function PLY:GetPlayerColor() return self.color end

function PLY:SetBodygroup(id,value)
    self.bodygroups[id] = value
    if IsValid(self.mdl) then self.mdl:SetBodygroup(id,value) end
end

function PLY:ClearBodygroup(id,value)
    for k in pairs(self.bodygroups) do self.bodygroups[k] = nil end
end

function PLY:SetSkin(value)
    self.skin = value
    if IsValid(self.mdl) then self.mdl:SetSkin(value) end
end