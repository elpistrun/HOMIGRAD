local MANAGER = ManagerRegistry("node_network")
if not MANAGER then return end

function MANAGER:GetNetUserName() return self.name .. "_user" end

MANAGER:Event_Add("Init","Network",function(self)
    local name = self.name

    net.Receive(name .. "_server",function()
        if self.InputServer then self:InputServer() end
    end)
end)

function MANAGER:NetStart()
    net.Start(self.name .. "_server")--no
end
