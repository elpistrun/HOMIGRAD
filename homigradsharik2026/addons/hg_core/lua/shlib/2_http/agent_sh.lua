AgentList = AgentList or {}

function AgentCreate(class,name,ip)
    if AgentList[name] then return AgentList[name] end
    
    local agent = oop.Create("agent_" .. class)

    agent.ip = ip
    agent.name = name

    AgentList[name] = agent
    _G[name] = agent

    if agent.Initialize then agent:Initialize() end

    return agent
end