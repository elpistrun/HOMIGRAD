local initProtocol_1,initProtocol_2,initProtocol_3,initProtocol_3_Start

net.LoadScreenTask = net.LoadScreenTask or {
    manual = {},
    list = {}
}

local LoadScreenTask = net.LoadScreenTask

function net.LoadScreenTastAdd(id,func,prio)
    LoadScreenTask.manual[prio] = LoadScreenTask.manual[prio] or {}
    LoadScreenTask.manual[prio][id] = func

    LoadScreenTask.list = event.Construct(LoadScreenTask.manual)
end

local err = function(err)
    InitProtocol = "ERROR BY CLIENT"
    InitProtocolError = markup.Parse("<color=255,0,0>" .. err .. "\n" .. debug.traceback() .. "</color>")
end

local initProtocol_3_Started = false

initProtocol_3_Start = function()
    if initProtocol_3_Started then return end

    initProtocol_3_Started = true

    timer.Create("initProtocol_3",0,0,function()
        if InitProtocolError then return end--wtf

        local func = LoadScreenTask.list[1]
        if not func then timer.Remove("initProtocol_3") initProtocol_3() return end

        local _,result,title,progressTitle,progress,progressMax,desc = xpcall(func,err)

        if result != false then
            table.remove(LoadScreenTask.list,1)
        else
            initProtocol_3_Title = title
            initProtocol_3_Progress = progress
            initProtocol_3_ProgressMax = progressMax
            initProtocol_3_ProgressTitle = progressTitle
            initProtocol_3_Desc = desc
        end
    end)
end

initProtocol_1 = function()//Говорим что можно безопасно отправлять данные
    InitProtocol = "waitResponseFromServer"
    net.Start("initProtocol")
    net.SendToServer()
    //После получаем данные с сервера в виде net.Receive
    //(Информация о текущем раунде, ваше наиграное времмя и т.п)
    //В конце этой цепочки сервер отправляем initProtocol

    timer.Simple(2,function()//если сервер не ответил, пропускаем
        if InitProtocol != "waitResponseFromServer" then return end

        initProtocol_2()
    end)
end

initProtocol_2 = function()//Говори что получили данные с сервера, отправляем свои данные
    MainThread:CoroutineWrap(function()
        event.Call("Send Data")//Посылаем различные данные (информация о скине, выборке класса и прочее)

        InitProtocol = "waitReadyFromServer"
        net.Start("initProtocol")//Говорим что данных больше не будет и их нужно обработать.
        net.SendToServer()
        //Ждём ответа от сервера.

        timer.Simple(2,function()//если сервер не ответил, пропускаем
            if InitProtocol != "waitReadyFromServer" then return end

            initProtocol_3_Start()
        end)
    end):Send("initProtocol Send Data")
end


initProtocol_3 = function()//Говорим что мы готовы к игре\
    InitProtocol = "setupWorld"
    event.Call("Setup World")//Подготавливаем мир, настраивам объекты к игре.

    InitProtocol = "ready"
    InitNET = true
    net.Start("initProtocol")
    net.SendToServer()
end

hook.Add("InitPostEntity","Player Spawn",function()
    InitProtocol = "setupWorld"
    local ok,err = pcall(event.Call,"Setup World")
    if not ok then PrintMessage(HUD_PRINTTALK,"Setup World error: "..tostring(err)) end
    InitProtocol = "ready"
    InitNET = true

    local okNet = pcall(net.Start,"initProtocol")
    if okNet then pcall(net.SendToServer) end
end)

net.Receive("initProtocol_Error",function()
    InitProtocol = "ERROR BY SERVER"
    InitProtocolError = markup.Parse("<color=255,0,0>" .. net.ReadString() .. "</color>")
end)

net.Receive("initProtocol",function()
    local success,err = xpcall(function()
        if InitProtocol == "waitResponseFromServer" then//Принимаем данные с сервера, отправляем свои.
            initProtocol_2()
        elseif InitProtocol == "waitReadyFromServer" then//Подготавливаем мир.
            initProtocol_3_Start()
        end
    end,function(err)
        InitProtocol = "ERROR BY CLIENT"
        InitProtocolError = markup.Parse("<color=255,0,0>" .. net.ReadString() .. "</color>")
    end)
end)

//

local function Init(ply)
    ply.init = true

    event.Call("Player Create",ply)
    event.Call("Player Spawn",ply)
end

event.Add("EntityCreate","InitProtocol",function(ply)
    if not ply:IsPlayer() then return end

    if not ply.init then Init(ply) end
end)

hook.Add("InitPostEntity","PlayerCreate",function()
    for i,ply in pairs(player.GetAll()) do
        Init(ply)
    end
end)

net.ReceiveTick("player_spawn",function(data)
    local ply = Player(data[1])

    event.Call("Player Spawn",ply)

    if ply == LocalPlayer() then event.Call("Player Spawn Local",ply) end
end)
