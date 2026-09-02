local ENTITY = FindMetaTable("Entity")

ENTITY.GetDummy = function(self)
    local result = self:GetPVSVar("Dummy") or -1
    if result == -1 then return self end

    result = Entity(result)
    if not IsValid(result) then return self end

    return result
end

ENTITY.SetDummy = function(self,ent) return self:SetPVSVar("Dummy",IsValid(ent) and ent:EntIndex() or -1) end

ENTITY.GetController = function(self)
    local result = self:GetPVSVar("Controller") or -1
    if result == -1 then return end

    result = Entity(result)
    if not IsValid(result) then return end

    return result
end

ENTITY.SetController = function(self,ent) return self:SetPVSVar("Controller",IsValid(ent) and ent:EntIndex() or -1) end

FindMetaTable("Player").GetVehicleEntity = function(self)
    local vehicle = self:GetVehicle()
    if not IsValid(vehicle) then return end
    
    local parent = vehicle:GetNWEntity("Parent",vehicle:GetParent())

    return IsValid(parent) and parent or vehicle
end

local vector = Vector(1,1,1)

ENTITY.GetPlayerVector = function(self) return self:SetPVSVar("PlayerColor",vector) end
ENTITY.SetPlayerVector = function(self,vector) self:GetPVSVar("PlayerColor",vector) end

util.tableLink(FindMetaTable("Player"),oop.listClass.lib_event[1])