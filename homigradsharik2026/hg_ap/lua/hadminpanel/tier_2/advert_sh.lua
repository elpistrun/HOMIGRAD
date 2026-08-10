if CLIENT then
    adminPanelAdvert = ManagerCreate("adminPanelAdvert",{"node"})

    function adminPanelAdvert:InputFull(body)
        adminPanelAdvert.listData = JSONToTable(body)

        adminPanelAdvert:Event_Call("Update")
    end
end

adminPanel.commandRegistry("advert_add",
    {
        {type = "string",name = "message",required = true},
        {type = "number",name = "time",required = true},
        {type = "number",name = "r",required = true},
        {type = "number",name = "g",required = true},
        {type = "number",name = "b",required = true},
        {type = "string",name = "id"}
    },
    "async",
    nil,
    "project"
).UICreate = function(panelCommand,panelCommandRight)
    function panelCommand:Update()
        panelCommand:Clear()

        local y = 0
        
        local function create(id,advert)
            local Y = y
            local panel = oop.CreatePanel("v_panel",panelCommand):ad(function(self,w,h) self:setSize(w,200):setPos(0,Y) end)
            y = y + panel:H()
            local textEntryMessage = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(w,60) end)
            textEntryMessage:SetMultiline(true)
            textEntryMessage:SetPlaceholderText("message")
            textEntryMessage:SetValue(advert.message or "")

            local textEntryTime = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(w,30):setPos(0,60) end)
            textEntryTime:SetNumeric(true)
            textEntryTime:SetPlaceholderText("time in seconds")
            if advert.time then textEntryTime:SetValue(advert.time) end

            local mixer = oop.CreatePanel("v_colormixer",panel):ad(function(self,w,h) self:setSize(w - 200,h - 90):setPos(0,90) end)
            mixer:SetAlphaBar(false)
            mixer:SetPalette(false)
            mixer:SetColor(advert.color or Color(255,255,255))

            local send = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setPos(mixer:W(),mixer.y):setSize(w - self.x,40) end)

            send.text = advert.message and "set" or "Added"

            function send:OnClick()
                local color = mixer:GetColor()
                RunConsoleCommand("ulx_cmd","advert_add",textEntryMessage:GetValue() or "null",textEntryTime:GetValue() or 300,color.r,color.g,color.b,advert.message and id)
            end

            if advert.message then
                local send = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setPos(mixer:W(),mixer.y + 40):setSize(w - self.x,40) end)
                send.text = "Remove"
                function send:OnClick()
                    RunConsoleCommand("ulx_cmd","advert_remove",tostring(id))
                end
            end
        end

        for id,advert in pairs(adminPanelAdvert.listData) do
            create(id,advert)
        end

        local Y = y
        local panel = oop.CreatePanel("v_panel",panelCommand):ad(function(self,w,h) self:setSize(w,30):setPos(0,Y) end)
        y = y + panel:H()

        function panel:Draw(w,h)
            surface.SetDrawColor(125,125,255,100)
            surface.DrawRect(0,0,w,h)
            draw.SimpleText("NEW","HS.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            draw.Frame(0,0,w,h,cframe1,cfreame2)
        end

        create(#adminPanelAdvert.listData + 1,{})
    end

    panelCommand:Update()
end

adminPanel.commandRegistry("advert_remove",{{type = "number",name = "id"}},"async",nil,"project").dontShowGUI = true

if CLIENT then
    adminPanelAdvert:Event_Add("Update","UI",function()
        if IsValid(adminpanel_menu) then adminpanel_menu.panelCommand:Update() end
    end)
end