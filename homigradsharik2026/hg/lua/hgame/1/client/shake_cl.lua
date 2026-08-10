if not HScreenShake then HScreenShake = util.ScreenShake end

local pointShakes = {}

local Player = FindMetaTable("Player")
if not HViewPunch then HViewPunch = Player.ViewPunch end

if SERVER then
    util.AddNetworkString("shake")
    util.AddNetworkString("punch")

    function Player:ViewPunch(ang)
        net.Start("punch",true)
        net.WriteAngle(ang)
        net.Send(self)
    end
else
    net.Receive("shake",function()
        util.ScreenShake(net.ReadVector(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadBool())
    end)

    net.Receive("punch",function()
        LocalPlayer():ViewPunch(net.ReadAngle())
    end)
end

function util.ScreenShake(pos,amp,freq,dur,radius,airshake,filter)
    dur = math.min(dur,1)

    HScreenShake(pos,amp,freq,dur,radius,airshake,filter)

    if SERVER then
        net.Start("shake")
        net.WriteVector(pos)
        net.WriteFloat(amp)
        net.WriteFloat(freq)
        net.WriteFloat(dur)
        net.WriteFloat(radius)
        net.WriteBool(airshake)
        if filter then net.Send(filter) else net.Broadcast() end
    else
        pointShakes[{pos,amp,freq,RealTime(),dur,radius,airshake}] = true
    end
end

if SERVER then return end

local viewPunch = Angle()

function Player:ViewPunch(ang) viewPunch:Add(ang) end

local Rand = math.Rand

local delay = 0
local dirSet = Vector()
local dir = Vector()

local fuck = 0 / 0

event.Add("PreCalcView","Shake",function(ply,view)
    local vec = view.vec

    view.ang:Add(viewPunch)
    viewPunch:LerpFT(0.1)

    local time = RealTime()

    local amp = 0
    local freq = 0

    local isOnGround = ply:IsOnGround()

    for point in pairs(pointShakes) do
        if not point[7] and not isOnGround then continue end

        local t = (point[4] + point[5] - time) / point[5]
        if t <= 0 then pointShakes[point] = nil continue end

        local k = math.max((point[6] - point[1]:Distance(vec)) / point[6],0) * t

        local _amp,_freq = point[2] * k,point[3]

        if amp < _amp then amp = _amp end
        if freq < _freq then freq = _freq end
    end

    freq = math.Clamp(freq,1,10)

    local t = 1 / freq

    if freq > 0 then
        amp = math.Clamp(amp / 10,0,10)

        if delay + t < time then
            delay = time
            dirSet:Set(Vector(1,0,0):Rotate(Angle(Rand(-180,180),Rand(-180,180),Rand(-180,180))))
        end

        dir:LerpFT(math.Clamp(freq / 44,0.25,0.5),LerpVector(1 - math.Clamp((delay + t - time) / t,0,1),dir,dirSet))

        vec:Add(dir * (amp or 0))
    end
end,6)

concommand.Add("shake2",function()
    print(dir,amp)

    util.ScreenShake(LocalPlayer():GetPos(),2,40,1,512)
end)

