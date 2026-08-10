AdminPanelPages[2] = AdminPanelPages[2] or {}
local Page = AdminPanelPages[2]

Page.Name = "ap_ui_role"

function Page.CanOpen()
    return LocalPlayer():HasSuccess("role_list")
end

local black,white = Color(0,0,0),Color(255,255,255)

local selectedSuccess = "discord_role_name"

local function ClickSound()
    LocalPlayer():EmitSound("homigrad/vgui/buttonclick.wav",75,100,0.2)
end

function Page.Open(frame)
    local rolePanel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w*(1/4),h - 40):setPos(0,40) end)
    local scrollPanel = oop.CreatePanel("v_scrollpanel",rolePanel):ad(function(self,w,h) self:setSize(w,h - 400) end)
    scrollPanel:CreateVBar()
    
    local roleEdit = oop.CreatePanel("v_panel",rolePanel):ad(function(self,w,h) self:setSize(w,h - scrollPanel:H()):setPos(0,h - self:H()) end)

    local selectedRole = 1

    function roleEdit:Draw(w,h)
        surface.SetDrawColor(175,175,255,128)
        surface.DrawRect(0,0,w,30)
        draw.GradientRight(0,0,w,30)

        draw.SimpleText(selectedRole,"HS.18",w/2,15,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local textEntryTitle = oop.CreatePanel("v_textentry",roleEdit):ad(function(self,w,h) self:setSize(w/2,30):setPos(0,30) end)
    textEntryTitle:SetPlaceholderText(L("ap_ui_role_title"))
    function textEntryTitle:OnEnter()
        RunConsoleCommand("ulx_cmd","role_settitle",selectedRole,self:GetValue())
    end

    local textEntryName = oop.CreatePanel("v_textentry",roleEdit):ad(function(self,w,h) self:setSize(w/2,30):setPos(w/2,30) end)
    textEntryName:SetPlaceholderText(L("ap_ui_role_name"))
    function textEntryName:OnEnter()
        RunConsoleCommand("ulx_cmd","role_rename",selectedRole,self:GetValue())
    end

    local colorMixer = oop.CreatePanel("v_colormixer",roleEdit):ad(function(self,w,h) self:setSize(w,w/2):setPos(w/2-self:W()/2,60) end)
    colorMixer:SetAlphaBar(false)
    colorMixer:SetPalette(false)

    function colorMixer:ValueChanged(color)
        timer.Create("role_set_color",0.1,1,function()
            local role = adminPanelRole.list[selectedRole]

            role.content.color = role.content.color or color
            
            if color.r == role.content.color.r and color.g == role.content.color.g and color.b == role.content.color.b then return end

            RunConsoleCommand("ulx_cmd","role_setcolor",selectedRole,color.r,color.g,color.b)
        end)
    end

    local butt = oop.CreatePanel("v_button",roleEdit):ad(function(self,w,h) self:setSize(w,40):setPos(0,h - self:H()) end)
    butt.text = "Удалить роль"; butt.font = "HS.18"
    function butt:OnClick()
        VParametrAgree(L("ap_ui_realy_want_delete_role"),function()
            RunConsoleCommand("ulx_cmd","role_remove",selectedRole)
        end)
    end

    local butt = oop.CreatePanel("v_button",roleEdit):ad(function(self,w,h) self:setSize(w,40):setPos(0,h - 80) end)
    butt.text = L("ap_ui_role_low_ierarchy"); butt.font = "HS.18"
    function butt:OnClick()
        RunConsoleCommand("ulx_cmd","role_set_inherit",selectedRole,adminPanelRole.listHierarchyIndex[selectedRole] + 1)
    end

    local butt = oop.CreatePanel("v_button",roleEdit):ad(function(self,w,h) self:setSize(w,40):setPos(0,h - 120) end)
    butt.text = L("ap_ui_role_high_ierarchy"); butt.font = "HS.18"
    function butt:OnClick()
        RunConsoleCommand("ulx_cmd","role_set_inherit",selectedRole,adminPanelRole.listHierarchyIndex[selectedRole] - 1)
    end

    local iconSize = 48
    local corner = iconSize * 0.25
    local usersPanel = oop.CreatePanel("v_players",frame):ad(function(self,w,h) self:setSize(w*(1/4),h - 80):setPos(rolePanel:W(),40) end)
    usersPanel:Setup(iconSize)
    usersPanel.search:ad(function(self,w,h) self:setSize(w,40) end)
    usersPanel.search:SetPlaceholderText(L("ap_ui_enter_name_or_steamid32"))
    usersPanel.scrollPanel.scrolling = 200
    usersPanel:CreateVBar()
    function usersPanel:Filter(value,info) return value == "" or string.find(string.utf8lower(info.name or ""),value) or value == string.lower(info.id) end
        
    function usersPanel:OnClick(key,info)
        local menu = DermaMenu()
        menu:AddOption(L("copy_steamid"),function()
            chat.AddText(info.id)
            SetClipboardText(info.id)
        end)
        menu:AddOption(L("copy_nickname"),function()
            chat.AddText(info.name)
            SetClipboardText(info.name)
        end)
        menu:AddOption(L("ap_ui_user_delete_role"),function()
            RunConsoleCommand("ulx_cmd","role_user_remove",info.id,selectedRole)
        end)
        menu:AddOption(L("open_profile"),function() gui.OpenURL("https://steamcommunity.com/profiles/" .. util.SteamIDTo64(info.id) .. "/") end)
        menu:Open()
    end

    local textEntryUser = oop.CreatePanel("v_textentry",frame):ad(function(self,w,h) self:setSize(usersPanel:W(),40):setPos(usersPanel.x,h - self:H()) end)
    textEntryUser:SetPlaceholderText("STEAM_0:1:164889146")
    function textEntryUser:OnEnter()
        RunConsoleCommand("ulx_cmd","role_user_add",textEntryUser:GetValue(),selectedRole)
    end

    local successPanel = oop.CreatePanel("v_scrollpanel",frame):ad(function(self,w,h) self:setPos(usersPanel.x + usersPanel:W(),40):setSize((w - self.x) / 2,h - 40) end)
    successPanel:CreateVBar()
    successPanel.scrolling = 235

    local successEditPanel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setPos(successPanel.x + successPanel:W(),40):setSize(w - self.x,h - 40) end)
    
    local count = 0
    local lastUpdateTime = 0

    function frame:Draw(w,h)
        local k = lastUpdateTime - RealTime() + 1

        if k > 0 then
            surface.SetDrawColor(75,75,75,64 * k)
            surface.DrawRect(0,0,w,h)
        end

        w = rolePanel:W()
        surface.SetDrawColor(175,175,255,64)
        surface.DrawRect(0,0,w,40)
        surface.SetDrawColor(175,175,255,255)
        draw.GradientRight(0,0,w,40)
        draw.SimpleText(L("ap_ui_list_roles"),"HS.18",w/2,20,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        w = successPanel:W()
        local x = successPanel.x
        surface.SetDrawColor(175,175,255,255)
        surface.DrawRect(x,0,w,40)
        draw.SimpleText(L("ap_ui_list_success"),"HS.18",x + w/2,20,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        w = usersPanel:W()
        local x = usersPanel.x
        surface.SetDrawColor(175,175,255,255)
        surface.DrawRect(x,0,w,40)
        draw.SimpleText(L("ap_ui_db_count",count),"HS.18",x + 20,20,nil,nil,TEXT_ALIGN_CENTER)
        draw.SimpleText(L("ap_ui_users"),"HS.18",x + w/2,20,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        w = successEditPanel:W()
        local x = successEditPanel.x
        surface.SetDrawColor(175,175,255,64)
        surface.DrawRect(x,0,w,40)
        surface.SetDrawColor(175,175,255,255)
        draw.GradientLeft(x,0,w/2,40)
        draw.SimpleText(L("ap_ui_settings_success"),"HS.18",x + w/2,20,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        w = self:W()
        draw.Frame(0,0,w,40,cframe1,cframe2)
    end

    function frame:DrawOver(w,h)
        local k = lastUpdateTime - RealTime() + 1

        if k > 0 then
            surface.SetDrawColor(255,255,255,25 * k)
            surface.DrawRect(0,0,w,40)

            local x,y = self:GetMousePos( )
            draw.SimpleText("Updated!","HS.18",x + 16,y - 16 * (1 - k),Color(255,255,255,255 * math.min(k * 2,1)))
        end
    end
    
    function rolePanel:SelectRole(nameRole)
        selectedRole = nameRole
        
        roleEdit:SetVisible(selectedRole and true or false)
 
        local role = adminPanelRole.list[nameRole]
        if not role or not adminPanelRole.list[nameRole] or not adminPanelRole.listHierarchyIndex[nameRole] then return end

        count = adminPanelRole.listUser and table.Count(adminPanelRole.listUser[selectedRole] or {}) or 0

        textEntryTitle:SetValue(role.content.title or "")
        textEntryName:SetValue(selectedRole)
        colorMixer:SetColor(role.content.color or Color(255,255,255))
        timer.Remove("role_set_color")

        usersPanel:Clear()

        for steamid64 in SortedPairs(adminPanelRole.listUser[nameRole] or {}) do
            local profile = Profiles[steamid64]

            if profile then
                usersPanel:AddPanel(steamid64,profile.name or steamid64,profile.avatar,profile.avatarFrame,profile.background,profile.backgroundOpacity)
            else
                usersPanel:AddPanel(steamid64,steamid64)
            end
        end

        successPanel:Clear()

        local y = 0

        for category,list in SortedPairs(adminPanel.successCategory) do
            local Y = y
            local panelCategory = oop.CreatePanel("v_panel",successPanel):ad(function(self,w,h) self:setSize(w,30 + 30 * table.Count(list)):setPos(0,Y) end)
            y = y + panelCategory:H()

            function panelCategory:Draw(w,h)
                surface.SetDrawColor(185,185,255,64)
                surface.DrawRect(0,0,w,30)
                surface.SetDrawColor(185,185,255,128)
                draw.GradientLeft(0,0,w,30)
                
                draw.SimpleText(category,"HS.18",w/2,15,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end

            local y = 30
            for name in SortedPairs(list) do
                local Y = y
                local panel = oop.CreatePanel("v_button",panelCategory):ad(function(self,w,h) self:setSize(w,30):setPos(0,Y) end)
                y = y + panel:H()

                local k = 0
                local old
                function panel:Draw(w,h)
                    if selectedSuccess == name then
                        surface.SetDrawColor(175,175,255,48)
                        surface.DrawRect(0,0,w,h)
                    end

                    if role.content.success[name] then
                        surface.SetDrawColor(0,255,0)
                        surface.DrawRect(0,0,4,h)
                        surface.SetDrawColor(0,255,0,128)
                        draw.GradientLeft(0,0,w,h)
                    end
                    
                    k = LerpFT(0.5,k,selectedSuccess == name and -0.5 or self:IsHovered() and 1 or 0)
                    draw.SimpleText(name,"HS.18",h/2 + h/4*k,h/2,nil,nil,TEXT_ALIGN_CENTER)
                end
                function panel:OnClick()
                    if selectedSuccess == name then
                        ClickSound()
                        RunConsoleCommand("ulx_cmd","role_success_set",selectedRole,selectedSuccess,role.content.success[name] and 0 or 1)
                    end
                    
                    selectedSuccess = name

                    self:Build()
                end

                function panel:Build()
                    successEditPanel:Clear()

                    local y = 0
                    local Y = y
                    local butt = oop.CreatePanel("v_button",successEditPanel):ad(function(self,w,h) self:setSize(w,40):setPos(0,Y) end)
                    y = y + butt:H()
                    function butt:Draw(w,h)
                        if role.content.success[name] then
                            surface.SetDrawColor(0,255,0,128)
                            surface.DrawRect(0,0,w,h)
                            surface.SetDrawColor(0,255,0)
                            draw.GradientDown(0,0,w,h)

                            draw.SimpleText(L("ap_ui_success"),"H.25",w/2,h/2,black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                        else
                            surface.SetDrawColor(128,128,128,128)
                            surface.DrawRect(0,0,w,h)
                            surface.SetDrawColor(128,128,128)
                            draw.GradientDown(0,0,w,h)

                            draw.SimpleText(L("ap_ui_not_success"),"H.25",w/2,h/2,black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                        end

                        if self:IsHovered() then
                            surface.SetDrawColor(255,125528,255,5)
                            surface.DrawRect(0,0,w,h)
                        end
                    end
                    function butt:OnClick()
                        RunConsoleCommand("ulx_cmd","role_success_set",selectedRole,selectedSuccess,role.content.success[name] and 0 or 1)
                    end
                    
                    local parametrs = adminPanel.success[selectedSuccess].parametrs
                    
                    if parametrs then
                        for id,paramInfo in pairs(parametrs) do
                            local Y = y
                            local panel = oop.CreatePanel("v_panel",successEditPanel):ad(function(self,w,h) self:setSize(w,60):setPos(0,Y) end)
                            function panel:Draw(w,h)
                                surface.SetDrawColor(75,75,128,128)
                                draw.GradientLeft(0,0,w,30)
                                draw.Frame(0,0,w,30,cframe1,cframe2)
                    
                                draw.SimpleText(paramInfo.name or i,"HS.18",15,15,nil,nil,TEXT_ALIGN_CENTER)
                            end
                            local textEntry = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(w,30):setPos(0,30) end)
                            textEntry:SetValue(role.content.success[selectedSuccess] and role.content.success[selectedSuccess][id] or "")
                            function textEntry:OnEnter()
                                local value = self:GetValue() != "" and self:GetValue() or nil

                                if paramInfo.canParse then
                                    local success,err = paramInfo.canParse(value)
                                    
                                    if success == false then
                                        self:SetText("error: " .. tostring(err))
                                        
                                        LocalPlayer():EmitSound("homigrad/vgui/beep22.wav",75,100,0.2)

                                        return
                                    end

                                    if success != nil then textEntry:SetValue(tostring(success)) end
                                end

                                ClickSound()

                                adminPanel.commandSendToServer("role_success_set_parametr",{selectedRole,selectedSuccess,id,value})
                            end
                            y = y + panel:H()
                        end
                    end
                end

                if selectedSuccess == name then panel:Build() end
            end
        end
    end

    function frame:Update()
        lastUpdateTime = RealTime()
        rolePanel:SelectRole(selectedRole and not adminPanelRole.list[selectedRole] and "root" or selectedRole)
        
        scrollPanel:Clear()

        local y = 0
        for id,name in pairs(adminPanelRole.listHierarchy) do
            local role = adminPanelRole.list[name]
            if not role then continue end
            
            local Y = y
            local butt = oop.CreatePanel("v_button",scrollPanel):ad(function(self,w,h) self:setSize(w,30):setPos(0,Y) end)
            y = y + butt:H()
            function butt:Draw(w,h)
                local color = role.content.color or white
                surface.SetDrawColor(color.r,color.g,color.b,5)
                surface.DrawRect(0,0,w,h)

                surface.SetDrawColor(color.r,color.g,color.b,255)
                surface.DrawRect(0,0,4,h)
                surface.SetDrawColor(color.r,color.g,color.b,64)
                draw.GradientLeft(4,0,w,h)

                if selectedRole == name then
                    surface.SetDrawColor(color.r,color.g,color.b,128)
                    surface.DrawRect(4,0,w,h)
                end
                
                draw.SimpleText(name,"HS.18",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)
                if role.content.title then draw.SimpleText(role.content.title,"HS.18",w - h/2,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER) end
                
                if self:IsHovered() then
                    surface.SetDrawColor(255,255,255,5)
                    surface.DrawRect(4,0,w,h)
                end
            end
            function butt:OnClick()
                rolePanel:SelectRole(name)
            end
        end

        local butt = oop.CreatePanel("v_button",scrollPanel):ad(function(self,w,h) self:setSize(w,30):setPos(0,y) end)
        function butt:Draw(w,h)
            draw.SimpleText("+","HS.25",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            surface.SetDrawColor(255,255,255,2)
            surface.DrawRect(1,0,w - 1,h)

            if self:IsHovered() then
                surface.SetDrawColor(255,255,255,5)
                surface.DrawRect(0,0,w,h)
            end
        end
        function butt:OnClick()
            RunConsoleCommand("ulx_cmd","role_create","role #" .. #adminPanelRole.listHierarchy)
        end
    end

    frame:Update()

    rolePanel:SelectRole("root")
end

adminPanelRole:Event_Add("Update","UI",function()
    if adminpanel_menu and IsValid(adminpanel_menu[2]) then adminpanel_menu[2]:Update() end
end)

adminPanelRole:Event_Add("Update List","UI",function()
    if adminpanel_menu and IsValid(adminpanel_menu[2]) then adminpanel_menu[2]:Update() end
end)

if Initialize then RunConsoleCommand("adminpanel_menu") end
