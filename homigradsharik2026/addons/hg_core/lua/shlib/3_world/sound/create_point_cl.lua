sound.pointIndex = sound.pointIndex or setmetatable({},{__mode = "k"})

local POINT = {}
POINT.__index = POINT

function POINT:IsValid()
    return not self.removed and IsValid(self.entity)
end

function POINT:Play()
    if not self:IsValid() then return false end

    if not self.patch then
        self.patch = CreateSound(self.entity,self.soundName)
        if not self.patch then return false end
        if self.level then self.patch:SetSoundLevel(self.level) end
    end

    local started = not self.patch:IsPlaying()
    if started then
        self.patch:PlayEx(self.volume or 1,(self.pitch or 1) * 100)
    else
        self.patch:ChangeVolume(self.volume or 1,0)
        self.patch:ChangePitch((self.pitch or 1) * 100,0)
    end

    return started
end

function POINT:Stop()
    if self.patch then self.patch:Stop() end
end

function POINT:Remove()
    if self.removed then return end

    self.removed = true
    self:Stop()
    sound.pointIndex[self] = nil
end

function sound.CreatePoint(entity,soundName,level,channel)
    if not IsValid(entity) or not isstring(soundName) then return end

    local point = setmetatable({
        entity = entity,
        soundName = soundName,
        level = level or 75,
        channel = channel,
        volume = 1,
        pitch = 1
    },POINT)

    sound.pointIndex[point] = true

    entity:CallOnRemove("HG Sound Point " .. tostring(point),function()
        point:Remove()
    end)

    return point
end

hook.Add("Think","HG Sound Points",function()
    for point in pairs(sound.pointIndex) do
        if not point:IsValid() then
            point:Remove()
        elseif point.patch and point.patch:IsPlaying() then
            point.patch:ChangeVolume(point.volume or 1,0)
            point.patch:ChangePitch((point.pitch or 1) * 100,0)
        end
    end
end)
