local ITEM = inventoryManager:ItemReg("case","base",true)
if not ITEM then return INCLUDE_BREAK end

DonatCasesClasses = DonatCasesClasses or {}

ITEM.category = "5_case"

function ITEM:GetCaseInfo()
    return DonatCasesClasses[self.type or ""]
end

local empty = {}

function ITEM:GetRaryType()
    return (self:GetCaseInfo() or empty).raryType or "common"
end

function ITEM:GetDesc()
    return (self:GetCaseInfo() or empty).desc or ""
end

function ITEM:GetPrintName()
    return (self:GetCaseInfo() or empty).name or "Missing Case"
end

function ITEM:GetCasinoItem()
    local caseInfo = self:GetCaseInfo()

    local totalWeight = 0

    for _,set in pairs(caseInfo.casino) do
        totalWeight = totalWeight + set.weight
    end

    local rand = math.random() * totalWeight
    local cumulativeWeight = 0
    
    for _,set in pairs(caseInfo.casino) do
        cumulativeWeight = cumulativeWeight + set.weight

        if rand <= cumulativeWeight then
            local number

            rand = math.random() * #set.list
            cumulativeWeight = 0

            for i,item in pairs(set.list) do
                cumulativeWeight = cumulativeWeight + 1
                if rand <= cumulativeWeight then return set.list[i],set.weight end
            end
        end
    end
end

function ITEM:CanReceive() return false end

if SERVER then return end

local colorWhite = Color(255,255,255,235)
local colorBlack = Color(0,0,0,235)

function ITEM:DrawObject(w,h,panel,desc)
    local caseInfo = self:GetCaseInfo()
    if not caseInfo then return end

    local mdl = self:GetCSM(caseInfo.model)

    local mdlLock = CSM.GetByID("models/jaggedsprings/lock.mdl","mdlLock" .. self.type)

    if caseInfo.subMaterial0 then
        mdl:SetSubMaterial(0,caseInfo.subMaterial0)
    end

    self:OpenScene(w,h,panel,20)
        mdl:SetPos(caseInfo.modelVec)
        mdl:SetAngles(caseInfo.modelAng)
        mdl:DrawModel()

        local pos,ang = LocalToWorld(caseInfo.modelLockVec,caseInfo.modelLockAng,caseInfo.modelVec,caseInfo.modelAng)
        mdlLock:SetPos(pos)
        mdlLock:SetAngles(ang)
        mdlLock:DrawModel()
    self:CloseScene(w,h,panel)
end

