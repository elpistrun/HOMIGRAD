local PANEL = oop.Reg("v_donat_itemlist_panel","v_panel")
if not PANEL then return end

PANEL:Event_Add("Init","Main",function(self)
    local frame = self
    frame.listItems = {}

    local scrollnav = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(w,50) end)
    scrollnav:SetHighlightSide("bottom",nil,true)
    scrollnav:SetupDrawStyle("whitebox")

    local AccountSteamID64 = LocalPlayer():SteamID64()
    local inventoryList = inventoryManager.listGame[AccountSteamID64]

    local panelItem = oop.CreatePanel("v_donat_item_panel",frame):ad(function(self,w,h) self:setSize(w * (1/3.3),h - scrollnav:H()):setPos(w - self:W(),scrollnav:H()) end)
    panelItem:SetInventory(inventoryList)

    local iconSize = 1

    local scrollPanel = oop.CreatePanel("v_scrollpanel",frame):ad(function(self,w,h)
        self:setPos(0,scrollnav:H()):setSize(w - panelItem:W(),h - self.y)

        local new = math.floor(self:W() / 7)

        if iconSize != new then
            iconSize = new

            if self.SelectCategory then self:SelectCategory(self.category) end
        end
    end)

    scrollPanel:CreateVBar()
    scrollPanel.scrolling = 300
    self.scrollPanel = scrollPanel

    function scrollPanel:SelectCategory(name)
        self.category = name
        self:Clear()

        local x,y = 0,0

        for _,item in pairs(inventoryManager:SortItemList(inventoryList,name)) do
            if frame.FilterItem and frame:FilterItem(item) == false then continue end

            local id = item.id
            
            local X,Y = x,y
            
            local icon = oop.CreatePanel("v_button",scrollPanel):ad(function(self,w,h) self:setSize(iconSize,iconSize):setPos(X,Y) end)
            
            x = x + icon:W()
            
            if x + iconSize > self:W() then
                x = 0
                y = y + iconSize
            end

            icon.soundDown = nil

            function icon:Draw(w,h)
                item:DrawIcon(w,h,self)
                
                if self:IsHovered() then
                    panelItem:SetItem(id)
                end

                if frame.listItems[item] then
                    surface.SetDrawColor(255,255,255)
                    surface.DrawRect(0,0,w,2)
                    surface.DrawRect(0,h - 2,w,2)
                    surface.DrawRect(0,2,2,h)
                    surface.DrawRect(w - 2,0,2,h)
                end

                if Outfit_GetPlayerModelID and Outfit_GetPlayerModelID(AccountSteamID64) == id then
                    surface.SetDrawColor(255,255,255)
                    draw.GradientDown(0,h - 4,w,3)
                    
                    draw.SimpleText("Экипипрован","HS.18",w/2,8,nil,TEXT_ALIGN_CENTER)
                end
            end

            function icon:OnClick()
                if frame.listItems[item] then
                    frame.listItems[item] = nil
                else
                    frame.listItems[item] = true
                end

                if frame.Update then frame:Update() end
            end
        end
    end

    for name,categoryName in SortedPairs(DonatCategories) do
        if not scrollPanel.category then scrollPanel:SelectCategory(name) end

        local butt = scrollnav:Add(L(categoryName),function() scrollPanel:SelectCategory(name) end)
        butt:SetupDrawStyle("white_gradient")
    end
end)

function PANEL:Build()
    self.scrollPanel:SelectCategory(self.scrollPanel.category)
end