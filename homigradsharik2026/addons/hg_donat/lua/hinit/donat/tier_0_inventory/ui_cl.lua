local Page = donatPanel:Page_Reg(3)
Page.Name = "donat_ui_inventory"
Page.Icon = Material("homigrad/vgui/icons/inventory_donat.png")

local colorRed = Color(255,0,0)

local EditItem,EditItemID

local categoryNameSave

function Page.Open(frame)
    Page.panel = frame

    local listGame = inventoryManager.listGame[AccountSteamID64]

    local selectItemID
    local selectItemAnchorID

    local panelItem = oop.CreatePanel("v_donat_item_panel",frame):ad(function(self,w,h) self:setSize(w * (1/3.3),h):setPos(w - self:W(),0) end)
    panelItem:SetInventory(listGame)

    --

    local navPanel = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(w - panelItem:W(),50) end)
    navPanel:SetHighlightSide("bottom",nil,true)
    navPanel:SetupDrawStyle("whitebox")

    local pagesPanel = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h)
        self:setPos(0,navPanel:H()):setSize(navPanel:W(),h - self.y)
    end)

    pagesPanel:SetHorizontal(true)
    
    function pagesPanel:Draw(w,h)
        panelItem:SetItem(selectItemAnchorID)
    end

    local panelAdminPanel
    local openAdminPanel = function(callback)
        if IsValid(panelAdminPanel) then panelAdminPanel:Remove() end
        panelAdminPanel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(pagesPanel:W(),pagesPanel:H()/2):setPos(pagesPanel.x,h - self:H()) end)
        function panelAdminPanel:Draw(w,h)
            surface.SetDrawColor(0,0,0,100)
            surface.DrawRect(0,0,w,h)
            DrawBlurByPanel(5,self)
            draw.Frame(0,0,w,h,cframe1,cframe2)
        end

        local close = oop.CreatePanel("v_button",panelAdminPanel):ad(function(self,w,h) self:setSize(50,50):setPos(16,h - 16 - 50) end)
        close:SetupDrawStyle("white"); close.text = "CLOSE"; close.font = "HS.12"
        function close:OnClick() if callback then callback() end panelAdminPanel:Remove() end

        return panelAdminPanel
    end

    //

    local categories = {}

    local iconSize
    
    for name,categoryName in SortedPairs(DonatCategories) do
        local page = pagesPanel:Add()
        local scrollPanel = oop.CreatePanel("v_scrollpanel",page):setDSize(1,1)
        scrollPanel.canvasPanel:AddFlexParent()
        scrollPanel:CreateVBar()
        scrollPanel.scrolling = 256

        local i = #pagesPanel.canvasPanel:GetChildren()
        local butt = navPanel:Add(L(categoryName),function() pagesPanel:Set(i) categoryNameSave = name end)
        butt:SetupDrawStyle("white_gradient"); butt.gradientSide = "bottom"; butt.font = "HS.18"

        categories[name] = scrollPanel

        scrollPanel:ad(function(self,w,h)
            iconSize = math.floor(w / 7) - self.vbar:W()/w
        end)

        if categoryNameSave == name then
            navPanel:Set(i)
            pagesPanel:Set(i)
        end
    end

    local OpenEditItem = function()
        if not EditItem then EditItemID = nil return end
        
        local panel = openAdminPanel(function() EditItem = nil EditItemID = nil end)
                            
        local textEntry = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(w,h - 50 - 32) end)
        textEntry:SetMultiline(true)
        textEntry:SetText(EditItem)

        local error = not JSONToTable(EditItem)

        function textEntry:DrawOver(w,h)
            if error then
                draw.SimpleText("ERROR JSON","H.12",0,0,colorRed)
            end
        end

        function textEntry:OnChange()
            EditItem = self:GetText()
            error = not JSONToTable(EditItem)
        end

        local send = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(50,50):setPos(w - 16 - self:W(),h - 16 - 50) end)
        send:SetupDrawStyle("white"); send.text = "SUMBIT"; send.font = "HS.12"
        function send:OnClick()
            if error then return end

            local id,json = EditItemID,EditItem
            
            MainThread:CoroutineWrap(function()
                inventoryManager:NetUserRequest({
                    steamid64 = AccountSteamID64,
                    cmd = "edit",
                    id = id,
                    json = json
                })
            end):Send()

            EditItem = nil
            EditItemID = nil
            panel:Remove()
        end
    end

    function frame:Update()
        for name,page in pairs(categories) do
            page:Clear()

            local x,y = 0,0
            for _,item in pairs(inventoryManager:SortItemList(listGame,name)) do
                local id = item.id
                
                local X,Y = x,y
                
                local icon = oop.CreatePanel("v_button",page):ad(function(self,w,h) self:setSize(iconSize,iconSize):setPos(X,Y) end)
                
                x = x + icon:W()
                
                if x + iconSize > page:W() then
                    x = 0
                    y = y + iconSize
                end

                icon.soundDown = nil

                function icon:Draw(w,h)
                    item:DrawIcon(w,h,self)
                    
                    if self:IsHovered() then
                        panelItem:SetItem(id)
                    end

                    if selectItemID == id then
                        surface.SetDrawColor(255,255,255)
                        surface.DrawRect(0,h - 1,w,1)
                    end

                    if outfitManager:GetPlayerModelID(AccountSteamID64) == id then
                        surface.SetDrawColor(255,255,255)
                        draw.GradientDown(0,h - 4,w,3)
                        
                        draw.SimpleText("Экипипрован","HS.18",w/2,8,nil,TEXT_ALIGN_CENTER)
                    end
                end
                function icon:OnClick(key)
                    if key == MOUSE_RIGHT and LocalPlayer():HasSuccess("donat_moderate") then
                        local menu = DermaMenu()
                        menu:AddOption("Edit",function()
                            EditItem = {
                                class = listGame[id].class,
                                type = listGame[id].type,
                            }

                            for k,v in pairs(listGame[id].data or {}) do EditItem[k] = v end

                            EditItem = util.TableToJSON(EditItem,true)
                            EditItemID = id

                            OpenEditItem(id,item,AccountSteamID64)
                        end)
                        menu:AddOption("Clone",function()
                            MainThread:CoroutineWrap(function()
                                inventoryManager:NetUserRequest({
                                    steamid64 = AccountSteamID64,
                                    cmd = "clone",
                                    id = id
                                })
                            end):Send()
                        end)
                        menu:AddOption("Delete",function()
                            MainThread:CoroutineWrap(function()
                                inventoryManager:NetUserRequest({
                                    steamid64 = AccountSteamID64,
                                    cmd = "delete",
                                    id = id,
                                })
                            end):Send()
                        end)
                        menu:Open()
                    end
                    
                    if key == MOUSE_LEFT then
                        selectItemAnchor = item
                        selectItemAnchorID = id
                    end
                end
                if EditItemID == id then OpenEditItem(id,item,steamid64) end
            end
        end

        if selectItemID then panelItem:SetItem(selectItemID,true) end
    end

    if LocalPlayer():HasSuccess("donat_moderate") then
        local addItem = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(50,50):setPos(16,h - 50 - 16) end)
        addItem:SetupDrawStyle("white"); addItem.text = "+"; addItem.font = "HS.45"
        function addItem:OnClick()
            local panel = openAdminPanel()

            local itemsList = oop.CreatePanel("v_scrollpanel",panel):ad(function(self,w,h) self:setSize(w,h - 50 - 32) end)
            itemsList:CreateVBar()
            itemsList.canvasPanel:AddFlexParent()
            itemsList.scrolling = 200

            for className,class in pairs(inventoryManager.listClass) do
                if class[2].doNotShowInUI then continue end

                local item = inventoryManager:CreateItemObjectFromData({class = className})

                local icon = oop.CreatePanel("v_button",itemsList):ad(function(self,w,h) self:setSize(160,160) end):AddByFlex()
                function icon:Draw(w,h) item:DrawIcon(w,h,self) end

                function icon:OnClick(key)
                    if key ~= MOUSE_LEFT then return end
                    
                    MainThread:CoroutineWrap(function()
                        inventoryManager:NetUserRequest({
                            steamid64 = AccountSteamID64,
                            cmd = "add",
                            className = className
                        })
                    end):Send()
                end
            end
        end
    end

    frame:Update()
end

inventoryManager:Event_Add("Add","UI",function(steamid64,item)
    if IsValid(Page.panel) and Page.panel.Update then Page.panel:Update() end
end)

inventoryManager:Event_Add("Delete","UI",function(steamid64,item)
    if IsValid(Page.panel) and Page.panel.Update then Page.panel:Update() end
end)

inventoryManager:Event_Add("Update","UI",function(steamid64,item)
    if IsValid(Page.panel) and Page.panel.Update then Page.panel:Update() end
end)

if Initialize then scoreboard:Open() end
