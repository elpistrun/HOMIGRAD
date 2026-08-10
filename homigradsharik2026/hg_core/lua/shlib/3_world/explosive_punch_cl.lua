local punch = 0
local punchSide = 0

local punchSet,punchSideSet = 0,0

local punchEmit = function(pos,metrs,distance)
    if sound.Trace(pos) then return end

    local k = 1 * (1 - math.min(metrs / distance,1))

    local posScreen = pos:ToScreen()
    local kSide = (math.Clamp(posScreen.x,0,ScrW()) - ScrW() / 2) / (ScrW() / 2)

    kSide = math.Clamp(kSide * 10000,-1,1) * k

    punchSet = math.min(punchSet + k,k * 4)
    punchSideSet = math.min(punchSideSet + kSide,kSide * 4 )
end

function ExplosivePunch(pos,distance)
    local metrs = EyePos():Distance(pos) * UNITS_TO_METERS

    if metrs <= SOUND_LESS_METERS_PLAY_INSTANT then
        timer.GameSimple(metrs / SOUND_SPEED,punchEmit,pos,metrs,distance)
    else
        punchEmit(pos,metrs,distance)
    end
end

event.Add("PreCalcView","Explosive Punch",function(ply,view)
    view.angles:Add(Angle(punch * 3,punchSide * 6,-punchSide * 6 + math.Rand(-punch,punch)))
end)

hook.Add("Think","Explosive Punch",function()
    punch = LerpFTLess(0.5,punch,punchSet,0.001)
    punchSide = LerpFTLess(0.5,punchSide,punchSideSet,0.001)
    
    punchSet = LerpFTLess(0.1,punchSet,0,0.001)
    punchSideSet = LerpFTLess(0.1,punchSideSet,0,0.001)
end)