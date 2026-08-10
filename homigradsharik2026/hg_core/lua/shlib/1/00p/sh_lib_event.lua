local LIB = oop.Reg("lib_event")
if not LIB then return end

LIB.event = {}
LIB.eventRemove = {}

function LIB:Event_Add(class,name,func,prio)
	local event = self.event[class]

	prio = prio or 0

	if not event then
		event = {manual = {},list = {},min = 0,max = 0}

		self.event[class] = event
	end

	event.manual[prio] = event.manual[prio] or {}
	event.manual[prio][name] = func

	if IsValid(self) then self:Event_Construct() end
end

function LIB:Event_Remove(class,name,prio)
	local event = self.event[class]

	prio = prio or 0

	if not event then
		event = {manual = {},list = {},min = 0,max = 0}

		self.event[class] = event
	end

	event.manual[prio] = event.manual[prio] or {}
	event.manual[prio][name] = nil

	if IsValid(self) then self:Event_Construct() end
end--никогда не юзал

--

local empty = {}

local err = function(err) ErrorNoHaltWithStack(err) end

local xpcall = xpcall

function LIB:Event_Call(class,...)
	local event = self.event[class]
	if not event then return end

	local list = event.list
	local max = #list
	if max == 0 then return end
	local i = 1

	local r1,r2,r3

	::loop::

	r1,r2,r3 = list[i](self,...)
	if r1 ~= nil then return r1,r2,r3 end

	i = i + 1
	if i <= max then goto loop end
end

LIB.Event_Run = LIB.Event_Call

function LIB:Event_CallNoSelf(class,...)
	local event = self.event[class]
	if not event then return end

	local list = event.list
	local max = #list
	if max == 0 then return end
	local i = 1

	local r1,r2,r3

	::loop::

	r1,r2,r3 = list[i](...)
	if r1 ~= nil then return r1,r2,r3 end

	i = i + 1
	if i <= max then goto loop end
end

--

local empty = {}

function LIB:Event_Construct()
	for class,event in pairs(self.event) do
		local min,max

		for prio in pairs(event.manual) do
			if not min then min = prio max = prio continue end

			if min > prio then min = prio end
			if max < prio then max = prio end
		end

		event.min = min
		event.max = max

		local list = {}

		for prio = min,max do
			for name,func in pairs(event.manual[prio] or empty) do list[#list + 1] = func end
		end

		event.list = list
	end
end

function LIB:Construct()
	local content = self[1]
	content:Event_Construct()

	content:Event_CallNoSelf("Construct",self)
end--ну и хуета конешно