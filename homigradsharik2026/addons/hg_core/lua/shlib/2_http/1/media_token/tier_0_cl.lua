local AGENT = oop.Reg("agent_media_token","agent_base")
if not AGENT then return end

net.Receive("media_token_ip",function()
    for name,ip in pairs(net.ReadTable()) do
        AgentCreate("media_token",name,ip)
    end
end)

net.ReceiversMediaToken = net.ReceiversMediaToken or {}

net.ReceiveMediaToken = function(name,func)
    net.ReceiversMediaToken[name] = func
end

net.Receive("media_token",function()
    local name,eventName,token = net.ReadString(),net.ReadString(),net.ReadString()

    local agent = AgentList[name]
    if not agent then return end--probably initalizing...

    agent:CoroutineWrap(function()
        agent:RequestByToken(eventName,token)
    end):Send()
end)

function AGENT:RequestByToken(eventName,token)
    CheckOnCoroutine()

    local res = self:HTTP({url = self.ip .. "?token=" .. token})

    local func = net.ReceiversMediaToken[eventName]
    if not func then ErrorNoHalt("mediatoken failed: " .. tostring(eventName) .. " not found\n") return end
    
    func(res.body,res)
end