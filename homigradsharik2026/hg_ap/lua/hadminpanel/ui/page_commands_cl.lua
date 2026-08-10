AdminPanelPages[1] = AdminPanelPages[1] or {}
local Page = AdminPanelPages[1]

Page.Name = "ap_ui_commands"

local white,black = Color(255,255,255),Color(0,0,0)

function Page.Open(frame)
    local scrollPanelList = oop.CreatePanel("v_scrollpanel",frame):ad(function(self,w,h) self:setSize(350,h) end)
    scrollPanelList:CreateVBar()
    scrollPanelList.canvasPanel:AddFlexParent()
    scrollPanelList.scrolling = 200

    local panelCommand = oop.CreatePanel("v_scrollpanel",frame):ad(function(self,w,h) self:setSize(w - scrollPanelList:W() - 400,h):setPos(scrollPanelList:W(),corner) end)
    panelCommand.scrolling = 200

    adminpanel_menu.panelCommand = panelCommand
    
    local panelCommandRight = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w - panelCommand.x - panelCommand:W(),h):setPos(w - self:W(),0) end)
    panelCommandRight:AddFlexParent()

    local y = 0
    function panelCommandRight:CreatePanel(H,argType)
        H = H + 30
        local Y = y
        local panel = oop.CreatePanel("v_panel",panelCommandRight):ad(function(self,w,h) self:setSize(w,H):setPos(0,Y) end)
        y = y + panel:H()
        function panel:Draw(w,h)
            surface.SetDrawColor(75,75,128,128)
            draw.GradientLeft(0,0,w,30)
            draw.Frame(0,0,w,30,cframe1,cframe2)

            draw.SimpleText(argType.name or "","H20",15,15,nil,nil,TEXT_ALIGN_CENTER)
            draw.SimpleText(argType.type,"H20",w - 15,15,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        end

        return panel
    end

    local selectCmd
    function panelCommand:SelectCommand(cmdName)
        if selectCmd == cmdName then return end
        selectCmd = cmdName
        Page.SelectCmd = cmdName

        panelCommand:Clear()
        panelCommand:RemoveVBar()
        panelCommandRight:Clear()

        if not LocalPlayer():HasSuccess("command_" .. cmdName) then selectCmd = nil Page.SelectCmd = nil return end

        local cmd = adminPanel.commands[selectCmd]

        y = 35

        panelCommand.Update = nil

        if cmd.UICreate then cmd.UICreate(panelCommand,panelCommandRight) return end

        local buttonSumbit = oop.CreatePanel("v_button",panelCommandRight):ad(function(self,w,h) self:setSize(w,60):setPos(0,h - self:H()) end)
        function buttonSumbit:Draw(w,h)
            surface.SetDrawColor(128,128,255,50)
            surface.DrawRect(0,0,w,h)

            draw.GradientDown(0,0,w,h)

            draw.SimpleText("ОТПРАВИТЬ","H20Black",w/2,h/2,self:IsHovered() and white or black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end

        local argsSumbit = {}

        function buttonSumbit:OnClick()
            adminPanel.commandSendToServer(selectCmd,argsSumbit)//ЕБУЧИЙ СИНГЛПЛЕЕР БЛЯДЬ
        end

        for i,argType in pairs(cmd.argsType or {}) do
            if argType.type == "players" or argType.type == "players^" or argType.type == "steamid" then
                local listSelectedPlayers = {}

                local iconSize = 64
                local corner = iconSize * 0.25
                local playersPanel = oop.CreatePanel("v_players",panelCommand):ad(function(self,w,h) self:setSize(w,h - corner):setPos(0,corner) end)
                playersPanel:Setup(iconSize)
                playersPanel:CreateVBar()
                playersPanel.search:ad(function(self,w,h) self:setSize(w - corner*2,iconSize - corner*2):setPos(corner,0) end)
                
                function playersPanel:OnClick(key,info)
                    if key == MOUSE_RIGHT then
                        OpenDermaPlayer(player.GetBySteamID(info.id))
                    else
                        if argType.type == "steamid" then
                            for name in pairs(listSelectedPlayers) do
                                listSelectedPlayers[name] = nil
                            end
                        end

                        listSelectedPlayers[info.name] = not listSelectedPlayers[info.name] and true or nil
                        
                        local list = {}
                        for name in pairs(listSelectedPlayers) do
                            list[#list + 1] = info.id
                        end

                        argsSumbit[i] = list
                    end
                end
            
                function playersPanel:DrawPanel(w,h,panel,info)
                    if listSelectedPlayers[info.name] then
                        surface.SetDrawColor(175,175,255,25)
                        surface.DrawRect(0,0,w,h)
                        surface.SetDrawColor(175,175,255,128)
                        draw.GradientLeft(0,0,w,h)
                    end

                    scoreboard.DrawPlayer(player.GetBySteamID64(info.id),w,h,{dontDrawMute = true, dontDrawPing = true,dontDrawTeam = true,dontDrawAlive = true},self)
                end
            
                for i,ply in pairs(player.GetAll()) do
                    if ply:GetNWBool("Hide") then continue end
                    
                    playersPanel:AddPlayer(ply)
                end
            end

            local Y = y
            local panel = panelCommandRight:CreatePanel(argType.type == "bool" and 75 or 30,argType)

            if argType.type == "bool" then
                local switch = oop.CreatePanel("v_switch",panel):ad(function(self,w,h) self:setPos(0,30):setSize(w,h - self.y) end)
                
                function switch:OnValue(value)
                    argsSumbit[i] = value and "1" or "0"
                end
            else
                local textEntry = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setPos(0,30):setSize(w,h - self.y) end)
                
                if argType.type == "number" then textEntry:SetNumeric(true) end

                function textEntry:OnChange()
                    argsSumbit[i] = self:GetValue() != "" and self:GetValue() or nil
                end
            end
        end
    end

    function panelCommandRight:Draw(w,h)
        if selectCmd then
            surface.SetDrawColor(175,175,255,128)
            draw.GradientLeft(0,0,w,35)

            draw.SimpleText(adminPanel.commands[selectCmd].title or selectCmd,"H20",w/2,35/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end

        surface.SetDrawColor(255,255,255,7)
        surface.DrawRect(0,0,1,h)
    end

    local panels = {}

    function frame:Update()
        if selectCmd and not LocalPlayer():HasSuccess("command_" .. selectCmd) then panelCommand:SelectCommand() end

        local H = 35

        local manual = {}

        for category,list in SortedPairs(adminPanel.commandsCategory) do
            local categoryList = {}
            local has

            for name,desc in pairs(list) do
                if adminPanel.commands[name].dontShowGUI or not LocalPlayer():HasSuccess("command_" .. name) then continue end

                has = true
                categoryList[name] = desc
            end

            if has then
                manual[category] = categoryList
            end
        end

        scrollPanelList:Clear()
        
        for category,list in SortedPairs(manual) do
            local panel = oop.CreatePanel("v_panel",scrollPanelList):ad(function(self,w,h) self:setSize(w,H * (table.Count(list) + 1)) end):AddByFlex()
            
            function panel:Draw(w,h)
                surface.SetDrawColor(175,175,255,25)
                surface.DrawRect(0,0,w,H)
                surface.SetDrawColor(175,175,255,128)
                draw.GradientRight(0,0,w,H)

                draw.SimpleText(category,"H20Black",w/2,H/2,color_black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end

            local i = 1
            for name,info in SortedPairs(list) do
                local I = i
                i = i + 1
                local butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,H):setPos(0,self:H() * I) end)
                butt:SetupDrawStyle("white_gradient"); butt.text = name; butt.font = "H20"
                panels[name] = butt
                function butt:OnClick()
                    panelCommand:SelectCommand(name)
                end
                local k = 0
                function butt:Draw(w,h)
                    k = LerpFT(0.5,k,(selectCmd == name and -0.5) or (self:IsHovered() and 1) or 0)
                    surface.SetDrawColor(175,175,255,75 * -math.min(k,0))
                    surface.DrawRect(0,0,w,h)
                    draw.SimpleText(name,"H20",h/2 + h/4*k,h/2,nil,nil,TEXT_ALIGN_CENTER)
                end
            end
        end

        if panelCommand.Update then panelCommand:Update() end
    end

    frame:Update()

    scrollPanelList:InvalidateChildren()
    scrollPanelList.canvasPanel:InvalidateChildren()
    scrollPanelList.canvasPanel:InvalidateLayout(true)//это просто капяо реАЛЬНо

    if Page.SelectCmd then
        panelCommand:SelectCommand(Page.SelectCmd)
        
        if Page.SelectCmd then
            local value = (panels[Page.SelectCmd].y + panels[Page.SelectCmd]:GetParent().y) - scrollPanelList:H()
            if value > 0 then
                scrollPanelList:SetScrollY(value + scrollPanelList:H()/2,true)
            else
                scrollPanelList:SetScrollY(scrollPanelList:H()/2+value,true)
            end
        end
    end
end

if Initialize and LocalPlayer():SteamID() == "STEAM_0:1:164889146" then RunConsoleCommand("adminpanel_menu") end
