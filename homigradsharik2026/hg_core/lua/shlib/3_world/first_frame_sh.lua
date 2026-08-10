local frameNumber = 0
local frameNumberRender = 0

function IsFirstFrame(self,tag)
    if self[tag] != frameNumber then
        self[tag] = frameNumber

        return true
    else
        return false
    end
end

if CLIENT then
    event.Add("PreRender","SetFirstFrameNumber",function()
        frameNumber = FrameNumber()
    end,-1000)

    function ClearRenderFrame()
        frameNumberRender = 1024 + (frameNumberRender + 1) % 1024
    end

    function IsFirstRenderFrame(self,tag)
        if self[tag] != frameNumberRender then
            self[tag] = frameNumberRender

            return true
        else
            return false
        end
    end
else
    event.Add("Think","SetFirstFrameNumber",function()
        frameNumber = FrameNumber() % 1024
    end,-1000)
end