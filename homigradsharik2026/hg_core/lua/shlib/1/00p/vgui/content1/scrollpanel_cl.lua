local PANEL = oop.Reg("v_scrollpanel","v_panel")
if not PANEL then return end

function PANEL:OnInit()
    self.canvasPanel = oop.CreatePanel("v_panel")
    self.canvasPanel.dontParentOnCanvas = true
    self.canvasPanel:SetParent(self)

    self.canvasPanel:Event_Add("Perform","ScrollPanel",function()
        self:PerformCanvasPanel()
        self:InvalidateParent()
    end,10)

    self:SetMouseInputEnabled(true)

    self.scrollY = 0
    self.scrollX = 0

    self.setScrollX = 0
    self.setScrollY = 0

    self.scrollMul = 1
    self.scrolling = 50

    self.scrollLerp = 0.25

    self.subX = 0
    self.subY = 0
end

PANEL:Event_Add("Child Added","ScrollPanel",function(self,panel)
    if not panel.dontParentOnCanvas then panel:SetParent(self.canvasPanel) end
end)

function PANEL:SetScrollY(value,fast)
    self.setScrollY = math.Clamp(value,0,math.max(self.canvasPanel:H() - self:H(),0))
    if fast then self.scrollY = self.setScrollY end
end

function PANEL:SetScrollX(value,fast)
    self.setScrollX = math.Clamp(value,0,math.max(self.canvasPanel:W() - self:W(),0))
    if fast then self.scrollX = self.setScrollX end
end

function PANEL:LinkScrollPanel(panel)
    self.linkScrollPanel = panel
end

PANEL:Event_Add("Think","Main",function(self)
    local linkScrollPanel = self.linkScrollPanel

    if IsValid(linkScrollPanel) then
        self.setScrollY = linkScrollPanel.setScrollY
        self.setScrollX = linkScrollPanel.setScrollX
        
        self.scrollY = linkScrollPanel.scrollY
        self.scrollX = linkScrollPanel.scrollX
    else
        self.scrollY = LerpFTLess(self.scrollLerp,self.scrollY or 0,self.setScrollY)
        self.scrollX = LerpFTLess(self.scrollLerp,self.scrollX or 0,self.setScrollX)
    end

    if self.x ~= self.scrollX or self.y ~= self.scrollY then
        self.canvasPanel:SetPos(-self.scrollX,-self.scrollY)
    end
end)

function PANEL:OnMouseWheeled(value)
    local func = self.OnWheel
    if func and func(self,value) == false then return end

    value = -value * self.scrolling * self.scrollMul
    value = value * (input.IsButtonDown(KEY_LSHIFT) and 4 or 1) 

    if self.canvasPanel:H() <= self:H() then
        self:SetScrollX(self.scrollX + value)
    else
        self:SetScrollY(self.scrollY + value)
    end
end

function PANEL:Clear()
    for i,child in pairs(self.canvasPanel:GetChildren()) do
        if child.dontClear then continue end

        child:Remove()
    end
end

function PANEL:CanvasH() return self.canvasPanel:H() end
function PANEL:CanvasW() return self.canvasPanel:W() end

//

function PANEL:GetScrollY()
    local h = math.max(self:CanvasH() - self:H(),0)
    if h == 0 then return 0 end

    return 1 - (h - self.scrollY) / h
end

function PANEL:GetScrollBarYSize()
    local h = math.max(self:CanvasH() - self:H(),0)
    if h == 0 then return 0 end
    
    return self:H() * (self:H() / (self:H() + h))
end

function PANEL:GetScrollBarY()
    return (self:H() - self:GetScrollBarYSize()) * self:GetScrollY()
end

function PANEL:GetScrollX()
    local w = math.max(self:CanvasW() - self:W(),0)
    if w == 0 then return 0 end

    return 1 - (w - self.scrollX) / w
end

function PANEL:GetScrollBarXSize()
    local w = math.max(self:CanvasW() - self:W(),0)
    if w == 0 then return 0 end
    
    return self:W() * (self:W() / (self:W() + w))
end

function PANEL:GetScrollBarX()
    return (self:W() - self:GetScrollBarXSize()) * self:GetScrollX()
end

//

PANEL:Event_Add("Perform","ScrollPanel",function(self)
    self:PerformCanvasPanel()
end)

