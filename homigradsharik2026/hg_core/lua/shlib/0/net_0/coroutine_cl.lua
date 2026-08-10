local wait = {}
local waitTimeout = {}

local empty = {}

local function resume(entIndex)
    for running in pairs(wait[entIndex] or empty) do
		local ent = Entity(entIndex)
		if not IsValid(ent) then continue end
		
        coroutine.resume(running,ent)
    end
end

event.Add("EntityCreate","EntityCoroutine",function(ent)
    resume(ent:EntIndex())
end,100)

event.Add("Think","EntityCoroutine",function()
	for entIndex,start in pairs(waitTimeout) do
		if start > RealTime() then continue end

        resume(entIndex)
	end
end,-100)

function EntityCoroutine(entIndex,delay)
	local running = coroutine.running()

	local ent = Entity(entIndex)

	if not IsValid(ent) then
		wait[entIndex] = wait[entIndex] or {}
        wait[entIndex][running] = true

		waitTimeout[entIndex] = RealTime() + (delay or 0.5)

		local result = coroutine.yield()

		wait[entIndex][running] = nil
		waitTimeout[running] = nil

		return result
	else
		return ent
	end
end