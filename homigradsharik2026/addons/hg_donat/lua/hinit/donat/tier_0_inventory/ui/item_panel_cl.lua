local PANEL = oop.Reg("v_donat_item_panel","v_panel")
if not PANEL then return end

PANEL:Event_Add("Init","Main",function(self)
    local frame = self

    local icon = oop.CreatePanel("v_panel",self):ad(function(self,w,h) self:setSize(w,h * (1/2)):setPos(0,0) end)
    
    function icon:OnWheel(wheel)
        self.wheel = (self.wheel or 0) + wheel
    end

    function icon:Draw(w,h)
        surface.SetDrawColor(0,0,0,64)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(0,0,0,125)
        draw.GradientDown(0,0,w,h)

        local item = frame:GetItem()

        if not item then
            draw.Frame(0,0,w,h,cframe2,cframe1)
            
            frame:SetItem()
            frame:SetItemEx()

            return
        end

        item:DrawBigIcon(w,h,self)

        draw.Frame(0,0,w,h,cframe2,cframe1)
    end

    local frameDesc = oop.CreatePanel("v_panel",self):ad(function(self,w,h) self:setPos(0,icon:H()):setSize(w,h - self.y) end)
    local descItem = oop.CreatePanel("v_panel",frameDesc):ad(function(self,w,h) self:setSize(w,h * 0.3) end)
    self.descItem = descItem
    function descItem:SetText(value)
        if self.oldValue != value then
            self.oldValue = value
            
            self.markup = markup.Parse(value,self:W())
        end
    end

    function descItem:Draw(w,h)
        if not self.markup then return end
        
        self.markup:Draw(16,16)
    end

    local itemCreatePanel = oop.CreatePanel("v_panel",frameDesc):ad(function(self,w,h) self:setSize(w,h * 0.1):setPos(0,h - self:H()) end)
    self.itemCreatePanel = itemCreatePanel
    function itemCreatePanel:Draw(w,h)
        local item = frame:GetItem()
        if not item then return end

        draw.SimpleText(L("donat_ui_created",os.date("%d.%m.%Y %H:%M",item.timestamp_create)),"HS.18",w - 15,h - 20,colorGray,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
    end
    
    local descPanel = oop.CreatePanel("v_panel",frameDesc):ad(function(self,w,h)
        if IsValid(itemCreatePanel) then
            self:setPos(0,descItem:H()):setSize(w,h - self.y - itemCreatePanel:H())
        else
            self:setPos(0,descItem:H()):setSize(w,h - self.y)
        end
    end)

    self.descPanel = descPanel

    function descPanel:Draw(w,h)
        local item = frame:GetItem()
        if not item then return end

        if item.DrawDesc then item:DrawDesc(w,h,self) end
    end
end)

function PANEL:GetItem()
    if self.item then
        return self.item
    elseif self.inventoryList then
        return self.inventoryList[self.selectItemID]
    end
end

function PANEL:SetInventory(inventoryList)
    self.inventoryList = inventoryList
end

function PANEL:SetItem(itemID,force)
    if not force and self.selectItemID == itemID then return end
    self.selectItemID = itemID

    local item = self.inventoryList[itemID]

    local descPanel = self.descPanel
    descPanel:Clear()

    local descItem = self.descItem
    descItem:SetText("")

    if item then
        descItem:SetText(L(item:GetDesc()))
        
        if item.CreateDescPanel then item:CreateDescPanel(descPanel) end
    end
end

function PANEL:SetItemEx(item)
    if self.item == item then return end
    self.item = item

    local descPanel = self.descPanel
    descPanel:Clear()
    
    local descItem = self.descItem
    descItem:SetText("")

    if item then
        descItem:SetText(L(item:GetDesc()))

        if item.CreateDescPanel then item:CreateDescPanel(descPanel) end
    end
end