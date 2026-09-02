local SafeFromSend
SafeFromSend = function(parent)
    local type = TypeID(parent)

    if type == TYPE_FUNCTION then
        return nil
    elseif type == TYPE_DAMAGEINFO then
        return nil
    elseif type == TYPE_TABLE then
        for k,v in pairs(parent) do
            k = SafeFromSend(k)
            if not k then parent[k] = nil continue end

            parent[k] = SafeFromSend(v)
        end
    end

    return parent
end

function net.SafeFromSend(tbl)
    local new = util.tableCopy(tbl)
    
    SafeFromSend(new)

    return new
end

if CLIENT then
    function Ping(ply)
        if ply and ply == LocalPlayer() then
            return 0
        else
            return LocalPlayer():Ping() / 1000
        end
    end
else
    function Ping(ply)
        if IsValid(ply) then
            return ply:Ping() / 1000
        else
            return 0
        end
    end
end

function PingTick(ply)
    return math.ceil(Ping(ply) / TickInterval())
end

function PingTickHalf(ply)
    return math.ceil(PingTick(ply) / 2)
end

function UnPredictedCurTimeTick() return math.Round(UnPredictedCurTime() / TickInterval()) * TickInterval() end