local list
local startProfiler
local isRecording
local list_iteration

debug.sethook()
hook.Remove("Think","FPS Recorder")

function OpenDesc(frameInfo)
    if IsValid(hg_dev_fpsFrame) then hg_dev_fpsFrame:Remove() end
    
    hg_dev_fpsFrame = VguiCreateBlackScreen("dev")
    hg_dev_fpsFrame:MakePopup()

    local scrollList = oop.CreatePanel("v_scrolllist",hg_dev_fpsFrame):ad(function(self,w,h) self:setSize(w*0.8,h*0.8):setPos(w/2-self:W()/2,h/2-self:H()/2) end)

    scrollList:AddRow(1,"Path")
    scrollList:AddRow(2,"Line")
    scrollList:AddRow(3,"RunTime")
    scrollList:AddRow(4,"Count Call")

    for path,content in pairs(frameInfo.content) do
        scrollList:AddItem(content.short_src,content.linedefined .. " - " .. content.lastlinedefined,string.format("%.5f", content.runtime or -1),content.countCall)
    end

    function scrollList:DrawItem(info,line,w,h)
        line:DrawTip(info[3] and (1 / info[3]) .. " fps" or "",1)
    end

    scrollList.sortBy = 3
    scrollList.sortMode = true

    scrollList:UpdateList()

    local runtime = 0

    for path,content in pairs(frameInfo.content) do
        if not content.runtime or content.runtime <= 0 then continue end

        runtime = runtime + content.runtime
    end

    function hg_dev_fpsFrame:DrawContent(w,h)
        draw.SimpleText(math.floor(frameInfo.fps * 10) / 10 .. " FPS","HS.25",w/2,scrollList.y / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
        draw.SimpleText(table.Count(frameInfo.content) .. " Вызовов","HS.25",w/2,scrollList.y / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

        draw.SimpleText(math.floor(runtime * 1000) / 1000 .. " Секунд" .. " / " .. (1 / runtime) .. " fps","HS.18",w/2,scrollList.y / 2 + 45,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
    end
end

function renderFPSCall(path,runtime)
    if not list then return end

    local content = list[#list].content[path]

    if not content then
        content = {
            short_src = path,
            linedefined = -1,
            lastlinedefined = -1,
        }

        list[list_iteration].content[path] = content
    end

    content.countCall = (content.countCall or 0) + 1
    content.runtime = (content.runtime or 0) + runtime
end 

concommand.Add("hg_dev_fps",function(ply,cmd,args)
    if not list then
        list_iteration = 0
        
        list = {
            [1] = {
                fps = 1,
                content = {}
            }
        }

        for i = 1,200 * 20 do
            list[i] = {
                content = {}
            }
        end

        startProfiler = SysTime()
        
        hook.Add("Think","FPS Recorder",function()
            local fps = 1 / FrameTime()

            list_iteration = list_iteration + 1
            
            if not list[list_iteration] then
                list[list_iteration] = {
                    fps = fps,
                    content = {}
                }
            else
                list[list_iteration].fps = fps
            end
        end)

        isRecording = true

        if args[1] then
            local startFuncs = {}

            debug.sethook(function(event)
                if not isRecording then return end

                local info = debug.getinfo(2)
                if not info then return end

                local path = info.short_src .. info.linedefined .. info.lastlinedefined

                local content = list[list_iteration].content
                
                if event == "call" or event == "tail call" then
                    startFuncs[path] = SysTime()
                    
                    content[path] = content[path] or info

                    content[path].countCall = (content[path].countCall or 0) + 1
                elseif event == "return" then
                    local start = startFuncs[path]
                    
                    if start and content[path] then
                        content[path].runtime = (content[path].runtime or 0) + SysTime() - start

                        startFuncs[path] = nil
                    end
                end
            end,"cr",0)
        end
    else
        isRecording = nil
        debug.sethook()

        for i,frame in pairs(list) do
            local top = {}

            for i,content in pairs(frame.content) do
                top[#top + 1] = {content.runtime or -1,i}
            end

            table.sort(top,function(a,b) return a[1] > b[1] end)

            local newTop = {}

            for i,content in pairs(top) do
                newTop[i] = frame.content[content[2]]
            end

            frame.top = newTop
        end

        hook.Remove("Think","FPS Recorder")

        local list2 = list
        list = nil
        local list = list2

        local frame = VguiCreateBlackScreen("fpsrecorder")
        
        local panel = oop.CreatePanel("v_scrollpanel",frame):ad(function(self,w,h)
            self:setSize(w * 0.8,h * 0.8):setPos(w/2-self:W()/2,h/2-self:H()/2)
        end)
        panel:CreateHBar()
        panel.scrolling = 200
        function panel:Draw(w,h)
            draw.Frame(0,0,w,h,cframe1,cframe2)
        end

        local anchor = oop.CreatePanel("v_panel",panel)

        local frameInfo
        local oldAttack

        function anchor:SetList(list)
            local MaxList = list_iteration

            local max = 0
            local middle = 0
            local time = 0

            for i = 1,MaxList do
                local frame = list[i]
                max = math.max(frame.fps,max)

                middle = middle + frame.fps
                time = time + (1 / frame.fps)
            end

            middle = middle / MaxList
            max = math.max(max,max * 1.5)

            local wide = math.max(math.ceil(6 * (120 / max)),2)

            anchor:setSize(MaxList * wide,panel:H() - panel.hbar:H())

            function anchor:Draw(w,h)
                local x = (w - panel:W()) * panel:GetScrollX()

                local y = h - (h * (120 / max))
                draw.SimpleText("120","ChatFont",x,y)
                surface.SetDrawColor(165,165,165,125)
                surface.DrawRect(0,y,w,1)

                local y = h - (h * (60 / max))
                draw.SimpleText("60","ChatFont",x,y)
                surface.SetDrawColor(165,165,165,125)
                surface.DrawRect(0,y,w,1)

                local y = h - (h * (30 / max))
                draw.SimpleText("30","ChatFont",x,y)
                surface.SetDrawColor(165,165,165,125)
                surface.DrawRect(0,y,w,1)

                local y = h - (h * (middle / max))
                draw.SimpleText(math.floor(middle),"ChatFont",math.min(w,x + panel:W()),y,nil,TEXT_ALIGN_RIGHT)
                surface.SetDrawColor(255,255,165,125)
                surface.DrawRect(0,y,w,1)

                draw.SimpleText((math.floor(time * 100) / 100) .. ".s","ChatFont",100,0)

                local mx,my = self:GetMousePos(0,0)
                
                local iterations = 0

                for i = 1,MaxList do
                    local frame = list[i]
                    surface.SetDrawColor(255,255,255,55)

                    local x = wide * iterations
                    iterations = iterations + 1

                    local size = h * (frame.fps / max)
                    
                    if mx >= x and mx <= x + wide then
                        surface.SetDrawColor(255,255,255,125)

                        local text = tostring(math.floor(frame.fps)) .. "\n"
                        text = text .. "Caller: " .. table.Count(frame.content) .. "\n"
                        
                        local top = frame.top

                        for i = 1,math.min(#top,10) do
                            text = text .. string.sub(tostring(top[i].short_src) .. string.rep(" ",100),1,100) .. string.sub(math.floor(tonumber(top[i].runtime or 0) * 1000) / 1000 .. string.rep(" ",1,10),1,10) .. "\n"
                            text = text .. tostring(top[i].linedefined) .. ":" .. tostring(top[i].lastlinedefined) .. "\n"
                        end

                        local active = input.IsMouseDown(MOUSE_LEFT)
                        if oldAttack != active then
                            oldAttack = active

                            if active and self:IsHovered() then
                                OpenDesc(frame)
                            end
                        end

                        self:DrawTip(text,1,ScrW() - gui.MouseX())
                    end

                    surface.DrawRect(x,h - size,wide,size)
                end
            end

            self.list = list
        end

        anchor:SetList(list)

        local copy = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(300,50):setPos(panel.x + panel:W() - self:W(),panel.y + panel:H()) end)
        copy:SetupDrawStyle("white_gradient"); copy.gradientSide = "bottom"; copy.text = "COPY JSON"; copy.font = "HS.45"

        function copy:OnClick()
            local list = anchor.list
            local json = util.TableToJSON(list)
            SetClipboardText(json)

            local frames = {}

            local new = {
                fps = list.fps,
                frames = frames
            }

            for frameNumber = 1,#list do
                local frame = {
                    content = {}
                }

                frames[frameNumber] = frame

                local frameInfo = list[frameNumber]

                frame.fps = frameInfo.fps
                
                for i,content in pairs(frameInfo.content) do
                    frame.content[i] = {
                        countCall = content.countCall,
                        short_src = content.short_src,
                        runtime = content.runtime
                    }
                end
            end
            
            file.Write("!copyjson.txt",util.TableToJSON(new,true))
        end

        local paste = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(300,50):setPos(panel.x,panel.y + panel:H()) end)
        paste:SetupDrawStyle("white_gradient"); paste.gradientSide = "bottom"; paste.text = "PASTE JSON"; paste.font = "HS.45"

        function paste:OnClick()
            local panel = VParametrEdit("","",function(value)
                anchor:SetList(util.JSONToTable(value,true))
            end)
        end
    end
end)