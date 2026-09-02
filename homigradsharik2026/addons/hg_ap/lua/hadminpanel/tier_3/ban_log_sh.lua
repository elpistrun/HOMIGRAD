if CLIENT then
    adminPanel.commandCreate("ban_log_menu",function()
        managerLogBan:OpenMenu()
    end)

    function managerLogBan:CreateSearch(textEntryCaller,panel)
        function textEntryCaller:OnChange()
            managerLogBan.frame.findByCaller = textEntryCaller:GetValue()
        end

        function textEntryCaller:OnChange()
            managerLogBan.frame.findByCaller = textEntryCaller:GetValue()
        end
        
        local textEntryBanned = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setPos(textEntryCaller:W(),0):setSize(w - self.x,textEntryCaller:H()) end)
        textEntryBanned:SetPlaceholderText("Искать по забаненому")
        
        function textEntryBanned:OnChange()
            managerLogBan.frame.findByBanned = textEntryBanned:GetValue()
        end
    end

    function managerLogBan:CreateInfo(buttCaller,butt,info)
        function butt:Draw(w,h)
            surface.SetDrawColor(0,0,0,100)
            surface.DrawRect(0,0,w,h)

            draw.SimpleText(os.date("%d.%m.%y %H:%M:%S",tonumber(info.timestamp_create)),"HS.12",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)
            draw.SimpleText(info.content.reason,"HS.12",w - h/2,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

            local time

            if info.action == "SET" then
                if tonumber(info.content.time) == 0 then
                    time = "permament"
                else
                    local lessTime = tonumber(info.timestamp_create) + tonumber(info.content.time) - os.time()
                    
                    time = adminPanel.TimeToText(tonumber(info.content.time)) .. " / " .. ((lessTime > 0 and adminPanel.TimeToText(lessTime)) or L("ap_ui_less"))
                end
            else
                time = info.action
            end

            draw.SimpleText(time,"HS.12",w * 0.25,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            if info.content.content and info.content.content.info then
                self:DrawTip(info.content.content.info,1)
            end
        end

        function butt:OnClick()
            local menu = DermaMenu()

            menu:AddOption(L("copy_steamid64"),function()
                local steamid64 = managerLogBan:GetSteamid64Victim(info)

                chat.AddText(steamid64)
                SetClipboardText(steamid64)
            end)

            menu:AddOption("copy reason",function()
                chat.AddText(info.content.reason)
                SetClipboardText(info.content.reason)
            end)

            if info.content.content and info.content.content.info then
                menu:AddOption("copy hide info",function()
                    chat.AddText(info.content.content.info)
                    SetClipboardText(info.content.content.info)
                end)
            end
            
            menu:Open()
        end

        function buttCaller:OnClick()
            local menu = DermaMenu()
            menu:AddOption(L("copy_steamid64"),function()
                chat.AddText(info.caller)
                SetClipboardText(info.caller)
            end)
            menu:Open()
        end
    end

    function managerLogBan:GetSteamid64Victim(info) return info.content.old and info.content.old.steamid64 or info.content.steamid64 end
    
    function managerLogBan:Request()
        local frame = managerLogBan.frame
        
        self:NetUserStart()
        self:RequestWrite(0,nil,frame.findByCaller)
        net.WriteString(frame.findByBanned or "")
        self:NetUserSend()
    end
end

adminPanel.commandRegistry("ban_log_menu",{},"game",nil,"admin")
adminPanel.commandRegistry("ban_log",{{type = "string",name = "page"},{type = "string",name = "findByAction"},{type = "string",name = "findByCaller"}},"async",nil,"admin")