donatPanel = donatPanel or {}
donatPanel.shop = donatPanel.shop or {}

function donatPanel.XPToText(xp)
    xp = tostring(xp)
    local text = ""

    for i = 1,math.ceil(#xp / 3) do
        if text == "" then
            text = string.sub(xp,math.max(#xp - 3 * i + 1,0),#xp - 3 * (i - 1))
        else
            text = string.sub(xp,math.max(#xp - 3 * i + 1,0),#xp - 3 * (i - 1)) .. " " .. text
        end
    end

    return text
end

function donatPanel.TimeToTextLess(timeAgo)
    local text
    if timeAgo < 60 then
        text = timeAgo .. " " .. L("seconds")
    elseif timeAgo < 60 * 60 then
        text = math.floor(timeAgo / 60) .. " " .. L("minutes")
    elseif timeAgo < 60 * 60 * 24 then
        text = math.floor(timeAgo / (60 * 60)) .. " " .. L("hours")
    else
        text = math.floor(timeAgo / (60 * 60 * 24)) .. " " .. L("days")
    end

    return text
end
