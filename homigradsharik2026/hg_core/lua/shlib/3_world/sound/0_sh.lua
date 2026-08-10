UNITS_TO_METERS = 0.01905

BALISTIC_SCALE = 0.7

SOUND_SPEED = 343 // в метрах

SOUND_ROOF_DISTANCE = 3000
SOUND_LESS_METERS_PLAY_INSTANT = 17.5

local filterEnt

local filterFuncByOneEntity

if SERVER then
    filterFuncByOneEntity = function(ent)
        if util.IsHumanoid(ent) or ent == filterEnt then return false end

        return true
    end
else
    filterFuncByOneEntity = function(ent)
        if util.IsHumanoid(ent) or GetViewEntity() == ent or ent == filterEnt then return false end

        return true
    end
end

local tr = {
    mask = MASK_SHOT,
    filter = filterFuncByOneEntity,
    output = {}
}

local max = math.max

local TraceLine = util.TraceLine

function sound.Trace(posend,earpos,filter)
    if CLIENT then
        if IsValid(filter) then
            return not filter:IsDormant()
        else
            tr.start = earpos
            tr.endpos = posend

            filterEnt = filter

            local result = TraceLine(tr)

            return result and result.HitPos:Distance(posend) <= 32
        end
    else
        tr.start = earpos
        tr.endpos = posend

        filterEnt = filter

        local result = TraceLine(tr)

        return result and result.HitPos:Distance(posend) <= 32
    end
end

local min,max = math.min,math.max

function sound.PitchDistance(pos,earPos,pitch)
    local dis = (earPos or (CLIENT and RenderView.origin)):Distance(pos) * UNITS_TO_METERS

    local sub = 30 * min(dis / 100,1)
    sub = sub * min(max(pitch - 30,0) / 10,1)

    return (pitch or 100) - sub
end

local filter

if SERVER then
    filter = function(ent)
        if util.IsHumanoid(ent) or ent.obbLenghtMetrs <= 3 then return false end

        return true
    end
else
    filter = function(ent)
        if util.IsHumanoid(ent) or ent.obbLenghtMetrs <= 3 or ent == GetViewEntity() then return false end

        return true
    end
end

local tr = {
    mask = MASK_SHOT,
    filter = filter,
    output = {}
}

local vecRoof = Vector(0,0,4096)
local VecSet = Vector()

function sound.GetPositionState(pos,filter)
    tr.start = pos
    tr.endpos = VecSet:Set(pos):Add(vecRoof)
    
    local result = util.TraceLine(tr)

    return result.Hit and not result.HitSky and "indoors" or "outdoors"
end

function sound.CreateFormatedListZero(snd,startValue,endValue,format)
    local list = {}

    for i = startValue,endValue do
        if i < 10 then
            list[#list + 1] = snd .. "0" .. i .. format
        else
            list[#list + 1] = snd .. i .. format
        end
    end

	return list
end

function sound.CreateFormatedList(snd,startValue,endValue,format)
    local list = {}

    for i = startValue,endValue do
        list[#list + 1] = snd .. i .. format
    end

	return list
end

if CLIENT then
    local delayCheck = 0

    event.Add("PreRender","sound.GetPositionState",function(ply,view)
        local time = RealTime()
        if delayCheck > time then return end
        delayCheck = time + 1 / 24
        
        SoundPositionState = sound.GetPositionState(RenderView.origin)
    end)
end

function sound.WaitDistance(metrs)
    if metrs <= SOUND_LESS_METERS_PLAY_INSTANT then return end
    
    local running = coroutine.running()
    timer.Simple(metrs / SOUND_SPEED,function() coroutine.resume(running) end)
    coroutine.yield()
end

if CLIENT then
    cvars.SetPermament("dsp_enhance_stereo","0")
    cvars.SetPermament("dsp_slow_cpu","0")
    cvars.SetPermament("snd_spatialize_roundrobin","0")
    cvars.SetPermament("snd_defer_trace","0")
    cvars.SetPermament("snd_surround_speakers","1")
    cvars.SetPermament("snd_disable_mixer_duck","0")

    cvars.SetPermament("dsp_room","0")
    cvars.SetPermament("dsp_water","14")
    cvars.SetPermament("dsp_spatial","40")

    local max,min,Clamp = math.max,math.min,math.Clamp

    local dir = Vector()

    function sound.PanoramaPos(src,minPanoramaDis,maxPanoramaDis,panoramaEffect)
        local ear = RenderView.origin

        minPanoramaDis = minPanoramaDis or 5
        maxPanoramaDis = maxPanoramaDis or 100

        local dis = src:Distance(ear) * UNITS_TO_METERS
        dir:Set(ear)
        dir:Sub(src)
        dir:Normalize()

        dis = max(dis,minPanoramaDis)
        dis = max(dis - minPanoramaDis) / (maxPanoramaDis - minPanoramaDis)
        
        dis = min(dis,1)

        if dis != 0 then
            if panoramaEffect then dis = Lerp(dis,0,panoramaEffect) end

            dir:Div(Lerp(dis,1,0.35))
        else
            dir:Div(1000)
        end

        src[1] = ear[1] - dir[1]
        src[2] = ear[2] - dir[2]
        src[3] = ear[3] - dir[3]
    end

    local vector_example = Vector()

    function sound.ThinkGoAway(ent)
        vector_example:Set(ent.pos)
        
        sound.PanoramaPos(vector_example,ent.minPanoramaDis,ent.maxPanoramaDis,ent.panoramaEffect)

        ent:SetPos(vector_example)
    end
end