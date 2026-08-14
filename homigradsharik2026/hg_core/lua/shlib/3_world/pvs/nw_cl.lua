pvsAuto = pvsAuto or {}

function pvsAuto.ReadIndex()
    local typeValueID = net.ReadUInt(4)
    local typeName = pvsAuto.TYPE_ID_NET[typeValueID]
    local typeInfo = typeName and pvsAuto.TYPE_ID[typeName]
    if not typeInfo then return nil end

    return typeInfo[2]()
end

local ENTITY = FindMetaTable("Entity")

function ENTITY:OnChangePVSVar(name,old,new)
    self:CallProxyPVSVar(name,old,new)
end

local err = function(err) ErrorNoHaltWithStack(err) end

net.Receive("pvs_auto",function(len)
    local entIndex = net.ReadUInt(14)
    local var_name = net.ReadString()
    local value = pvsAuto.ReadIndex()

    coroutine.wrap(function()
        local ent = EntityCoroutine(entIndex)
        if not IsValid(ent) then return end--fuckyou

        ent:InitPVS()
        ent:SetPVSVar(var_name,value)
    end)()
end)

concommand.Add("hg_dev_pvs_entity",function(ply,cmd,args)
    local ent = ply:GetEyeTrace().Entity
    if not ent then return end

    print(ent)
    if not ent.pvsVarsValues then print("ent.pvsVarsValues == nul") return end
    
    PrintTable(ent.pvsVarsValues)
end)
