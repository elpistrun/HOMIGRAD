if CLIENT then return end

local MANAGER = ManagerRegistry("node_network")
if not MANAGER then return end

function MANAGER:GetNetUserName()
	return self.name .. "_user"
end

MANAGER:Event_Add("Init","Network",function(self)
	local name = self.name
	util.AddNetworkString(name .. "_server")

	net.Receive(name .. "_server",function(_,ply)
		if self.InputServer then self:InputServer(ply) end
	end)
end)

function MANAGER:NetStart()
	net.Start(self.name .. "_server")
end