function PANEL:PerformCanvasPanel()
    local panel = self.canvasPanel
    local subX,subY = 0,0

    if self.vbar and not self.vbar.ignoreSize then subX = self.vbar:W() end
    if self.hbar and not self.hbar.ignoreSize then subY = self.hbar:H() end

    self.subX = subX
    self.subY = subY
    
    local w,h = panel:GetChildrenSize()

    if self.canvasW then
        w = self.canvasW
    else
        w = math.max(w,self:W()) - subX
    end

    if self.canvasH then
        h = self.canvasH
    else
        h = math.max(self.canvasH or h,self:H()) - subY
    end

    panel:SetSize(w,h)

    self:SetScrollY(self.setScrollY)
    self:SetScrollX(self.setScrollX)
end

function PANEL:CreateVBar(width)
    if IsValid(self.vbar) then return end
    
    width = width or 10

    local vbar = oop.CreatePanel("v_panel")
    vbar.dontParentOnCanvas = true
    vbar:SetParent(self)
    vbar:ad(function(_,w,h) vbar:setSize(width,h):setPos(w - vbar:W(),0)  end)

    function vbar.Draw(vbar,w,h)
        surface.SetDrawColor(15,15,15,200)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(255,255,255,vbar.isDown and 200 or 125)
        local y,h = self:GetScrollBarY(),self:GetScrollBarYSize()
        surface.DrawRect(0,y,w,h)

        vbar:SetCursor(vbar.isDown and "hand" or "arrow")
    end

    function vbar.Step(vbar)
        local mx,my = vbar:GetMousePos()

        local scrollBarY,scrollBarH = self:GetScrollBarY(),self:GetScrollBarYSize()

        if scrollBarH == 0 then return end

        vbar.isDown = vbar.grabY or (mx > 0 and mx < vbar:W() and my > scrollBarY and my <= scrollBarY + scrollBarH)

        if vbar.mouse[MOUSE_LEFT] then
            if vbar.isDown then
                vbar.grabY = vbar.grabY or (my - scrollBarY)
            elseif vbar:IsHovered() then
                vbar.grabY = my > scrollBarY + scrollBarH and scrollBarH or 0
            end
        end

        if vbar.grabY then
            if not vbar.mouse[MOUSE_LEFT] then
                vbar.grabY = nil
            else
                self:SetScrollY((self:CanvasH() - self:H()) * ((my - vbar.grabY) / (vbar:H() - self:GetScrollBarYSize())),true)
            end
        end
    end

    self.vbar = vbar
end

function PANEL:RemoveVBar()
    if not IsValid(self.vbar) then return end
    self.vbar:Remove()
    self.vbar = nil
end

function PANEL:CreateHBar(width)
    if IsValid(self.hbar) then return end
    
    width = width or 20

    local hbar = oop.CreatePanel("v_panel")
    hbar.dontParentOnCanvas = true
    hbar:SetParent(self)
    hbar:ad(function(_,w,h) hbar:setSize(w,width):setPos(0,h - hbar:H())  end)

    function hbar.Draw(hbar,w,h)
        surface.SetDrawColor(15,15,15,200)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(255,255,255,hbar.isDown and 200 or 125)
        surface.DrawRect(self:GetScrollBarX(),0,self:GetScrollBarXSize(),h)

        hbar:SetCursor(hbar.isDown and "hand" or "arrow")
    end

    function hbar.Step(hbar)
        local mx,my = hbar:GetMousePos()

        local scrollBarX,scrollBarW = self:GetScrollBarX(),self:GetScrollBarXSize()
        if scrollBarW == 0 then return end

        hbar.isDown = hbar.grabX or (mx > scrollBarX and mx < scrollBarX + scrollBarW and my > 0 and my <= hbar:H())

        if hbar.mouse[MOUSE_LEFT] then
            if hbar.isDown then
                hbar.grabX = hbar.grabX or (mx - scrollBarX)
            elseif hbar:IsHovered() then
                hbar.grabX = mx > scrollBarX + scrollBarW and scrollBarW or 0
            end
        end

        if hbar.grabX then
            if not hbar.mouse[MOUSE_LEFT] then
                hbar.grabX = nil
            else
                self:SetScrollX((self:CanvasW() - self:W()) * ((mx - hbar.grabX) / (hbar:W() - self:GetScrollBarXSize())),true)
            end
        end
    end

    self.hbar = hbar
end

function PANEL:WBar() return self.vbar:W() end
function PANEL:HBar() return self.hbar:H() end