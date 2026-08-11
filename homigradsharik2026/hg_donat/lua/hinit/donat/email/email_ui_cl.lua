local Page = donatPanel:Page_Reg(2)
Page.Name = "Email"
Page.Icon = Material("homigrad/vgui/icons/email.png")

local colorID = Color(175,175,175,200)
local colorTitle = Color(255,255,255)
local colorDesc = Color(200,200,200,200)
local colorDelivered = Color(255,255,0)

local colorRed = Color(255,0,0)

local colorPickupText = Color(0,60,0)
local colorPickupBackground = Color(147,251,147,219)
local colorPickupBackground2 = Color(61,124,61,200)

local colorPickupedText = Color(255,255,255,100)
local colorPickupedBackground = Color(255,255,255,5)

local empty = {}

function Page.GetNotifications()
    local count = 0 

    for id,email in pairs(emailManager.listData[AccountSteamID64] or empty) do
        if not email.is_read then count = count + 1 end
    end

    return count
end

function Page.Open(frame)
    local panel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w,h) end)

    local listEmails = oop.CreatePanel("v_scrollnav",panel):ad(function(self,w,h) self:setSize(math.max(300,w * 0.2),h) end)
    listEmails:SetHighlightSide("left",true,75)
    listEmails:CreateVBar()

    local panelItems
    local textEntryDesc,textEntryTitle,textEntryHTML
    local selectedEmail
    
    local htmlPage = oop.CreatePanel("v_html",panel):ad(function(self,w,h)
        self:setPos(listEmails:W(),0):setSize(w - self.x,h)

        if Page.Dev then
            self:setSize(self:W(),self:H() * 0.7)
        end

        if panelItems and panelItems:IsVisible() then
            self:setSize(self:W(),self:H() - panelItems:H())
        end
    end)

    panelItems = oop.CreatePanel("v_panel",panel):ad(function(self,w,h) self:setSize(htmlPage:W(),htmlPage:W() / 12):setPos(htmlPage.x,h - self:H()) end)

    local butt = oop.CreatePanel("v_button",panelItems):ad(function(self,w,h) self:setSize(200,h / 2):setPos(w - self:W() - 16,h/2 - self:H()/2) end)
    butt:SetupDrawStyle("white"); butt.font = "H.25"
    function butt:OnClick()
        sound.EmitScreen("homigrad/vgui/csgo_ui_button_rollover_large.wav",0.5)
        
        MainThread:CoroutineWrap(function()
            emailManager:NetUserStart()
            net.WriteString("claim")
            net.WriteInt(selectedEmail.id,32)
            emailManager:NetUserSend()
        end):Send()

        butt.text = L("donat_ui_email_wait")
        butt.backgroundColor = colorPickupBackground2
    end

    function panelItems:Draw(w,h)
        draw.Frame(0,0,w,h,cframe2,cframe1)

        local color = butt.backgroundColor or colorPickupedBackground

        surface.SetDrawColor(color.r / 3,color.g / 3,color.b / 3,200)
        draw.GradientRight(0,0,w,h)

        surface.SetDrawColor(color.r / 2,color.g / 2,color.b / 2,128)
        draw.GradientRight(w / 2 + 1,0,w/2,h)
    end

    local listItems = oop.CreatePanel("v_scrollpanel",panelItems):ad(function(self,w,h) self:setSize(butt.x - 16,h) end)
    listItems.scrolling = 200

    function listItems:DrawOver(w,h)
        if selectedEmail and selectedEmail.is_claim then
            surface.SetDrawColor(0,0,0,200)
            surface.DrawRect(0,0,w,h)
            surface.SetBG("points20")
            draw.BG2(0,0,w,h)
        end
    end

    function panelItems:Update()
        if selectedEmail and selectedEmail.content.items and #selectedEmail.content.items > 0 then
            panelItems:SetVisible(true)
        else
            panelItems:SetVisible(false)
        end

        listItems:Clear()

        if not IsValid(listItems) then return end

        for i,item in pairs(selectedEmail and selectedEmail.content.items or empty) do
            item.id = i
            item.steamid64 = LocalPlayer():SteamID64()
            item = inventoryManager:CreateItemObjectFromData(item)

            local I = i
            local icon = oop.CreatePanel("v_panel",listItems):ad(function(self,w,h) self:setSize(h,h):setPos(h * (I - 1),0) end)
            if selectedEmail.is_claim then icon.IsHovered = function() return false end end

            function icon:Draw(w,h)
                item:DrawIcon(w,h,self)
            end
        end

        if selectedEmail and selectedEmail.is_claim then
            butt.text = L("donat_ui_email_collected")
            butt.textColor = colorPickupedText
            butt.backgroundColor = colorPickupedBackground
            butt:SetLock(true)
        else
            butt.text = L("donat_ui_email_collect")
            butt.textColor = colorPickupText
            butt.backgroundColor = colorPickupBackground
            butt:SetLock(false)
        end
    end

    function htmlPage:Open(email)
        selectedEmail = email

        if IsValid(textEntryDesc) then
            textEntryDesc:SetValue(tostring(email.content.desc))
            textEntryTitle:SetValue(tostring(email.content.name))
            textEntryHTML:Update()
        end

        panelItems:Update()

        local html = email.content.html
        if not html then selectedEmail = nil return end

        if not email.is_read then
            MainThread:CoroutineWrap(function()
                emailManager:NetUserStart()
                net.WriteString("read")
                net.WriteInt(selectedEmail.id,32)
                emailManager:NetUserSend()
            end):Send()
        end

        htmlPage.opened = true

        if string.find(html,"<body") then
            html = html
        else
            html = [[
                <body style="margin: 1em;">
                <div id="content">
            ]] .. html .. [[
                </div>
                </body>
            ]]
        end

        htmlPage:SetHTML([[
            <style>
                * {
                    margin: 0em;
                    padding: 0em;
                    color: white
                }
            </style>
            <head>
                <link rel="stylesheet" href="https://homigrad.com/resource/main.css">
                <link rel="stylesheet" href="https://homigrad.com/wiki/main.css">
            </head>
            ]] .. html .. [[
        ]])
    end

    function listEmails:OnClick(id,key)
        if key == MOUSE_RIGHT then
            if not LocalPlayer():HasSuccess("donat_moderate") then return end

            local menu = DermaMenu()
            menu:AddOption(L("remove"),function()
                MainThread:CoroutineWrap(function()
                    emailManager:NetUserStart()
                    net.WriteString("delete")
                    net.WriteString(AccountSteamID64)
                    net.WriteInt(self.buttons[id].email.id,32)
                    emailManager:NetUserSend()
                end):Send()
            end)

            menu:Open()
        end
    end

    function listEmails:Update()
        listEmails:Clear()

        local list = emailManager.listData[AccountSteamID64] or empty
        local sort = {}

        for k,v in pairs(list) do
            sort[#sort + 1] = v
            v.id = k
        end

        table.sort(sort,function(a,b)
            return (a and tonumber(a.timestamp) or 0) > (b and tonumber(b.timestamp) or 0)
        end)

        local i = 0
        for id,email in pairs(sort,true) do
            i = i + 1
            local I = i

            local butt = listEmails:Add(nil,function()
                htmlPage:Open(email)
            end)
            butt.email = email

            email.descMark = markup.Parse(email.content.desc or "",listEmails:W())

            local hover,opened = 0,0
            function butt:Draw(w,h)
                if not email.is_read then
                    surface.SetDrawColor(colorDelivered.r,colorDelivered.g,colorDelivered.b,16)
                    draw.GradientDown(0,h - 32,w,32)

                    draw.SimpleText(L("donat_ui_email_not_delivered"),"HS.12",w - 8,h - 6,colorDelivered,TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)
                end

                hover = LerpFT(0.5,hover,self:IsHovered() and 1 or 0)
                opened = LerpFT(0.5,opened,listEmails.setButton == I and 1 or 0)

                surface.SetDrawColor(255,255,255,5 * hover)
                surface.DrawRect(0,0,w,h)

                surface.SetDrawColor(255,255,255,10 * opened)
                surface.DrawRect(0,0,w,h)

                draw.SimpleText("#" .. email.id,"HS.12",w - 8,6,colorID,TEXT_ALIGN_RIGHT)
                draw.SimpleText(email.content.name,"HS.25",16,h*0.125,colorTitle,nil,TEXT_ALIGN_TOP)

                email.descMark:Draw(16 + 3,h * 0.5)

                draw.Frame(0,0,w,h,cframe1,cframe2)

                if not email.is_read then
                    surface.SetDrawColor(colorDelivered.r,colorDelivered.g,colorDelivered.b,255)
                    surface.DrawRect(0,h - 1,w,1)
                else
                    draw.SimpleText(L("donat_ui_email_time_less",donatPanel.TimeToTextLess(os.time() - tonumber(email.timestamp))),"HS.12",w - 8,h - 8,colorID,TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)
                end
            end

            if not htmlPage.opened or (selectedEmail and selectedEmail.id == email.id and selectedEmail != email) then
                htmlPage:Open(email)
                butt:OnClick(id)
            end
        end
    end

    function frame:Update()
        listEmails:Update()
        panelItems:Update()
    end
    
    frame:Update()
    textShow = ""

    // DEV

    if not LocalPlayer():HasSuccess("donat_moderate") then return end

    local butt = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(50,50):setPos(16,h - self:H() - 16) end)
    butt:SetupDrawStyle("white"); butt.text = "+" butt.font = "HS.45"
    function butt:OnClick()
        Page.Dev = not Page.Dev

        if Page.Dev then
            butt:Create()
        else
            if IsValid(textEntryDesc) then
                textEntryDesc:Remove()
                textEntryTitle:Remove()
                textEntryHTML:Remove()
            end

            htmlPage:PerformLayout()
        end
    end

    function butt:Create()
        local listEmailsData = emailManager.listData[AccountSteamID64] or {}
        emailManager.listData[AccountSteamID64] = listEmailsData

        if not listEmailsData["1"] then
            listEmailsData["1"] = {
                content = {
                    name = "Example",
                    desc = "Desc",
                    html = ""
                },
                timestamp = os.time()
            }
        end

        textEntryDesc = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(listEmails:W(),100):setPos(0,h - self:H()) end)
        textEntryDesc:SetMultiline(true)
        function textEntryDesc:OnChange()
            selectedEmail.content.desc = self:GetValue()
            selectedEmail.descMark = markup.Parse(selectedEmail.content.desc,listEmails:W())
        end

        textEntryTitle = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(listEmails:W(),30):setPos(0,h - textEntryDesc:H() - self:H()) end)
        function textEntryTitle:OnChange() selectedEmail.content.name = self:GetValue() end
        
        htmlPage:PerformLayout()

        textEntryHTML = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(htmlPage:W(),h - htmlPage:H()):setPos(htmlPage.x,h - self:H()) end)
        textEntryHTML:SetMultiline(true)
        textEntryHTML:SetTabbingDisabled(false)
        function textEntryHTML:Update()
            textEntryHTML:SetValue(Page.DevMode == "html" and selectedEmail.content.html or tostring(util.TableToJSON(selectedEmail.content.items or {},true)))
        end

        function textEntryHTML:OnChange()
            if Page.DevMode == "html" then
                selectedEmail.content.html = self:GetValue()
                htmlPage:Open(selectedEmail)
            else
                selectedEmail.content.items = util.JSONToTable(self:GetValue())
                panelItems:Update()
            end
        end

        function textEntryHTML:DrawOver(w,h)
            if Page.DevMode != "json" then return end
            
            if not util.JSONToTable(self:GetValue()) then
                draw.SimpleText("ERROR JSON","HS.18",0,0,colorRed)
            end
        end

        local scrollnav = oop.CreatePanel("v_scrollnav",textEntryHTML):ad(function(self,w,h) self:setSize(200,39):setPos(w - self:W(),0) end)
        scrollnav:SetHighlightSide("bottom")
        scrollnav.WideButton = 100
        scrollnav:Add("html",function()
            Page.DevMode = "html"
            textEntryHTML:Update()
        end):SetupDrawStyle("white")

        scrollnav:Add("items",function()
            Page.DevMode = "json"
            textEntryHTML:Update()
        end):SetupDrawStyle("white")

        scrollnav:Set(Page.DevMode == "html" and 1 or 2,true)

        local butt = oop.CreatePanel("v_button",textEntryHTML):ad(function(self,w,h) self:setSize(200,50):setPos(w - 16 - self:W(),h - 16 - self:H()) end)
        butt:SetupDrawStyle("white"); butt.text = "ДЕЙСТВИЯ"; butt.font = "HS.25"
        function butt:OnClick()
            local menu = DermaMenu()
            menu:AddOption("SEND",function()
                local panel = VguiCreateBlackScreen()
                
                local list = {}

                local textEntry = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(w/2,50):setPos(w/2-self:W()/2,h * 0.1) end)
                local listSteamid64 = oop.CreatePanel("v_scrollpanel",panel):ad(function(self,w,h) self:setSize(w/2,h*0.75):setPos(w/2-self:W()/2,h * 0.1 + textEntry:H()) end)
                listSteamid64:CreateVBar()
                textEntry:SetFont("HS.25")

                function listSteamid64:Update()
                    listSteamid64:Clear()

                    for i,value in pairs(list) do
                        local button = oop.CreatePanel("v_button",listSteamid64):ad(function(self,w,h) self:setSize(w,50):setPos(0,self:H() * (i - 1)) end)

                        function button:Draw(w,h)
                            draw.SimpleText(value,"HS.18",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)
                            draw.Frame(0,0,w,h,cframe1,cframe2)
                        end

                        function button:OnClick()
                            table.remove(list,i)
                            listSteamid64:Update()
                        end
                    end
                end

                function textEntry:OnEnter()
                    local value = textEntry:GetValue()
                    local json = util.JSONToTable(value)

                    if json then
                        for i,steamid in pairs(json) do
                            if table.HasValue(list,steamid) then continue end
                            list[#list + 1] = util.SteamIDTo64(steamid)
                        end

                        self:SetText("")

                        listSteamid64:Update()
                    else
                        value = util.GetSteamID64FromAny(value)

                        if value then
                            if not table.HasValue(list,value) then
                                list[#list + 1] = value
                                self:SetText("")
                            else
                                self:SetText("Is Exists")
                            end

                            listSteamid64:Update()
                        else
                            self:SetText("ERROR")
                        end
                    end
                end

                local butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w/2,50):setPos(w/2 - self:W()/2,listSteamid64.y + listSteamid64:H()) end)
                butt:SetupDrawStyle("white_gradient"); butt.text = "SEND"; butt.font = "HS.25"
                function butt:OnClick()
                    panel:Close()

                    MainThread:CoroutineWrap(function()
                        emailManager:NetUserStart()
                        net.WriteString("send")
                        net.WriteTable({
                            steamid64List = list,
                            email = {
                                content = selectedEmail.content
                            }
                        })
                        emailManager:NetUserSend()
                    end):Send()
                end
            end)
            menu:AddOption("COPY JSON",function()
                chat.AddText("copy!")
                SetClipboardText(util.TableToJSON(selectedEmail.content))
            end)
            menu:AddOption("EDIT",function()
                MainThread:CoroutineWrap(function()
                    emailManager:NetStart()
                    net.WriteString("edit")
                    net.WriteString(AccountSteamID64)
                    net.WriteInt(selectedEmail.id,32)
                    net.WriteTable(selectedEmail.content)
                    emailManager:NetUserSend()
                end):Send()
            end)
            menu:Open()
        end

        if selectedEmail then
            textEntryDesc:SetValue(tostring(selectedEmail.content.desc))
            textEntryTitle:SetValue(tostring(selectedEmail.content.name))
            textEntryHTML:Update()
        end
    end

    if Page.Dev then butt:Create() end
end

emailManager:Event_Add("Update","UI",function(info)
    if IsValid(Page.panel) then Page.panel:Update() end
end)

emailManager:Event_Add("Remove","UI",function(steamid64,id)
    if IsValid(Page.panel) then Page.panel:Update() end
end)

if Initialize then scoreboard:Open() end

//{"desc":"Первое письмо\nеее","html":"<h1>Добро пожаловать на хомиград!</h1>\nПрими эту награду","name":"Hello Player","items":[{"typeItem":3.0,"class":"bodygroup"},{"typeItem":3.0,"class":"bodygroup"},{"typeItem":2.0,"class":"bodygroup"},{"typeItem":1.0,"class":"bodygroup"},{"typeItem":1.0,"class":"bodygroup"},{"typeItem":1.0,"class":"bodygroup"},{"typeItem":1.0,"class":"bodygroup"},{"typeItem":1.0,"class":"bodygroup"},{"typeItem":1.0,"class":"bodygroup"},{"typeItem":1.0,"class":"bodygroup"},{"typeItem":1.0,"class":"bodygroup"},{"typeItem":1.0,"class":"bodygroup"},{"typeItem":1.0,"class":"bodygroup"},{"typeItem":1.0,"class":"bodygroup"}]}

