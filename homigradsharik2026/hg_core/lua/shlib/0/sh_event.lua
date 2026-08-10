event = event or {}
local event = event

event.list = event.list or {}
event.list_count = event.list_count or {}

local event_list = event.list
local event_list_count = event.list_count

local pairs = pairs
local empty = {}

function event.Construct(manual)
	local list = {}

	local min,max

	for prio in pairs(manual) do
		if not min then
			min = prio
			max = prio
		else
			if min > prio then min = prio end
			if max < prio then max = prio end
		end
	end

	for prio = min,max do
		for name,func in SortedPairs(manual[prio] or empty) do list[#list + 1] = func end
	end

	return list
end

function event.Add(class,name,func,prio)
	local _event = event_list[class]

	prio = prio or 0

	if not _event then
		_event = {manual = {}}
		event_list[class] = _event
	end

	local manual = _event.manual
	if not manual[prio] then manual[prio] = {} end
	manual[prio][name] = func

	_event.list = event.Construct(manual)
	event_list_count[class] = #_event.list
end

function event.Remove(class,name,prio)
	local _event = event_list[class]
	if not _event then return end

	prio = prio or 0

	local manual = _event.manual
	if not manual[prio] then return end
	manual[prio][name] = nil

	_event.list = event.Construct(manual)

	if #_event.list == 0 then
		event_list[class] = nil
	end

	event_list_count[class] = #_event.list
end

//

function event.Call(class,...)
	local _event = event_list[class]
	if not _event then return end

	local list = _event.list
	
	local r1,r2,r3
	local max = event_list_count[class]

	for i = 1,max do
		r1,r2,r3 = list[i](...)
		if r1 ~= nil then return r1,r2,r3 end
	end
end

event.Run = event.Call

function event.CallNoReturn(class,...)
	local _event = event_list[class]
	if not _event then return end

	local list = _event.list
	local max = event_list_count[class]
	
	for i = 1,max do
		local func = list[i]
		func(...)
	end
end

concommand.Add("hg_dev_event",function(ply,cmd,args)
	if SERVER and IsValid(ply) then return end
	
	PrintTable(event_list[args[1]])
end,nil,nil,SERVER and FCVAR_SERVERCMD_CAN_EXECUTE or FCVAR_CLIENTCMD_CAN_EXECUTE)
