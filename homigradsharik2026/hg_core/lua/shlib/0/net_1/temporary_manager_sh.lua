temporary = temporary or {}
temporary.List = temporary.List or {}

function temporary.Create(name,funcOutput,funcRead,funcInput)
    temporary.List[name] = {
        funcOutput = funcOutput,
        funcRead = funcRead,
        funcInput = funcInput
    }
end

if SERVER then return end

function temporary.Input(name,data)
    local info = temporary.List[name]
    
    if not info then error("temporary.Input(" .. tostring(name) .. ") is not exists") end

    return info.funcInput(data)
end

local tempData = {}

net.ReceiveBig("temporaryData_Delta",function()
    local name = net.ReadString()

    local info = temporary.List[name]

    for k in pairs(tempData) do tempData[k] = nil end

    info.funcRead(tempData)
    info.funcInput(tempData)
end)

--

net.ReceiveBig("temporaryData",function()
    local bytes_amount = net.ReadUInt(16)
    local json = net.ReadData(bytes_amount)
    json = util.Decompress(json)
    
    game.CleanUpMap()

    temporary.snapshot = util.JSONToTable(json)
    temporary.start = RealTime()
    temporary.iteration = 0
end)

temporary.wait = not Initialize

net.LoadScreenTastAdd("Temporary",function()
    if not temporary.wait then return end
    if not temporary.start then return false,"Temporary","Ждём ответа от сервера" end

    TEMPORARY = true

    local snapshot = temporary.snapshot
    if not snapshot then return end

    local max = math.min(#snapshot * ((RealTime() - temporary.start) * 500 / #snapshot),#snapshot)
    
    for i = temporary.iteration + 1,math.floor(max) do
        temporary.iteration = i

        local data = snapshot[i]
        
        temporary.Input(data[0],data)
    end

    if temporary.iteration >= #snapshot then
        temporary.start = nil
        temporary.wait = nil

        TEMPORARY = nil
    end

    return false,"Temporary","Подготовка сцены",#temporary.snapshot - temporary.iteration,#temporary.snapshot
end,-10)