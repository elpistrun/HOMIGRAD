function string.GetNameFromFilename(value)
	return string.Split(string.GetFileFromFilename(value),".")[1]
end

function string.SplitQMark(line)
	local wait

	local list = {}

	for i,str in pairs(TypeID(line) == TYPE_TABLE and line or string.Split(line," ")) do
		if string.sub(str,1,1) == '"' then
			wait = string.sub(str,2,#str)
		   
			if string.sub(wait,#wait,#wait) == '"' then
				list[#list + 1] = string.sub(wait,1,#wait - 1)
				
				wait = nil
			end

			continue
		end

		if wait then
			if string.sub(str,#str,#str) == '"' then
				wait = wait .. " " .. string.sub(str,1,#str - 1)

				list[#list + 1] = wait

				wait = nil
			else
				wait = wait .. " " .. str
			end
		else
			list[#list + 1] = str
		end
	end

	return list
end

local lowerRu = {
	["А"] = "а",
	["Б"] = "б",
	["В"] = "в",
	["Г"] = "г",
	["Д"] = "д",
	["Е"] = "е",
	["Ё"] = "ё",
	["Ж"] = "ж",
	["З"] = "з",
	["И"] = "и",
	["К"] = "к",
	["Л"] = "л",
	["М"] = "м",
	["Н"] = "н",
	["О"] = "о",
	["П"] = "п",
	["Р"] = "р",
	["С"] = "с",
	["Т"] = "т",
	["У"] = "у",
	["Ф"] = "ф",
	["Ц"] = "ц",
	["Ш"] = "ш",
	["Щ"] = "щ",
	["Ъ"] = "ъ",
	["Ы"] = "ы",
	["Ь"] = "ь",
	["Э"] = "э",
	["Ю"] = "ю",
	["Я"] = "я"
}

local lower = string.lower
local len,GetChar = utf8.len,utf8.GetChar

function string.utf8lower(text)
	local newText = ""

	local i = 1
	local sum = 0
	local max = len(text)

	::start::

	sum = GetChar(text,i,i)
	newText = newText .. (lowerRu[sum] or sum)
	
	i = i + 1
	if i <= max then goto start end

	return lower(newText)
end