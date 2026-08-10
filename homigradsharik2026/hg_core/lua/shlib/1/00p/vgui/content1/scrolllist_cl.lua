local PANEL = oop.Reg("v_scrolllist","v_panel")
if not PANEL then return end

PANEL:Event_Add("Init","ScrollList",function(self)
    self.rows = {}
    
    local frame = self

    self.filterPanel = oop.CreatePanel("v_panel",self):ad(function(self,w,h) self:setSize(w,18) end)
    local filterPanel = self.filterPanel

    self.scrollPanel = oop.CreatePanel("v_scrollpanel",self):ad(function(self,w,h) self:setPos(0,filterPanel:H()):setSize(w,h - self.y) end)
    self.scrollPanel:CreateVBar()
    self.scrollPanel.scrolling = 100

end)

function PANEL:AddRow(id,name,type)
    self.rows[id] = {
        name = name,
        type = type or "string"
    }

    self.list = {}

    self:UpdateRows()
end

function PANEL:AddItem(...)
    self.list[#self.list + 1] = {...}

    timer.Create(tostring(self),0,1,function()
        if not IsValid(self) then return end

        self:UpdateList()
    end)
end

function PANEL:UpdateRows()
    if not self.filterPanel then return end
    self.filterPanel:Clear()

    self.sortBy = 1

    local frame = self

    for i = 1,#self.rows do
        local row = self.rows[i]

        local button = oop.CreatePanel("v_button",self.filterPanel)
        row.button = button
        

        button.text = row.name

        button.w = (self.filterPanel:W() - self.scrollPanel.vbar:W()) / #self.rows
        
        button:ad(function(self,w,h)
            self:setSize(self.w,h)

            local lastButton = frame.rows[i - 1]

            if lastButton and lastButton.button then
                self:setPos(lastButton.button.x + lastButton.button:W(),0)
            end
        end)

        local grabX,grabW

        function button:OnMouse(key,down)
            if key == MOUSE_LEFT and down then
                grabX = gui.MouseX()
                grabW = self.w
            elseif key == MOUSE_RIGHT and down then
                if frame.sortBy == i then
                    frame.sortMode = not frame.sortMode
                end

                frame.sortBy = i

                frame:UpdateList()
            end
        end

        function button:Step()
            if input.IsButtonDown(MOUSE_LEFT) then
                if grabX then
                    self.w = math.max(grabW + (gui.MouseX() - grabX),16)

                    frame.filterPanel:InvalidateChildren()
                end
            elseif grabX then
                grabX = nil
            end
        end

        function button:OnClick()
            frame.sortBy = i
        end
    end

    frame.filterPanel:InvalidateChildren(true)
end

function PANEL:UpdateList()
    self.scrollPanel:Clear()
    
    local frame = self

    local listSorted = {}

    for i = 1,#self.list do
        listSorted[i] = self.list[i]
    end

    local filter = self.sortBy
    
    if filter and filter != 1 then
        if self.sortMode then
            table.sort(listSorted,function(a,b) return a[filter] > b[filter] end)
        else
            table.sort(listSorted,function(a,b) return a[filter] < b[filter] end)
        end
    end

    for i = 1,#listSorted do
        local I = i - 1
        local line = oop.CreatePanel("v_panel",self.scrollPanel):ad(function(self,w,h) self:setSize(w,18):setPos(0,self:H() * I) end)

        local info = listSorted[i]

        function line:Draw(w,h)
            if i % 2 == 0 then
                surface.SetDrawColor(20,20,20,100)
                surface.DrawRect(0,0,w,h)
                surface.DrawRect(0,0,w,1)
                surface.SetDrawColor(255,255,255,15)
                surface.DrawRect(0,h - 1,w,1)
            end

            if self:IsHovered() then
                surface.SetDrawColor(255,255,255,5)
                surface.DrawRect(0,0,w,h)
            end

            for i = 1,#info do
                local button = frame.rows[i].button

                markup.Parse(tostring(info[i]),button:W()):Draw(button.x,0)
            end

            if frame.DrawItem then
                frame:DrawItem(info,line,w,h)
            end
        end
    end
end

/*
timer.Simple(0,function()
    if IsValid(TEST) then TEST:Remove() end

    TEST = oop.CreatePanel("v_frame"):ad(function(self,w,h) self:setSize(w*0.8,h*0.8):setPos(w/2-self:W()/2,h/2-self:H()/2) end)
    TEST:MakePopup()
    
    local scrollList = oop.CreatePanel("v_scrolllist",TEST):ad(function(self,w,h) self:setSize(w,h) end)
    scrollList:AddRow(1,"Name")
    scrollList:AddRow(2,"Path")
    scrollList:AddRow(3,"Line")
    scrollList:AddRow(4,"Time","number")

    for i = 1,255 do
        scrollList:AddItem("name" .. i,"path",math.random(0,10) .. " - " .. math.random(20,50),math.Rand(0.1,0.0001))
    end
end)
*/