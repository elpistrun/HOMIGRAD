local errors = {}

local delayNotify = 5

-- Client-side RTV state defaults. The Draw methods index these every frame,
-- so they must always be tables even before the server sends the first status.
RTVStatus     = RTVStatus or nil
RTVVote       = RTVVote or {}
RTVVoteNumber = RTVVoteNumber or {}
RTVVoteMax    = RTVVoteMax or 0
RTVLeaders    = RTVLeaders or {}
RTVRandom     = RTVRandom or {}
RTVRandomWinner = RTVRandomWinner or ""

net.Receive("rtv notify",function()
    table.insert(errors,1,{
        text = net.ReadString(),
        color = net.ReadColor(),
        start = RealTime()
    })

    surface.PlaySound("homigrad/vgui/menu_focus.wav")
end)

local width,height = 250,50

local olderPreviewImage,curretPreviewImage
local animSlideShow = 0

local _,map
local delay = 0

function RTVGetRandomMap()
    local time = RealTime()

    if delay < time then
        delay = time + 0.25
        _,map = table.Random(RTVMapsAviable)
    end

    return map
end

function OpenRTV()
    if not RTVMapsAviable then return end
    if IsValid(RTVFrame) then RTVFrame:Remove() end
    RTVFrame = oop.CreatePanel("v_frame"):setDSize(1,1)
    RTVFrame:SetZPos(-200)
    RTVFrame:MakePopup()
    RTVFrame:SetKeyboardInputEnabled(false)

    function RTVFrame:Draw(w,h)
        gui.EnableScreenClicker(true)

        local map = RTVLeaders[1]
        
        if RTVStatus == "random" then
            map = RTVFrame.Random.cursorMap
        end

        local white = RTVStatus == "random" and 125 or 125

        if map then
            if map == "extend" then map = game.GetMap() end
            if map == "random" then map = RTVGetRandomMap() end

            -- Background preview image. A map may have no entry (e.g. the
            -- current map after "extend", or placeholder data without media),
            -- then the preview is simply skipped -- never the blur and the
            -- dark overlay drawn below.
            local mapInfo = RTVMapsAviable[map]
            if mapInfo then
                local previewImage = mapInfo.previewImage

                if curretPreviewImage ~= previewImage then
                    olderPreviewImage = curretPreviewImage
                    curretPreviewImage = previewImage

                    animSlideShow = RealTime()
                end

                local k = math.max(animSlideShow - RealTime() + 0.2,0) / 0.8

                surface.SetDrawColor(0,0,0)
                surface.DrawRect(0,0,w,h)
                
                if previewImage then
                    surface.SetDrawColor(white,white,white,255 * (1 - k))
                    DrawHTTPMaterialCenter(0,0,w,h,previewImage)
                end

                if olderPreviewImage then
                    surface.SetDrawColor(white,white,white,255 * (k))
                    DrawHTTPMaterialCenter(0,0,w,h,olderPreviewImage)
                end
            end
        end


        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)

        DrawBlur(6)

        if RTVLeaders[1] then
            local leader = RTVLeaders[1]
            if leader == "extend" then
                leader = L("rtv_extend_button")
            elseif leader == "random" then
                leader = L("rtv_random_button")
            end

            draw.SimpleText(leader,"HS.45",w - h * (0.15/2),h * (0.15/2),nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        end

        draw.SimpleText(L(GetGlobalVar("RTVTitle","test")),"HS.45",w / 2,h * (0.15/2),nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        local start = GetGlobalVar("RTVStart",0)
        local delay = GetGlobalVar("RTVTime",0)
        
        local value = math.ceil(start + delay - CurTime())

        if value >= 0 then
            draw.SimpleText(tostring(value) .. " " .. L("seconds"),"HS.45",h * (0.15/2),h * (0.15/2),nil,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
        end
    end

    function RTVFrame:DrawOver(w,h)
        local i = 1
        local y = 32
        local time = RealTime()

        ::start::

        local error = errors[i]
        if not error then surface.SetAlphaMultiplier(1) return end

        local k = (error.start - time + delayNotify) / delayNotify
        if k <= 0 then table.remove(errors,i) goto start end
        surface.SetAlphaMultiplier(k)
        
        local color = error.color

        surface.SetDrawColor(color.r,color.g,color.b)
        surface.DrawRect(32,y,width,height)
        draw.SimpleText(L(error.text),"H.18",32 + width/2,y + height/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        local kflash = math.max(k - 0.95,0) / 0.05
        surface.SetDrawColor(255,255,255,255 * kflash)
        surface.DrawRect(32,y,width,height)

        y = y + 50
        i = i + 1
        goto start
    end
    
    local pagesVertical = oop.CreatePanel("v_scrollpage",RTVFrame):setDSize(1,1)
    pagesVertical:SetHorizontal(false)
    RTVFrame.pagesVertical = pagesVertical

    local pageVertical = pagesVertical:Add()//empty for horizontals pages

    local pagesHorizontal = oop.CreatePanel("v_scrollpage",pageVertical):setDSize(1,1)
    pagesHorizontal:SetHorizontal(true)
    RTVFrame.pagesHorizontal = pagesHorizontal

    local page = pagesHorizontal:Add()
    RTVFrame.MapVote = page
    RTVUI_CreateMapVote(page)

    local page = pagesHorizontal:Add()
    RTVFrame.SelectMap = page
    RTVUI_CreateSelectMap(page,function(map)
        net.Start("rtv add map")
        net.WriteString(map)
        net.SendToServer()
    end)

    local page = RTVFrame.pagesVertical:Add()
    RTVFrame.Random = page
    RTVUI_CreateRandom(page)

    local buttonMapVote = oop.CreatePanel("v_button",pageVertical):ad(function(self,w,h) self:setSize(150,30):setPos(w / 2 - self:W(),h * 0.15 - self:H() / 2) end)
    local buttonSelectMap = oop.CreatePanel("v_button",pageVertical):ad(function(self,w,h) self:setSize(150,30):setPos(w / 2,h * 0.15 - self:H() / 2) end)

    local hover = 0

    function buttonMapVote:Draw(w,h)
        surface.SetDrawColor(125,125,125,128)
        local size = h * 0.8
        draw.GradientDown(0,h - size + 1,w,size)

        if pagesHorizontal.setPage == 1 then
            surface.SetDrawColor(255,255,255,25)
            draw.GradientDown(0,0,w,h)
        end

        surface.SetDrawColor(255,255,255)
        surface.DrawRect(0,h - 1,w,1)

        draw.SimpleText("Голосование","HS.18",w / 2,h / 2 - hover * 5,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        hover = LerpFT(0.5,hover,self:IsHovered() and 1 or 0)
    end
    function buttonMapVote:OnClick() pagesHorizontal:Set(1) end

    local hover = 0
    function buttonSelectMap:Draw(w,h)
        surface.SetDrawColor(125,125,125,128)
        local size = h * 0.8
        draw.GradientDown(0,h - size + 1,w,size)

        if pagesHorizontal.setPage == 2 then
            surface.SetDrawColor(255,255,255,25)
            draw.GradientDown(0,0,w,h)
        end

        surface.SetDrawColor(255,255,255)
        surface.DrawRect(0,h - 1,w,1)

        draw.SimpleText("Добавить карту","HS.18",w / 2,h / 2 - hover * 5,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        hover = LerpFT(0.5,hover,self:IsHovered() and 1 or 0)
    end
    function buttonSelectMap:OnClick() pagesHorizontal:Set(2) end

    //

    RTVFrame.MapVote:Update()
    RTVFrame.SelectMap:Update(RTVMapsAviable)

    RTVVoteUpdate()
end

function RTVSetPage(value,fast)
    if not IsValid(RTVFrame) then return end

    RTVFrame.SetPage = value

    if value == 1 then
        RTVFrame.pagesHorizontal:Set(1,fast)
        RTVFrame.pagesVertical:Set(1,fast)
    elseif value == 2 then
        RTVFrame.pagesHorizontal:Set(2,fast)
        RTVFrame.pagesVertical:Set(1,fast)
    elseif value == 3 then
        RTVFrame.pagesVertical:Set(2,fast)
    end
end

function CloseRTV()
    if IsValid(RTVFrame) then RTVFrame:Remove() end
    
    gui.EnableScreenClicker(false)
end

net.ReceiveMediaToken("rtv_maps",function(body)
    RTVMapsAviable = JSONToTable(body)

    RTVVoteUpdate()

    if IsValid(RTVFrame) then RTVFrame.SelectMap:Update(RTVMapsAviable) end
end)

-- Server-provided map list fallback. Used when the external `rtv_maps` media
-- token is unavailable; lets OpenRTV() render with placeholder art instead of
-- failing because RTVMapsAviable is nil.
if SERVER then return end

net.Receive("rtv maps list",function()
    local maps = net.ReadTable()
    if type(maps) ~= "table" then return end

    RTVMapsAviable = {}
    for _, map in ipairs(maps) do
        RTVMapsAviable[map] = { previewImage = nil, screenshoots = {} }
    end

    -- Seed the shared map index: admin panel "Maps" page / map_setcontent read
    -- mapManager.listIndex, which is otherwise only filled by the external
    -- mapManager_listIndex media token. With no media server it is empty, so
    -- those UIs showed no maps at all.
    if mapManager and mapManager.listIndex and not next(mapManager.listIndex) then
        for map, info in pairs(RTVMapsAviable) do
            mapManager.listIndex[map] = info
        end

        if event and event.Call then event.Call("Map Blocked Sync") end
    end

    RTVVoteUpdate()

    if IsValid(RTVFrame) and RTVFrame.SelectMap and RTVFrame.SelectMap.Update then
        RTVFrame.SelectMap:Update(RTVMapsAviable)
    end
end)

local oldStatus
function RTVVoteUpdate()//rtv maps считывает данные, и что-бы клиент не посылал серверу статус о готовности принимать обновки я просто создал эту функцию и заранее прислал данные rtvvote
    if not RTVMapsAviable then return end

    // Only open the frame when an actual vote is running; otherwise RTV would
    // pop up for no reason right after joining the server.
    if not IsValid(RTVFrame) and RTVStatus then OpenRTV() end

    if RTVStatus == "vote" then
        RTVVoteNumber = {}

        local max = 0

        for vote,list in pairs(RTVVote) do
            local map = RTVMapsAviable[vote]
            if map == "extend" then extend = RTVMapsAviable[game.GetMap()] end

            local count = table.Count(list)
            
            RTVVoteNumber[vote] = count
            max = max + count
        end
        
        RTVVoteMax = max
        RTVLeaders = RTVGetLeaders()
        
        if IsValid(RTVFrame.MapVote) then RTVFrame.MapVote:Update() end
        if RTVFrame.SetPage == 3 then RTVSetPage(1) end//dev
    elseif RTVStatus == "random" then
        RTVFrame.Random:Start()
    end
end

net.Receive("rtv status",function()
    local status = net.ReadString()
    RTVStatus = status

    if status == "vote" then
        RTVRandom = nil//dev
        RTVVote = net.ReadTable()

        RTVVoteUpdate()
    elseif status == "random" then
        RTVRandom = net.ReadTable()
        RTVRandomWinner = net.ReadString()

        RTVRoulleteMul = tonumber(net.ReadString())
        RTVRoulleteSub = tonumber(net.ReadString())

        RTVVoteUpdate()
    else
        CloseRTV()

        return
    end
end)