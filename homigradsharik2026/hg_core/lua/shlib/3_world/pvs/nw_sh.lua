pvsAuto = pvsAuto or {}

TYPE_PVS_COMPRESS_DATA = "TYPE_PVS_COMPRESS_DATA"

pvsAuto.TYPE_ID = {
    ["none"] = {function() end,function() return nil end},
    [TYPE_STRING] = {net.WriteString,net.ReadString},
    [TYPE_NUMBER] = {function(value) net.WriteString(tostring(value)) end,function() return tonumber(net.ReadString()) end},
    [TYPE_TABLE] = {net.WriteTable,net.ReadTable},
    [TYPE_BOOL] = {net.WriteBool,net.ReadBool},
    [TYPE_VECTOR] = {net.WriteVector,net.ReadVector},
    [TYPE_ANGLE] = {net.WriteAngle,net.ReadAngle},
    [TYPE_PVS_COMPRESS_DATA] = {
        function(value)
            local compress = util.Compress(value)
            net.WriteUInt(#compress,16)
            net.WriteData(compress)
        end,
        function()
            local bytes_count = net.ReadUInt(16)
            return util.Decompress(net.ReadData(bytes_count))
        end
    }
}

local TYPE_ID_NET = {}
pvsAuto.TYPE_ID_NET = TYPE_ID_NET

for name,info in pairs(pvsAuto.TYPE_ID) do
    TYPE_ID_NET[#TYPE_ID_NET + 1] = name
    info.net_pkg_id = #TYPE_ID_NET
end

pvsAuto.InitPVS = function(self)
    if self.pvsVarsValues then return end

    self.pvsVarsValues = {}

    if SERVER and TypeID(self) == TYPE_ENTITY then pvsAuto.Insert(self) end
end

pvsAuto.ProxyPVSVar = function(self,name,func)
    if not self.pvsVarsCallback then self.pvsVarsCallback = {} end

    self.pvsVarsCallback[name] = func
end

local err = function(err) ErrorNoHaltWithStack(err) end

pvsAuto.CallProxyPVSVar = function(self,name,old,new)
    if not self.pvsVarsCallback then return end

    local func = self.pvsVarsCallback[name]
    if func then xpcall(func,err,self,old,new) end
end

pvsAuto.SetPVSVar = function(self,name,value,typeValue)
    if not self.pvsVarsValues then self:InitPVS() end

    local varValue = self.pvsVarsValues[name]
    
    if not varValue then
        varValue = {}
        self.pvsVarsValues[name] = varValue
    end

    varValue.value = value
    varValue.type = typeValue

    if TypeID(value) == TYPE_TABLE then
        local valueJSON = util.TableToJSON(value)
        
        if varValue.oldValue == valueJSON then return end
        varValue.oldValue = valueJSON
    else
        if varValue.oldValue == value then return end
        varValue.oldValue = value
    end

    if self.OnChangePVSVar then self:OnChangePVSVar(name,varValue.oldValue,value) end
end

pvsAuto.GetPVSVar = function(self,name,def)
    if not self.pvsVarsValues then return end

    local value = self.pvsVarsValues[name]
    if not value then return def end

    value = value.value
    if value == nil then return def end

    return value
end

--

local ENTITY = FindMetaTable("Entity")

ENTITY.InitPVS = pvsAuto.InitPVS
ENTITY.ProxyPVSVar = pvsAuto.ProxyPVSVar
ENTITY.CallProxyPVSVar = pvsAuto.CallProxyPVSVar
ENTITY.SetPVSVar = pvsAuto.SetPVSVar
ENTITY.GetPVSVar = pvsAuto.GetPVSVar

local PLAYER = FindMetaTable("Player")

PLAYER.InitPVS = pvsAuto.InitPVS
PLAYER.ProxyPVSVar = pvsAuto.ProxyPVSVar
PLAYER.CallProxyPVSVar = pvsAuto.CallProxyPVSVar
PLAYER.SetPVSVar = pvsAuto.SetPVSVar
PLAYER.GetPVSVar = pvsAuto.GetPVSVar

fakeObject:Event_Add("Create","PVS",function(fake)
    ENTITY.InitPVS(fake)

    fake.ProxyPVSVar = pvsAuto.ProxyPVSVar
    fake.CallProxyPVSVar = pvsAuto.CallProxyPVSVar
    fake.SetPVSVar = pvsAuto.SetPVSVar
    fake.GetPVSVar = pvsAuto.GetPVSVar
end)