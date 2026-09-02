scoreboard.pages[101].list[6] = scoreboard.pages[101].list[6] or {}
local Page = scoreboard.pages[101].list[6]

Page.Name = "donat_ui_shop"

local colorBlack = Color(0,0,0)
local colorWhite = Color(255,255,255)
local color_gold = Color(255,255,0)
local colorRed = Color(255,0,0)

function Page.Open(frame)
    Page.panel = frame
        
    local scrollNav = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(math.max(w/6,250),h) self.WideButton = h / 13 end)
    scrollNav:SetHighlightSide("right"); scrollNav:SetupDrawStyle("whitebox")

    local panelItem = oop.CreatePanel("v_donat_item_panel",frame):ad(function(self,w,h) self:setSize(w/3.3,h):setPos(w - self:W(),0) end)
    panelItem.itemCreatePanel:Remove()
    panelItem.descPanel.type = "shop"

    local panelBuy = oop.CreatePanel("v_button",panelItem):ad(function(self,w,h) self:setSize(w,math.max(h * 0.05,60)):setPos(0,h - self:H()) end)

    panelItem.descPanel:ad(function(self,w,h) self:setPos(0,panelItem.descItem:H()):setSize(w,h - panelBuy:H() - self.y) end)
    
    local selectItem
    local selectItemAnchor

    function panelItem:DrawOver()
        self:SetItemEx(selectItem or selectItemAnchor)
        selectItem = nil
    end

    local scrollPage = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h) self:setSize(w - scrollNav:W() - panelItem:W(),h):setPos(scrollNav:W(),0) end)
    scrollPage:SetHorizontal(false)

    local hoverItem

    for idCategory,category in pairs(ShopConfig) do
        local page = scrollPage:Add()
        local butt = scrollNav:Add(category.name,function() Page.SelectCategory = idCategory scrollPage:Set(idCategory) end)
        butt:SetupDrawStyle("white_gradient"); butt.text = L(category.name); butt.font = "HS.18"

        if category.funcCreate then
            local items = {}

            for i,item in pairs(category.list) do
                item = util.tableCopy(item)
                item.categoryID = idCategory
                item.categoryItemID = i

                items[i] = item
            end

            category.funcCreate(page,items,panelItem)
        else
            local iconSize
            local scrollPanel = oop.CreatePanel("v_scrollpanel",page)
            scrollPanel:CreateVBar()
            scrollPanel:ad(function(self,w,h) self:setSize(w,h) iconSize = math.floor((w - self.vbar:W())/6) end)
            scrollPanel.scrolling = iconSize * 3
            scrollPanel.canvasPanel:AddFlexParent()

            for i,item in pairs(category.list) do
                if item.category and item.list then
                    local panel = oop.CreatePanel("v_panel",scrollPanel)
                    panel:AddFlexParent()
                    panel:ad(function(self,w,h)
                        local cw,ch = panel:GetChildrenSize()
                        panel:setSize(scrollPanel:W(),ch)
                    end):AddByFlex()

                    local panelTitle = oop.CreatePanel("v_panel",panel):ad(function(self,w,h) self:setSize(w,40) end):AddByFlex()
                    function panelTitle:Draw(w,h)
                        surface.SetDrawColor(0,0,0)
                        draw.GradientLeft(0,0,w,h)
                        draw.SimpleText(item.category,"H.18",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)
                        draw.Frame(0,0,w,h,cframe1,cframe2)
                    end

                    for id,item in pairs(item.list) do
                        local item = inventoryManager:CreateItemObjectFromData(item)
                        
                        item.price = item.data.price
                        item.priceDonat = item.data.priceDonat

                        item.categoryID = idCategory
                        item.categorySubID = i
                        item.categoryItemID = id

                        local icon = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(iconSize,iconSize) end):AddByFlex()
                        icon.type = "shop"

                        function icon:Draw(w,h)
                            item:DrawIcon(w,h,self)
                            draw.SimpleText(donatPanel.XPToText(item.price or item.priceDonat),"HS.18",8,8,item.priceDonat and color_gold or colorWhite)

                            if self:IsHovered() then selectItem = item panelItem:SetItemEx(item) end
                            if selectItem == item then
                                surface.SetDrawColor(255,255,255)
                                surface.DrawRect(0,h - 2,w,2)
                            end
                        end
                        function icon:OnClick()
                            selectItemAnchor = item
                            panelItem:SetItemEx(item)
                        end
                    end
                else
                    item = inventoryManager:CreateItemObjectFromData(item)
                    item.categoryID = idCategory
                    item.categoryItemID = i

                    item.price = item.data.price
                    item.priceDonat = item.data.priceDonat

                    local icon = oop.CreatePanel("v_button",scrollPanel):ad(function(self,w,h) self:setSize(iconSize,iconSize) end):AddByFlex()
                    icon.type = "shop"

                    function icon:Draw(w,h)
                        item:DrawIcon(w,h,self)
                        draw.SimpleText(donatPanel.XPToText(item.price or item.priceDonat),"HS.18",8,8,item.priceDonat and color_gold or colorWhite)

                        if self:IsHovered() then selectItem = item panelItem:SetItemEx(item) end
                        if selectItem == item then
                            surface.SetDrawColor(255,255,255)
                            surface.DrawRect(0,h - 2,w,2)
                        end
                    end
                    function icon:OnClick()
                        selectItemAnchor = item
                        panelItem:SetItemEx(item)
                    end
                end
            end
        end
    end

    function frame:Draw(w,h)
        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)
        DrawBlurByPanel(5,self)
    end

    if Page.SelectCategory then
        scrollPage:Set(Page.SelectCategory,true)
        scrollNav:Set(Page.SelectCategory,true)
    end

    function panelBuy:Draw(w,h)
        surface.SetDrawColor(0,0,0,50)
        surface.DrawRect(0,0,w,h)

        self:SetLock(true)

        local item = selectItem or selectItemAnchor
        if not item then return end

        if (item.price and tonumber(balanceManager.listData[AccountSteamID64].balance) >= item.price) or (item.priceDonat and tonumber(balanceManager.listData[AccountSteamID64].balance_donat) >= item.priceDonat) then
            self:SetLock(false)
            
            surface.SetDrawColor(0,255,0,100)
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(0,255,0,255)

            local size = h + h * 0.25 * math.cos(RealTime())
            draw.GradientDown(0,h - size + 1,w,size)

            draw.SimpleText(L("donat_ui_shop_buy",(item.price or item.priceDonat)),"H.25",w/2,h/2,self:IsHovered() and (item.priceDonat and color_gold or colorWhite) or colorBlack,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        else
            surface.SetDrawColor(255,0,0,100)
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(255,0,0,255)
            local size = h + h * 0.25 * math.cos(RealTime())
            draw.GradientDown(0,h - size + 1,w,size)

            draw.SimpleText(L("donat_ui_shop_not_enough"),"H.25",w/2,h/2,self:IsHovered() and colorWhite or colorBlack,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end

        draw.Frame(0,0,w,h,cframe2,cframe1)
    end

    function panelBuy:OnClick()
        if selectItemAnchor.ClickBuy then
            selectItemAnchor:ClickBuy(panelItem.descPanel)
        end

        local panel = VguiCreateBlackScreen()
        sound.EmitScreen("homigrad/vgui/menu_invalid.wav",0.25)

        local textEntryCount = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(h * 0.1,h * 0.075):setPos(w/2-self:W()/2,h/2 + h/3) end)
        textEntryCount:SetNumeric(true)
        textEntryCount:SetValue(1)
        textEntryCount:SetFont("H.45")

        function textEntryCount:GetCount() return math.max(tonumber(self:GetValue()) or 1,1) end

        local buttYes = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w * 0.3,h * 0.075):setPos(w/2-self:W() - h/12,h/2 + h/3) end)
        buttYes:SetupDrawStyle("white_gradient"); buttYes.text = L("yes"); buttYes.font = "HS.45"
        function buttYes:DrawOver()
            self.gradientSide = self:IsHovered() and "bottom" or ""
        end
        function buttYes:OnClick()
            local totalBuy = (selectItemAnchor.price or selectItemAnchor.priceDonat) * textEntryCount:GetCount()
            local balance = selectItemAnchor.price and balanceManager.listData[AccountSteamID64].balance or balanceManager.listData[AccountSteamID64].balance_donat

            if balance - totalBuy < 0 then
                LocalPlayer():StopSound("homigrad/vgui/weapon_cant_buy.wav")
                LocalPlayer():EmitSound("homigrad/vgui/weapon_cant_buy.wav")

                return
            end
            
            net.Start("shop_buy")
            net.WriteInt(selectItemAnchor.categoryID,11)
            net.WriteInt(selectItemAnchor.categorySubID or 0,11)
            net.WriteInt(selectItemAnchor.categoryItemID,11)
            net.WriteInt(textEntryCount:GetCount(),7)
            net.SendToServer()
            panel:Close()
        end

        local buttNo = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w * 0.3,h * 0.075):setPos(w/2 + h/12,h/2 + h/3) end)
        buttNo:SetupDrawStyle("white_gradient"); buttNo.text = L("no"); buttNo.font = "HS.45";
        function buttNo:DrawOver()
            self.gradientSide = self:IsHovered() and "bottom" or ""
        end
        function buttNo:OnClick() panel:Close() end

        local panelIcon = oop.CreatePanel("v_panel",panel):ad(function(self,w,h) self:setSize(h/2,h/2):setPos(w/2-self:W()/2,h/2-self:H()/2) end)
        function panelIcon:OnWheel(wheel) self.wheel = wheel end
        function panelIcon:Draw(w,h)
            local k = panel:GetK()
            surface.SetAlphaMultiplier(k)
            render.SetBlend(math.ease.InExpo(k))
            render.ClearDepth()
            selectItemAnchor:DrawBigIcon(w,h,self)
            surface.SetAlphaMultiplier(1)
            render.SetBlend(0)
        end

        function panel:DrawContent(w,h,k)
            local raryData = DonatItemsRaryData[selectItemAnchor:GetRaryType()]
            local color = raryData[1]
            surface.SetDrawColor(color.r,color.g,color.b,5)
            surface.DrawRect(0,0,w,h)

            surface.SetDrawColor(color.r/2,color.g/2,color.b/2,128)
            local size = h + h * 0.25 * math.cos(RealTime())
            draw.GradientDown(0,h - size + 1,w,size)

            local color = selectItemAnchor.priceDonat and color_gold or colorWhite

            draw.SimpleText(L("donat_ui_shop_realy_buy"),"HS.45",w/2,h * 0.15 * k,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            draw.SimpleText(L(selectItemAnchor.priceDonat and "donat_ui_shop_buy_for_donat" or "donat_ui_shop_buy_for",donatPanel.XPToText(selectItemAnchor.price or selectItemAnchor.priceDonat)),"HS.25",w/2,h * 0.2 * k,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            
            local balance = selectItemAnchor.price and balanceManager.listData[AccountSteamID64].balance or balanceManager.listData[AccountSteamID64].balance_donat
            draw.SimpleText(L("donat_ui_shop_balance",donatPanel.XPToText(balance)),"HS.25",buttYes.x,h * 0.79 + (h - h * 0.79) * (1 - k),color,nil,TEXT_ALIGN_CENTER)

            local totalBuy = (selectItemAnchor.price or selectItemAnchor.priceDonat) * textEntryCount:GetCount()
            draw.SimpleText("Будет вычтено: " .. donatPanel.XPToText(totalBuy),"HS.25",w/2,h * 0.79 + (h - h * 0.79) * (1 - k),color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            if balance - totalBuy < 0 then
                draw.SimpleText("Недостаточно средств! " .. donatPanel.XPToText(balance - totalBuy),"HS.25",buttNo.x + buttNo:W(),h * 0.79 + (h - h * 0.79) * (1 - k),colorRed,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
            else
                draw.SimpleText("Балан после покупки " .. donatPanel.XPToText(balance - totalBuy),"HS.25",buttNo.x + buttNo:W(),h * 0.79 + (h - h * 0.79) * (1 - k),color,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
            end

            local k = 1 - k
            local y = h/2 + h/3 + (h - (h/2 + h/3)) * k
            buttYes:setPos(buttYes.x,y)
            buttNo:setPos(buttNo.x,y)
        end
    end
end

if Initialize then scoreboard:Open() end