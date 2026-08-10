ObjectsListForDev = ObjectsListForDev or {}

local override

function ReConstructOBjectsByClassName(className)
    if override then return end
    
	local list = ObjectsListForDev[className] or {}

	local class = GetClassFromName(className)

	for self in pairs(list) do
		if not IsValid(self) then list[self] = nil continue end//lol

		override = true
		self:Event_Call("Construct Dev",class)
		override = nil
	end
end

function ReConstructObjectsByBase(baseClass)
	local list = {}

	for className in pairs(ObjectsListForDev) do
		if not oop.listClass[className] then continue end
		
		local base = oop.listClass[className].base

		if base and table.HasValue(base,baseClass) then
			list[className] = true
		end
	end

	ReConstructOBjectsByClassName(baseClass)

	for className in pairs(list) do
		ReConstructObjectsByBase(className)
	end
end

function GetClassFromName(spawnname)
	local class = oop.listClass[spawnname]
	return class and class[1] or scripted_ents.Get(spawnname) or weapons.Get(spawnname)
end