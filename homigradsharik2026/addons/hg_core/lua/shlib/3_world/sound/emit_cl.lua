sound.vurtialEmitIndex = sound.vurtialEmitIndex or {}
local vurtialEmitIndex = sound.vurtialEmitIndex

if not sound.freeVurtialEmitList then
    sound.freeVurtialEmitList = {}

    for i = 1,8096 do
        sound.freeVurtialEmitList[i] = true
    end
end

local freeVurtialEmitList = sound.freeVurtialEmitList

local function removeFromIndex(self)
    if vurtialEmitIndex[self.sndID] == self then
        vurtialEmitIndex[self.sndID] = nil
        freeVurtialEmitList[self.sndID] = true
    end
end

function sound.GetVurtialEmit(pos,id,delay)
    if not id then
        for freeID in pairs(freeVurtialEmitList) do
            id = freeID
            freeVurtialEmitList[id] = nil
            break
        end
    end

    local srcEnt = vurtialEmitIndex[id]

    if IsValid(srcEnt) then
        srcEnt:SetPos(pos)
        srcEnt.sndTimeout = RealTime() + (delay or 3)
        
        return srcEnt
    end
    
    srcEnt = CSM.CreateClientSideModel("models/hunter/plates/plate.mdl")
    srcEnt:SetNoDraw(true)
    srcEnt:SetPos(pos)
    srcEnt.sndID = id
    srcEnt.sndTimeout = RealTime() + (delay or 3)
    srcEnt:CallOnRemove("sound.vurtialEmitList",removeFromIndex)

    vurtialEmitIndex[id] = srcEnt
    
    return srcEnt
end

event.Add("Think","sound.vurtialEmitList",function()
    local time = RealTime()
    
    for id,srcEnt in pairs(vurtialEmitIndex) do
        if not IsValid(srcEnt) or srcEnt.sndTimeout < time then
            if IsValid(srcEnt) then
                srcEnt:RemoveCallOnRemove("sound.vurtialEmitList")
                srcEnt:Remove()
            end

            vurtialEmitIndex[id] = nil
            freeVurtialEmitList[id] = true
        else
            if srcEnt.Think then srcEnt:Think() end
        end
    end
end)