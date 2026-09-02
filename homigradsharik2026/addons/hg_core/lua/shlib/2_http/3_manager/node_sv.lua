if CLIENT then return end

local MANAGER = ManagerRegistry("node")
if not MANAGER then return end

MANAGER:Event_Add("Init","Base",function(self)
	self.listData = {}
end,-1)

function MANAGER:Initialize()
	self:Event_Call("Init",self)
end

MANAGER:Event_Add("Construct","Update Objects",function(self)
	local content = self[1]

	for name,manager in pairs(ManagerList) do
		if not table.HasValue(manager.baseInherit,content.ClassName) then continue end
		util.tableLink(manager,content)
	end
end)
