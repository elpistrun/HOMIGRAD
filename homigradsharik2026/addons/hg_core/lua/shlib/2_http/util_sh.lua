if not HHTTP then HHTTP = HTTP end

function HTTP(data)
    local running = coroutine.running()
    if not running then return HHTTP(data) end

    data.timeout = data.timeout or 10

    if data.body then
        data.method = data.methor or "POST"
        data.headers["Content-Length"] = #data.body
    end

    data.success = function(code,body,headers)
        coroutine.resume(running,true,{code = code,body = body,headers = headers})
    end

    data.failed = function(err)
        coroutine.resume(running,false,err)
    end

    local module = CHTTP or HHTTP

    module(data)

    return coroutine.yield()
end

function CheckOnCoroutine()
    if not coroutine.running() then error("coroutine running is not valid") end
end

local removeSpecSumbol = {
    "?",
    "/",
    "\\",
    ":",
    "<",
    ">",
    ",",
    "\"",
    "|"
}

function RemoveSpecialSumbolsFromURL(url)
    if not url then return end
    
    for _,sum in pairs(removeSpecSumbol) do url = string.gsub(url,sum,"") end
    return url
end

function coroutine.Wait(delay)
    local running = coroutine.running()

    timer.Simple(delay,function() coroutine.resume(running) end)

    coroutine.yield()
end