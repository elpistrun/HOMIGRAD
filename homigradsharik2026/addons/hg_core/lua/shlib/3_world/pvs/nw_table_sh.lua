local ENTITY = FindMetaTable("Entity")

function ENTITY:SetupNWTable(name)
    self:InitPVS()

    self:ProxyPVSVar(name,function(_,old,new)
        local func = self["OnNWTable_" .. name]
        if func then func(self,new) end
    end)

    local value = self:GetPVSVar(name)

    if value then
        local func = self["OnNWTable_" .. name]
        if func then func(self,value) end
    else
        self:SetPVSVar(name,{})
    end
end

function ENTITY:GetNWTable(name)
    return self:GetPVSVar(name)
end

function ENTITY:SetNWTable(name,table)
    self:InitPVS()
    
    table = table or {}
    self:SetPVSVar(name,table)
end

fakeObject.fakeExample.GetNWTable = ENTITY.GetNWTable
fakeObject.fakeExample.SetNWTable = ENTITY.SetNWTable
