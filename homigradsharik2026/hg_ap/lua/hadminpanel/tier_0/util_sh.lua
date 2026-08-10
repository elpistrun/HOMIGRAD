function adminPanel.GetArgsFromText(text)
    local args = string.Split(text," ")
	local newArgs = {}
	local waitClose,waitCloseText

	for i,text in pairs(args) do
		if not waitClose and string.sub(text,1,1) == "\"" then
			waitClose = true

			if string.sub(text,#text,#text) == "\n" then
				newArgs[#newArgs + 1] = string.sub(text,2,#text - 1)

				waitClose = nil
			else
				waitCloseText = string.sub(text,2,#text) .. " "
			end

			continue
		end

		if waitClose then
			if string.sub(text,#text,#text) == "\"" then
				waitClose = nil

				newArgs[#newArgs + 1] = waitCloseText .. string.sub(text,1,#text - 1)
			else
				waitCloseText = waitCloseText .. string.sub(text,1,#text)
			end

			continue
		end

		newArgs[#newArgs + 1] = text
	end

	return newArgs
end

function adminPanel.TimeToText(value)
    if value == "permament" then return "постоянно" end

    if value >= 60 * 60 * 24 * 30 then
        return math.floor(value / 60 / 60 / 24 / 30) .. " " .. L("months")
    elseif value >= 60 * 60 * 24 then
        return math.floor(value / 60 / 60 / 24) .. " " .. L("days")
    elseif value >= 60 * 60 then
        return math.floor(value / 60 / 60) .. " " .. L("hours")
    elseif value >= 60 then
        return math.floor(value / 60) .. " " .. L("minutes")
    else
        return math.floor(value) .. " " .. L("seconds")
    end
end

function adminPanel.TimeFromText(time)
    time = tostring(time)

    local endPrefix = string.sub(time,#time,#time)

    local timeLess = tonumber(string.sub(time,1,#time - 1))

    if endPrefix == "s" then
        time = timeLess
    elseif endPrefix == "M" then
        time = timeLess * 60
    elseif endPrefix == "h" then
        time = timeLess * 60 * 60
    elseif endPrefix == "d" then
        time = timeLess * 60 * 60 * 24
    elseif endPrefix == "w" then
        time = timeLess * 60 * 60 * 24 * 7
    elseif endPrefix == "m" then
        time = timeLess * 60 * 60 * 24 * 31
    elseif endPrefix == "y" then
        time = timeLess * 60 * 60 * 24 * 365//капяо
    else
        if tonumber(timeLess) or 0 <= 0 then 
            time = 0
        else
            time = tonumber(timeLess) or 0
        end
    end

    return time
end