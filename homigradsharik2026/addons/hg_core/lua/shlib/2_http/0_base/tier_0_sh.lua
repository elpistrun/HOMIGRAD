local AGENT = oop.Reg("agent_base","lib_event_noself",true)
if not AGENT then return INCLUDE_BREAK end

AGENT.ThreadName = "main"

function AGENT:Initialize()
    self.thread = queueManager.thread.Create(self.ThreadName or self.name)

    if self.OnInit then self:OnInit() end

    self:Event_Call("Init",self)
end

function AGENT:HTTP(data)
    CheckOnCoroutine()

    data.timeout = data.timeout or 10
    
    local success,res = HTTP(data)

    if not success then
        error(self.name .. " failed: " .. tostring(res or "unkown"))
    else
        if res.code ~= 200 then
            error(self.name .. " failed: " .. tostring(res and res.body or "unkown") .. ", code=" .. (res and res.code or "unkown"))
        end

        return res
    end
end

function AGENT:CoroutineWrap(func)
    return self.thread:CoroutineWrap(func)
end

AGENT:Event_Add("Construct","Update Objects",function(self)
    local content = self[1]

    for name,agent in pairs(AgentList) do
        if agent.ClassName ~= content.ClassName then continue end
        util.tableLink(agent,content)
    end
end)