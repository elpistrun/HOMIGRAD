local copy
copy = function(obj,seen)
	if type(obj) ~= "table" then return obj end
	if seen[obj] then return seen[obj] end

	local res = {}

	seen[obj] = res

	for k,v in pairs(obj) do res[copy(k,seen)] = copy(v,seen) end

	return res
end

function util.tableCopy(obj)
	local seen = {}
	local result = copy(obj,seen)

	return result,seen
end--https://gist.github.com/tylerneylon/81333721109155b2d244

function util.tableChange(tbl,source)
	for k in pairs(tbl) do tbl[k] = nil end

	for k,v in pairs(source) do
		tbl[k] = v
	end
end

function util.tableMerge(tbl,source)
	local seen = {}

	for k,v in pairs(source) do
		if type(v) == "table" then v = copy(v,seen) end
		if type(k) == "table" then k = copy(k,seen) end

		tbl[k] = v
	end

	return seen
end

local function copy(tbl,source,seen)
	seen[source] = true
	seen[tbl] = true

	for k,v in pairs(source) do
		if type(v) == "table" then
			if seen[v] then tbl[k] = v continue end

			tbl[k] = tbl[k] or {}

			copy(tbl[k],v,seen)
		else
			tbl[k] = v
		end
	end
end

function util.tableLink(inTable,fromTable)--пиздец блядь было бы моя воля яб твою мать к стулу привезал и хуём ей пятки щекотал до смерти
	local seen = {}

	copy(inTable,fromTable,seen)
end//пиздец если что без рофла этой функции наверное уже пять лет (2025)

local function copy2(tbl,source,seen)
	seen[source] = true
	seen[tbl] = true

	for k,v in pairs(source) do
		if type(v) == "table" then
			if seen[v] then tbl[k] = v continue end

			tbl[k] = {}
			copy2(tbl[k],v,seen)
		else
			if tbl[k] == nil then
				tbl[k] = v
			end
		end
	end
end

local function copy(tbl,source,seen,change)
	seen[source] = true
	seen[tbl] = true

	for k,v in pairs(source) do
		if type(v) == "table" then
			if seen[v] then
				if tbl[k] == nil then change[k] = true end

				continue
			end

			if tbl[k] == nil then tbl[k] = {} end

			change[k] = {}
			copy(tbl[k],v,seen,change[k])
		else
			if tbl[k] == nil then
				tbl[k] = v
				change[k] = true
			end
		end
	end
end

function util.tableUnLink(tbl,source)
	local seen,change = {},{}

	copy(tbl,source,seen,change)

	return change
end

local function copy(tbl,source)
	for k,v in pairs(source) do
		if type(v) == "table" then
			if not tbl[k] then continue end

			copy(tbl[k],v)
		else
			tbl[k] = nil
		end
	end
end

function util.tableRemove(tbl,source)
	copy(tbl,source,seen)
end

function util.tableMinMax(tbl)
	local min
	local max

	for i,_ in pairs(tbl) do
		if not min then
			min = i
			max = i

			continue
		end

		if min > i then min = i end
		if max < i then max = i end
	end

	return min,max
end

local TypeID,pairs,table_Count = TypeID,pairs,table.Count

local override = {}

local table_Equal

table_Equal = function(a,b)
	if TypeID(a) != TYPE_TABLE or TypeID(b) != TYPE_TABLE then return a == b end

	if table_Count(a) ~= table_Count(b) then return false end

	override[a] = true
	override[b] = true
	
	for k, v in pairs(a) do
		local v2 = b[k]

		if TypeID(v) == TYPE_TABLE and TypeID(v2) == TYPE_TABLE then
			if override[v] or override[v2] then continue end

			if not table_Equal(v,v2) then return false end
		elseif v ~= v2 then
			return false
		end
	end

	for k in pairs(override) do override[k] = nil end

	return true
end

table.Equal = table_Equal

function table.Merge( dest, source, forceOverride, override )
	override = override or {}
	if override[dest] then return end
	override[dest] = true

	for k, v in pairs( source ) do
		if ( !forceOverride and istable( v ) and istable( dest[ k ] ) ) then
			-- don't overwrite one table with another
			-- instead merge them recurisvely
			table.Merge( dest[ k ], v , nil, override)
		else
			dest[ k ] = v
		end
	end

	return dest

end