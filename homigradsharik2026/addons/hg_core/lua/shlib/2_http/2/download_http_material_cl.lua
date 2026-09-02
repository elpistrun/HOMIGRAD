local chache = {}

file.CreateDir("homigrad")
file.CreateDir("homigrad/chache")

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

local function bakeMaterial(path,callback)
    AsyncThread:CoroutineWrap(function()
        callback(Material(path))
    end):Send()
end//хотел сделать возможность написать обработчик, но чот заметил что и так лагает нахуй кароче

function GetHTTPMaterial(url)
    if not url or url == true then return end
    
    local mat = chache[url]

    if not mat or mat[1] == "load" or mat[1] == "need_retry" then
        mat = mat or {}
        chache[url] = mat

        if mat[1] == "load" then return mat end

        local path = RemoveSpecialSumbolsFromURL(url)
        
        if not file.Read("homigrad/chache/" .. path .. ".png") or file.Time("homigrad/chache/" .. path .. ".png","DATA") + 60 * 60 * 24 * 24 <= os.time() then
            mat[1] = "load"

            local req = MainThread:CoroutineWrap(function()
                local success,res = HTTP({url = url,method = "GET",timeout = 1})

                if not success then
                    if res == "Timeout was reached" then
                        print("download_http: " .. tostring(url) .. "\nerror: " .. tostring(res))
                        mat[1] = "need_retry"
                        mat[3] = RealTime()
                        mat[4] = "TIMEOUT"
                    else
                        ErrorNoHalt("download_http: " .. tostring(url) .. "\nerror: " .. tostring(res) .. "\n")
                    end
                elseif res.code != 200 then
                    ErrorNoHalt("download_http: " .. tostring(url) .. "\nerror code: " .. tostring(res.code) .. "\nbody: " .. tostring(res.body) .. "\n")
                else
                    file.Write("homigrad/chache/" .. path .. ".png",res.body)
                    bakeMaterial("data/homigrad/chache/" .. path .. ".png",function(material) mat[2] = material end)
                end
            end)

            req.timeout = 5
            req:Send("GetHTTPMaterial")

            return mat
        else
            mat[1] = "load"
            
            bakeMaterial("data/homigrad/chache/" .. path .. ".png",function(material) mat[2] = material end)

            return mat
        end
    end

    return mat
end

function SetHTTPMaterial(url,data)
    local path = RemoveSpecialSumbolsFromURL(url)

    file.Write("homigrad/chache/" .. path .. ".png",data)
    chache[url] = Material("data/homigrad/chache/" .. path .. ".png")
end

local color_Red = Color(255,125,125)

local function drawError(mat,x,y,w,h)
    if not mat[4] then return end

    local k = (mat[3] or 0) + 1 - RealTime()

    if k > 0 then
        color_Red.a = 255 * k
        draw.SimpleText(mat[4],"HS12",x + w/2 + math.random(-k * 3,k * 3),y + h/2 + math.random(-k * 3,k * 3),color_Red,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end

function DrawHTTPMaterial(x,y,w,h,url)
    local mat = GetHTTPMaterial(url)
    if not mat then return end

    if not mat[2] then
        DrawLoading(x + w / 2,y + h / 2,math.min(w,h) / 2)
        drawError(mat,x,y,w,h)
    else
        surface.SetMaterial(mat[2])
        surface.DrawTexturedRect(x,y,w,h)
    end
end

function DrawHTTPMaterialCenter(x,y,w,h,url)
    local mat = GetHTTPMaterial(url)
    if not mat then return end

    if not mat or not mat[2] then
        DrawLoading(x + w / 2,y + h / 2,math.min(w,h) / 2)
        drawError(mat,x,y,w,h)
    else
        mat = mat[2]

        local mw,mh = mat:Width(),mat:Height()
        local maxLength = math.max(w,h) / math.max(mw,mh)

        mw = mw * maxLength
        mh = mh * maxLength

        surface.SetMaterial(mat)
        surface.DrawTexturedRect(x + -(mw - w)/2,y + -(mh - h)/2,mw,mh)
    end
end

local mat_loading = Material("homigrad/vgui/loading.png")

function DrawLoading(x,y,size,alpha)
    local size = size

    surface.SetMaterial(mat_loading)
    surface.SetDrawColor(255,255,255,alpha or 255)
    surface.DrawTexturedRectRotated(x,y,size,size,-(RealTime() * 360) % 360)
end

queueManager.thread.Create("download")

local old = 0

hook.Add("PostRenderVGUI","Download HTTP",function()
    local list = queueManager.thread.download.list

    local queue = list[1]
    if not queue then old = 0 return end

    draw.SimpleText(queue.name,"DefaultFixedDropShadow",0,0)
    
    old = math.max(old,#list)

    surface.SetDrawColor(0,0,0)
    surface.DrawRect(0,0,ScrW(),1)

    surface.SetDrawColor(0,255,0)
    surface.DrawRect(0,0,ScrW() * (1 - #list/ old),1)

    draw.SimpleText((old - #list) .. "/" .. old,"DefaultFixedDropShadow",ScrW(),0,nil,TEXT_ALIGN_RIGHT)
end)

concommand.Add("hg_download_clearchache",function()
    local files = file.Find("homigrad/chache/*","DATA")

    local count = 0

    for _,f in pairs(files) do
        file.Delete("homigrad/chache/" .. f)

        count = count + 1
    end

    chache = {}

    print("remove " .. count .. " files.")

    for k in pairs(threadList.download) do threadList.download[k] = nil end
end)