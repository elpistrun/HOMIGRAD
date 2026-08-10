local MANAGER = ManagerRegistry("node_network_user")
if not MANAGER then return end

function MANAGER:GetNetUserName() return self.name .. "_user" end

MANAGER:Event_Add("Init","Network User",function(self)
    local netUserName = self:GetNetUserName()

    net.ReceiveCoroutine(netUserName)
end)

function MANAGER:NetStart()
    net.Start(self.name .. "_server")--no
end

function MANAGER:CoroutineWrap(func,instant)
    local queue = MainThread:CoroutineWrap(function()
        func()
    end,function()
        coroutine_net_wait[self:GetNetUserName()] = nil--strange
    end)

    if instant then
        queue:SendAndPlay("Server Response " .. self.name)
    else
        queue:Send("Server Response " .. self.name)
    end
end

function MANAGER:NetUserStart()
    net.CoroutineStart(self:GetNetUserName())
end

function MANAGER:NetUserSend()
    net.CoroutineSend(self:GetNetUserName())

    local success,msg = net.ReadBool(),net.ReadString()
    
    if not success then
        if self.NetUserErrorHandler and self:NetUserErrorHandler() == true then return success,msg end

        chat.AddText(Color(200,0,0),self.name .. " failed: " .. tostring(msg == "" and "unkown" or msg))
    end

    return success,msg
end

local empty = {}

function MANAGER:NetUserBusy()
    return table.Count(coroutine_net_wait[self:GetNetUserName()] or empty) > 0
end

function MANAGER:CoroutineNetWaitCall(...)
    net.CoroutineResume(self:GetNetUserName(),...)
end

function MANAGER:NetUserRequest(data)
    self:NetUserStart()
    net.WriteTable(data)
    return self:NetUserSend()
end