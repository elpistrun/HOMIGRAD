-- Fix facial_emote: calcFlex/calcResetFlex are client-only but Think hook runs on server
if SERVER then
    -- Provide stub functions so the original Think hook doesn't error
    hook.Add("Initialize", "Fix_FacialEmote", function()
        if facialEmote and facialEmote.face then
            if not facialEmote.face.calcFlex then
                facialEmote.face.calcFlex = function() end
            end
            if not facialEmote.face.calcResetFlex then
                facialEmote.face.calcResetFlex = function() end
            end
        end
    end)
end
