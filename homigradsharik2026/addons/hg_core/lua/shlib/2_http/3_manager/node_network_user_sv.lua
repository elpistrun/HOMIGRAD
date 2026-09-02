if CLIENT then return end

local MANAGER = ManagerRegistry("node_network_user")
if not MANAGER then return end

function MANAGER:GetNetUserName()
	return self.name .. "_user"
end

MANAGER:Event_Add("Init","Network User",function(self)
	local netUserName = self:GetNetUserName()
	util.AddNetworkString(netUserName)

	net.Receive(netUserName,function(_,ply)
		local sessionId = net.ReadInt(7)

		local success,msg = true,""
		if self.InputServer then
			success,msg = self:InputServer(ply)
		end

		net.Start(netUserName)
		net.WriteInt(sessionId,7)
		net.WriteBool(success ~= false)
		net.WriteString(msg or "")
		net.Send(ply)
	end)
end)

function MANAGER:NetStart()
	net.Start(self.name .. "_server")
end
