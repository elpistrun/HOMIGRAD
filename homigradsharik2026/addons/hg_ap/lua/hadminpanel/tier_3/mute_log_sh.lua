if CLIENT then
    adminPanel.commandCreate("mute_log_menu",function()
        managerLogMute:OpenMenu()
    end)

    function managerLogMute:CreateSearch(textEntryCaller,panel)
        function textEntryCaller:OnChange()
            managerLogMute.frame.findByCaller = textEntryCaller:GetValue()
        end

        function textEntryCaller:OnChange()
            managerLogMute.frame.findByCaller = textEntryCaller:GetValue()
        end
        
        local textEntryBanned = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setPos(textEntryCaller:W(),0):setSize(w - self.x,textEntryCaller:H()) end)
        textEntryBanned:SetPlaceholderText("Искать по забаненому")
        
        function textEntryBanned:OnChange()
            managerLogMute.frame.findByBanned = textEntryBanned:GetValue()
        end
    end

    function managerLogMute:CreateInfo(buttCaller,butt,info)
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
        end

        function butt:OnClick()
            local menu = DermaMenu()

            if info.content.steamid64 then
                menu:AddOption(L("copy_steamid64"),function()
                    chat.AddText(info.content.steamid64)
                    SetClipboardText(info.content.steamid64)
                end)
            end

            menu:AddOption("copy reason",function()
                chat.AddText(info.content.reason)
                SetClipboardText(info.content.reason)
            end)
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

    function managerLogMute:GetSteamid64Victim(info) return info.content.steamid64 end
    
    function managerLogMute:Request()
        local frame = managerLogMute.frame
        
        self:NetUserStart()
        self:RequestWrite(0,nil,frame.findByCaller)
        net.WriteString(frame.findByBanned or "")
        self:NetUserSend()
    end
end

adminPanel.commandRegistry("mute_log_menu",{},"game",nil,"admin")
adminPanel.commandRegistry("mute_log",{{type = "string",name = "page"},{type = "string",name = "findByAction"},{type = "string",name = "findByCaller"}},"async",nil,"admin")