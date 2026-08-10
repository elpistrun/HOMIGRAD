local ITEM = inventoryManager:ItemReg("receiver",{"base","base_use"},true)
if not ITEM then return INCLUDE_BREAK end

ITEM.category = "3_icons"

ITEM.ReceiveList = {
    ["common"] = {{class = "bodygroup",type = 1}},
    ["uncommon"] = {{class = "bodygroup",type = 1},{class = "bodygroup",type = 1}},
    ["rary"] = {{class = "bodygroup",type = 2}},
    ["legendary"] = {{class = "bodygroup",type = 3}},
    ["epic"] = {{class = "bodygroup",type = 4}},
}

function ITEM:GetPrintName()
    return "Ресивер"
end

function ITEM:GetRaryType()
    return "common"
end

ITEM.DefaultUses = 50

function ITEM:GetCountUse()
    return self.data.countUse or self.DefaultUses
end

function ITEM:GetDesc()
    return "Перерабатывает предметы в бодигруппы (xp)"
end

function DonatItem_CanReceive(item)
    if item.CanReceive then return item:CanReceive() end

    return true
end

function ITEM:CanReceive() return false end

function ITEM:CanReceiveItem(item)
    if item.class == "bodygroup" or not DonatItem_CanTrade(item) or not DonatItem_CanReceive(item) then return false end

    return true
end

ITEM.WorldModel = "models/props_se/pipes/pipe_accessory_manometer.mdl"
ITEM.WorldVec = Vector(90,3,-3.9)
ITEM.WorldAng = Angle(-5,25,45)

if SERVER then return end

function ITEM:DrawObject(w,h,panel,desc)
    local mdl = self:GetCSM(self.WorldModel)

    self:OpenScene(w,h,panel,20)
        mdl:SetPos(self.WorldVec)
        mdl:SetAngles(self.WorldAng)
        mdl:DrawModel()
    self:CloseScene(w,h,panel)

    self:DrawCountUse(w,h,panel,desc)
end

local listItems = {}

function ITEM:CreateDescPanel(panel)
    local butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,h/3) end)
    butt:SetupDrawStyle("white") butt.text = "ПОДРОБНЕЕ" butt.font = "HS.45"
    
    function butt.OnClick()
        local frame = VguiCreateBlackScreen("reciever")

        local panel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w * 0.9,h * 0.8):setPos(w/2-self:W()/2,h/2-self:H()/2) end)
        function panel:DrawOver(w,h) draw.Frame(0,0,w,h,cframe1,cframe2) end

        local panelItem = oop.CreatePanel("v_donat_item_panel",panel):ad(function(self,w,h) self:setSize(w * (1/3.33),h):setPos(w - self:W(),0) end)
        panelItem.descPanel.type = "shop"

        local selectItem,selectItemAnchor

        function panelItem:DrawOver()
            self:SetItemEx(selectItem,selectItemAnchor)
            selectItem = nil
        end

        local scrollPanel = oop.CreatePanel("v_scrollpanel",panel):ad(function(self,w,h) self:setSize(w - panelItem:W(),h) end)
        scrollPanel:CreateVBar()

        local hBarText = 100
        local yRary = hBarText

        local text = markup.Parse([[
Обменивает редкость предмета на все предметы из шаблона редкости<br>
Если положить предмет с [Обычной] редкостью, выпадёт всё что находится в шаблоне [Обычный]
        ]],scrollPanel:W())

        function scrollPanel:Draw(w,h)
            text:Draw(16,16)
        end

        local iconSize = math.floor(panel:H() / 7)

        for typeRary,list in SortedPairs(self.ReceiveList) do
            local panel = oop.CreatePanel("v_panel",scrollPanel)
            
            local hBar = 40

            function panel:Draw(w,h)
                local raryData = DonatItemsRaryData[typeRary]
                
                surface.SetDrawColor(raryData[1])
                draw.GradientLeft(0,0,w,hBar)
                draw.SimpleText(raryData[7],"H.18",hBar/2,hBar/2,raryData[2],nil,TEXT_ALIGN_CENTER)

                draw.Frame(0,0,w,hBar,cframe1,cframe2)
            end
            
            local x,y = 0,hBar

            for i,item in pairs(list) do
                item = inventoryManager:CreateItemObjectFromData(item)

                local icon = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(iconSize,iconSize) end)
                function icon:Draw(w,h)
                    item:DrawIcon(w,h,self)

                    if self:IsHovered() then
                        selectItem = item
                        panelItem:SetItemEx(item)
                    end
                end

                function icon:OnClick(w,h)
                    selectItemAnchor = item
                    panelItem:SetItemEx(item)
                end

                icon:setPos(x,y)

                x = x + icon:W()
                if x + iconSize > scrollPanel:W() then
                    x = 0
                    y = y + iconSize
                end
            end

            panel:setSize(scrollPanel:W(),math.max(y,iconSize + hBar))
            panel:setPos(0,yRary)
            yRary = yRary + panel:H()
        end
    end

    local butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,h/3):setPos(0,h/3) end)
    butt:SetupDrawStyle("white") butt.text = "ДОБАВИТЬ ПРЕДМЕТЫ" butt.font = "HS.45"

    function butt.OnClick()
        if self.requestWait or panel.type == "shop" then return end

        local frame = VguiCreateBlackScreen("reciever")
        
        local panel = oop.CreatePanel("v_donat_itemlist_panel",frame):ad(function(self,w,h) self:setSize(w * 0.9,h * 0.8):setPos(w/2-self:W()/2,h/2-self:H()/2) end)
        function panel:DrawOver(w,h)
            draw.Frame(0,0,w,h,cframe1,cframe2)
        end

        function panel.FilterItem(_,item)
            if not self:CanReceiveItem(item) then return false end
        end

        panel.listItems = listItems
        
        function frame:DrawContent(w,h)
            draw.SimpleText("РЕСИВЕР","HS.45",w/2,panel.y/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end

    function butt:Step()
        local count = table.Count(listItems)
        butt.text = count == 0 and "ДОБАВИТЬ ПРЕДМЕТЫ" or count .. " ПРЕДМЕТОВ"
    end


    local butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,h/3):setPos(0,h/3*2) end)
    butt:SetupDrawStyle("white") butt.text = "ПЕРЕРАБОТАТЬ" butt.font = "HS.45"
    
    function butt.OnClick()
        if panel.type == "shop" then return end

        if table.Count(listItems) == 0 then
            LocalPlayer():EmitSound("homigrad/vgui/buttonrollover.wav")

            return
        end

        local newList = {}

        for item in pairs(listItems) do
            newList[item.id] = true
        end
        
        self.requestWait = true
        
        MainThread:CoroutineWrap(function()
            self.requestWait = nil

            self:NetUserRequest({cmd = "receiver",list = newList})
        end):Send()

        listItems = {}
    end
end

function ITEM:UpdatePost(cmd)
    LocalPlayer():EmitSound("homigrad/vgui/csgo_ui_contract_seal.wav")
end