function ITEM:CreateDescPanel(panel)
    local butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setPos(0,0):setSize(w,50) end)
    butt:SetupDrawStyle("white") butt.text = "Что выпадает?" butt.font = "HS.25"

    function butt.OnClick()
        local frame = VguiCreateBlackScreen("case_info")
        
        local selectedItem,selectedItemAnchor

        local panel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w * 0.9,h * 0.8):setPos(w/2-self:W()/2,h/2-self:H()/2) end)
        function panel:DrawOver(w,h) draw.Frame(0,0,w,h,cframe1,cframe2) end

        local panelItem = oop.CreatePanel("v_donat_item_panel",panel):ad(function(self,w,h) self:setSize(w * (1/3.33),h):setPos(w - self:W(),0) end)
        panelItem.descPanel.type = "shop"

        function panelItem:DrawOver()
            self:SetItemEx(selectedItem or selectedItemAnchor)
            selectedItem = nil
        end

        local scrollPanel = oop.CreatePanel("v_scrollpanel",panel):ad(function(self,w,h) self:setSize(w - panelItem:W(),h) end)
        scrollPanel:CreateVBar()
        scrollPanel.scrolling = 300

        local caseInfo = self:GetCaseInfo()

        local iconSize = math.floor(scrollPanel:W() / 8)

        local yRary = 0

        local panelInfo = oop.CreatePanel("v_panel",scrollPanel)
        panelInfo:setPos(0,0)
        panelInfo:setSize(scrollPanel:W(),100)

        local text = markup.Parse([[
Как работает выпадение предмета?<br>
Рандомно выберается число от 0 до 100<br>
Потом мы берём все шаблоны (6%, 15%, 50%) и ищем с самым низким шансом.<br>
Если число которое у нас выпало будет ниже шаблона, то этот шаблон выберается и выпадает рандомный предмет из этого шаблона.<br>
Берём количество предметов с шаблона (например 8) и делим на 1 (1 / 8) будет шанс 12,5% того что выпадет этот предмет из шаблон (то-есть шансы одинаковы)
        ]],panelInfo:W())

        yRary = panelInfo:H()

        function panelInfo:Draw(w,h)
            text:Draw(16,16)
        end

        local totalWeight = 0

        for i,set in pairs(caseInfo.casino) do
            totalWeight = totalWeight + set.weight
        end

        for i,set in pairs(caseInfo.casino) do
            local panelRary = oop.CreatePanel("v_panel",scrollPanel)

            local textH = 40

            function panelRary:Draw(w,h)
                surface.SetDrawColor(0,0,0,255)
                draw.GradientLeft(0,0,w,textH)

                draw.SimpleText(math.Round((set.weight / totalWeight) * 100 * 100) / 100 .. "%","HS.18",textH/2,textH/2,nil,nil,TEXT_ALIGN_CENTER)

                draw.Frame(0,0,w,textH,cframe1,cframe2)
            end

            local x,y = 0,0
            
            for i,itemData in pairs(set.list) do
                if x + iconSize > scrollPanel:W() then
                    x = 0
                    y = y + iconSize
                end
                
                local butt = oop.CreatePanel("v_button",panelRary):ad(function(self,w,h) self:setSize(iconSize,iconSize) end)
                butt:setPos(x,textH + y)

                local item = inventoryManager:CreateItemObjectFromData(itemData)

                function butt:Draw(w,h)
                    item:DrawIcon(w,h,self,"H.12")

                    if self:IsHovered() then
                        selectedItem = item
                        panelItem:SetItemEx(item)
                    end
                end

                function butt:OnClick() selectedItemAnchor = item panelItem:SetItemEx(item) end

                x = x + iconSize
            end

            panelRary:setSize(scrollPanel:W(),y + iconSize + textH)
            panelRary:setPos(0,yRary)
            yRary = yRary + panelRary:H()
        end
    end

    if self.class == "case" then
        local buttBuy = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,50):setPos(0,h - self:H()) end)
        
        function buttBuy.Draw(_,w,h)
            local canOpen = false

            local data = inventoryManager.listData[AccountSteamID64] or {}
            for id,item in pairs(data) do
                if item.class == "case_key" and item.type == self.type then canOpen = true break end
            end

            if canOpen then
                buttBuy:SetLock(panel.type == "shop")

                surface.SetDrawColor(0,255,0,100)
                surface.DrawRect(0,0,w,h)
                surface.SetDrawColor(0,255,0,255)

                local size = h + h * 0.25 * math.cos(RealTime())
                draw.GradientDown(0,h - size + 1,w,size)

                draw.SimpleText(panel.type == "shop" and "У ВАС ЕСТЬ КЛЮЧ" or "ОТКРЫТЬ КЕЙС","H.25",w/2,h/2,buttBuy:IsHovered() and colorWhite or colorBlack,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            else
                buttBuy:SetLock(true)

                surface.SetDrawColor(255,0,0,100)
                surface.DrawRect(0,0,w,h)
                surface.SetDrawColor(255,0,0,255)

                local size = h + h * 0.25 * math.cos(RealTime())
                draw.GradientDown(0,h - size + 1,w,size)

                draw.SimpleText("НЕТ КЛЮЧА","H.25",w/2,h/2,colorBlack,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end
        end

        function buttBuy.OnClick()
            if panel.type == "shop" then return end

            MainThread:CoroutineWrap(function()
                local success,data = self:NetUserRequest({cmd = "open"})

                if success then
                    self:CreateRollMenu(data.item)
                end
            end):Send()
        end
    end

    local panelNeed = oop.CreatePanel("v_panel",panel):ad(function(self,w,h) self:setPos(0,butt:H()):setSize(w,h - self.y - 50) end)

    local itemNeed

    if self.class == "case" then
        itemNeed = inventoryManager:CreateItemObjectFromData({class = "case_key",type = self.type,data = self.data})
    else
        itemNeed = inventoryManager:CreateItemObjectFromData({class = "case",type = self.type,data = self.data})
    end

    local panelTitle = oop.CreatePanel("v_panel",panelNeed):ad(function(self,w,h) self:setSize(w,25) end)

    function panelTitle.Draw(_,w,h)
        draw.SimpleText(self.class == "case" and "Открывается ключём" or "Открывает кейс","HS.12",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local icon = oop.CreatePanel("v_panel",panelNeed):ad(function(self,w,h)
        local size = h - panelTitle:H()
        self:setSize(size,size):setPos(w/2-size/2,panelTitle:H())
    end)

    function icon:Draw(w,h)
        itemNeed:DrawIcon(w,h,self,"H.12")
    end
end

/*
local list = {}

concommand.Add("TESTTTT",function()
    local self = DonatInventoryList[LocalPlayer():SteamID64()][305]

    local item,rary = self:GetCasinoItem()

    item = DonatItem_Create(item,item)

    print(rary,item:GetRaryType(),item:GetPrintName())

    list[rary] = list[rary] or {}
    list[rary][#list[rary] + 1] = item
end)

concommand.Add("TESTTTT2",function()
    local sort = {}

    local count = 0

    for rary,list in pairs(list) do
        print(rary)

        for id,item in pairs(list) do
            print("\t",item.item,item.rand)

            count = count + 1
        end
    end

    print(count)
end)
*/