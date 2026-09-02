local SWEP = oop.Get("tpik_animate")
if not SWEP then return end

local netName = "hg_animation_sync"

if SERVER then
    util.AddNetworkString(netName)

    local function CopyNetworkData(value,seen)
        if TypeID(value) != TYPE_TABLE then
            if TypeID(value) == TYPE_FUNCTION then return end
            return value
        end

        if seen[value] then return end
        seen[value] = true

        local result = {}
        for key,item in pairs(value) do
            if key == "parent" or key == "__index" then continue end

            local cleanKey = CopyNetworkData(key,seen)
            local cleanItem = CopyNetworkData(item,seen)
            if cleanKey != nil and cleanItem != nil then result[cleanKey] = cleanItem end
        end

        return result
    end

    function SWEP:SyncAnimation(recipients)
        local data
        if self.sequenceObject then
            data = CopyNetworkData(self.sequenceObject,{})
        end

        net.Start(netName)
        net.WriteEntity(self)
        net.WriteBool(data != nil)
        if data then net.WriteTable(data) end

        if recipients then
            net.Send(recipients)
        else
            net.SendPVS(self:GetPos())
        end
    end

    return
end

net.Receive(netName,function()
    local ent = net.ReadEntity()
    local hasAnimation = net.ReadBool()
    local data = hasAnimation and net.ReadTable() or nil

    if not IsValid(ent) or not ent.PlayAnimation then return end

    local result = ent:Event_Call("CanSequenceByServer",data)
    if result == false then return end

    if data and data.name then
        ent:PlayAnimation(data)
    else
        ent:ResetAnimation()
    end
end)
