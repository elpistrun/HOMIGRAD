local earrapeSet = 0
local earrape = 0

EarrapeSound = nil

hook.Add("Think","Earrape",function()
    if not LocalPlayer():Alive() then
        earrapeSet = 0
        earrape = 0
    end

    earrapeSet = math.max(earrapeSet - FrameTime() / 30,0)
    
    if earrape < earrapeSet then
        earrape = LerpFT(1,earrape,earrapeSet)
    else
        earrape = math.max(earrape - FrameTime() / 30,0)
    end

    if not EarrapeSound then
        EarrapeSound = CreateSound(LocalPlayer(),"homigrad/earraopoee.wav")
    end

    if earrape <= 0 then EarrapeSound:Stop() return end

    if not EarrapeSound:IsPlaying() then EarrapeSound:PlayEx(0,100) end

    EarrapeSound:ChangeVolume(earrape,0.1)
end)

function sound.GiveEarrapeOfPos(pos,radius)
    local metrs = EyePos():Distance(pos) * UNITS_TO_METERS

    local add = (1 - math.min(metrs / (radius * UNITS_TO_METERS),1)) / 4
    if add < 0.06 then return end

    if not sound.Trace(pos,RenderView.origin) then return end
    
    if metrs > SOUND_LESS_METERS_PLAY_INSTANT then
        timer.GameSimple(metrs / SOUND_SPEED,function() earrapeSet = math.min(earrapeSet + add,add) end)
    else
        earrapeSet = math.min(earrapeSet + add,add)
    end
end

function sound.GiveEarrape(add)
    earrapeSet = earrapeSet + add
end