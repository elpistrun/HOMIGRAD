AddCSLuaFile()

local AddCSLuaFile = AddCSLuaFile
local include = include

local string_sub = string.sub
local string_split = string.Split
local string_find = string.find

local string_GetFileFromFilename = string.GetFileFromFilename

local validTag = {
	["cl"] = true,
	["sv"] = true,
	["sh"] = true
}

local function includeFile(path,isDevPath)
	local fileName = string_GetFileFromFilename(path)
	if string_sub(fileName,1,1) == "!" then return end

	local split = string_split(fileName,"_")
	local prefix

	prefix = split[1]
	prefix = #prefix == 2 and string_sub(prefix,1,2) or ""
	
	if not validTag[prefix] then
		prefix = split[#split]
		prefix = string_sub(prefix,1,2)

		if not validTag[prefix] then return end--lol4ik
	end

	if prefix == "cl" then
		if SERVER then
			if not isDevPath or DEV then AddCSLuaFile(path) end
		else
			return include(path)
		end
	elseif prefix == "sv" then
		if SERVER then return include(path) end
	elseif prefix == "sh" then
		if SERVER then
			if not isDevPath or DEV then AddCSLuaFile(path) end
		end
		
		return include(path)
	end
end


local string_gsub = string.gsub

INCLUDE_BREAK = 1
INCLUDE_BREAK_CLIENT = 2

local file_Find = file.Find

function IncludeDir(path,isDevPath)
	local _files,_dirs = file_Find(path .. "*","LUA")

	--

	local files = {}
	local tier_files = {}

	for i = 1,#_files do
		local file = _files[i]

		local prefix = string_sub(file,1,1)
		if prefix == "!" then continue end

		local old = #tier_files
		local split = string_split(file,"_")

		for i = 1,#split do
			if split[i] == "tier" or split[i] == "t" then tier_files[#tier_files + 1] = file break end
		end

		if old != #tier_files then continue end

		files[#files+1] = file
	end

	--

	local dirs = {}
	local tier_dirs = {}

	for i = 1,#_dirs do
		local dir = _dirs[i]

		local prefix = string_sub(dir,1,1)
		if prefix == "!" then continue end

		local old = #tier_dirs
		local split = string_split(dir,"_")

		for i = 1,#split do
			if split[i] == "tier" or split[i] == "t" then tier_dirs[#tier_dirs + 1] = dir break end
		end

		if old != #tier_dirs then continue end

		dirs[#dirs+1] = dir
	end

	--

	for i = 1,#tier_files do
		local prefix = string_sub(tier_files[i],1,1)
		local file = path .. tier_files[i]
		local ok,res = pcall(includeFile,file,isDevPath or prefix == "#")

		if not ok then ErrorNoHalt("\t[hg_core] error in\n\t" .. file .. "\n" .. res .. "\n") end
		if res == INCLUDE_BREAK then return end
	end

	for i = 1,#files do
		local prefix = string_sub(files[i],1,1)
		local file = path .. files[i]
		local ok,res = pcall(includeFile,file,isDevPath or prefix == "#")

		if not ok then ErrorNoHalt("\t[hg_core] error in\n\t" .. file .. "\n" .. res .. "\n") end
		if res == INCLUDE_BREAK then return end
	end

	for i = 1,#tier_dirs do
		local prefix = string_sub(tier_dirs[i],1,1)
		local dir = path .. tier_dirs[i] .. "/"
		local ok,err = pcall(IncludeDir,dir,isDevPath or prefix == "#")

		if not ok then ErrorNoHalt("\t[hg_core] error in IncludeDir\n\t" .. dir .. "\n" .. err .. "\n") end
	end
	for i = 1,#dirs do
		local prefix = string_sub(dirs[i],1,1)
		local dir = path .. dirs[i] .. "/"
		local ok,err = pcall(IncludeDir,dir,isDevPath or prefix == "#")

		if not ok then ErrorNoHalt("\t[hg_core] error in IncludeDir\n\t" .. dir .. "\n" .. err .. "\n") end
	end
end

local string_sub,string_explode,string_gsub,string_find = string.sub,string.Explode,string.gsub,string.find

local traceback = debug.traceback

GetPath = function(levelDown)
	levelDown = 3 + (levelDown or 0)

	local trace = traceback()
	trace = string_sub(trace,19,#trace)
	
	trace = string_explode("\n",trace)
	trace = trace[levelDown]
	trace = string_gsub(trace,"	","")
	trace = string_sub(trace,1,string_find(trace,":") - 1)

	if string_sub(trace,1,7) == "addons/" then
		trace = string_sub(trace,8,#trace)
		trace = string_sub(trace,string_find(trace,"/") + 1,#trace)
		trace = string_sub(trace,string_find(trace,"/") + 1,#trace)

		return trace
	elseif string_sub(trace,1,4) == "lua/" then
		return string_sub(trace,5,#trace)
	end

	return trace
end

hook.Add("Initialize","SHLib",function()
	if event and event.Call then event.Call("Initialize") end

	Initialize = true
end)

hook.Add("InitPostEntity","!SHLib",function()
	InitPostEntity = true

	if event and event.Call then event.Call("InitPostEntity") end
end)