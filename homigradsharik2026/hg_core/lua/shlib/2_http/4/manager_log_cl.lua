local MANAGER = ManagerRegistry("base_log",{"node","node_network_user"})
if not MANAGER then return end

function MANAGER:InputFull(body)
    self.response = JSONToTable(body,true)

    self:Event_Call("Update",self)
end

function MANAGER:OpenMenu()
    local manager = self

    if IsValid(manager.frame) then self.frame:Remove() end

    local frame = VguiCreateBlackScreen("logmanager")
    manager.frame = frame

    local panel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w * 0.8,h * 0.8):setPos(w/2-self:W()/2,h/2-self:H()/2) end)

    function frame:DrawContent(w,h)
        local k = math.max((frame.updateStart or 0) - RealTime() + 0.2,0) / 0.2

        surface.SetDrawColor(255,255,255,6 * k)
        surface.DrawRect(0,0,w,h)

        draw.SimpleText("UPDATED","HS.45",w/2,h/2,Color(255,255,255,255 * k),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        
        draw.SimpleText(name,"HS.25",w / 2,panel.y / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("ap_ui_db_count",table.Count(manager.response or {})),"HS.25",panel.x,panel.y / 2,nil,nil,TEXT_ALIGN_CENTER)
    end

    function panel:Draw(w,h)
        draw.Frame(0,0,w,h,cframe1,cframe2)

        if not manager.response then
            draw.SimpleText("Сделайте запрос","HS.25",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end

    local textEntryCaller = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(w/3,30) end)
    textEntryCaller:SetPlaceholderText(L("ap_ui_find_caller"))

    local buttonSumbit = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,60):setPos(0,h - self:H()) end)
    buttonSumbit.text = "ОТПРАВИТЬ ЗАПРОС НА ПОЛУЧЕНИЕ ДАННЫХ"
    
    function buttonSumbit:OnClick()
        MainThread:CoroutineWrap(function()
            manager:Request()
        end):Send()
    end

    local scrollPanelCaller = oop.CreatePanel("v_scrollpanel",panel):ad(function(self,w,h) self:setPos(0,textEntryCaller:H()):setSize(textEntryCaller:W(),h - self.y - buttonSumbit:H()) end)
    local scrollPanel = oop.CreatePanel("v_scrollpanel",panel):ad(function(self,w,h) self:setPos(scrollPanelCaller:W(),scrollPanelCaller.y):setSize(w - self.x,h - self.y - buttonSumbit:H()) end)
    scrollPanel:CreateVBar()
    scrollPanel.scrolling = 300

    scrollPanelCaller:LinkScrollPanel(scrollPanel)

    local playersCaller = oop.CreatePanel("v_avatarlist",scrollPanelCaller)
    playersCaller:Setup(40)
    playersCaller:SetScrollPanel(scrollPanelCaller)

    local playersContent = oop.CreatePanel("v_avatarlist",scrollPanel)
    playersContent:Setup(40)
    playersContent:SetScrollPanel(scrollPanel)

    manager:CreateSearch(textEntryCaller,panel)

    function frame:Update()
        frame.updateStart = RealTime()
        
        playersCaller:Clear()
        playersContent:Clear()

        scrollPanel:Clear()

        for i,info in pairs(manager.response or {}) do
            local profile = Profiles[info.caller] or {}
            
            local buttCaller = playersCaller:AddPanel(i,profile.name or info.caller,profile.avatar,profile.avatarFrame,profile.background,profile.bacgkroundY)

            function buttCaller:Draw(w,h)
                surface.SetDrawColor(0,0,0,100)
                surface.DrawRect(0,0,w,h)
            end

            local steamid64 = manager:GetSteamid64Victim(info) or info.caller
            local profile = Profiles[steamid64] or {}

            local butt = playersContent:AddPanel(i,profile.name or info.caller,profile.avatar,profile.avatarFrame,profile.background,profile.bacgkroundY)

            function butt:Draw(w,h)
                surface.SetDrawColor(0,0,0,100)
                surface.DrawRect(0,0,w,h)
            end

            manager:CreateInfo(buttCaller,butt,info)
        end
    end

    frame:Update()
end

function MANAGER:RequestWrite(page,action,caller)
    net.WriteString("get")
    net.WriteInt(page or 0,8)
    net.WriteString(action or "")
    net.WriteString(caller or "")
end

--function MANAGER:CreateSearch(textEntryCaller,panel) end
--function MANAGER:CreateInfo(buttCaller,butt,info) end
--function MANAGER:GetSteamid64Victim(info) return end

MANAGER:Event_Add("Update","UI",function(self)
    if IsValid(self.frame) then self.frame:Update() end
end)