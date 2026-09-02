local PANEL = oop.Reg("v_scrollnav","v_panel")
if not PANEL then return end

function PANEL:OnInit()
    self.buttons = {}
    self.setButton = 1

    self.lerp = 0.3

    self:SetFont()
end

function PANEL:SetHighlightSide(side,useScrollPanel,wideButton)
    if wideButton == nil then wideButton = true end

    local firstRender = true

    self.side = side

    if side == "left" or side == "right" then
        self.WideButton = wideButton or 30

        local hY,hH = 0,0

        function self:DrawOver(w,h)
            local button = self.buttons[self.setButton]
            if not button then return end//lol

            if firstRender then
                firstRender = nil
                hY = button.y
                hH = button:H()
            else
                hY = LerpFTLess(self.lerp,hY,button.y,0.001)
                hH = LerpFTLess(self.lerp,hH,button:H(),0.001)
            end

            self:DrawHighlightSide(w,h,hY,hH,side)
        end
    elseif side == "top" or side == "bottom" then
        self.WideButton = wideButton or 200

        local hX,hW = 0,0

        function self:DrawOver(w,h)
            local button = self.buttons[self.setButton]
            if not button then return end//lol

            if firstRender then
                firstRender = nil
                hX = hX,button.x
                hW = button:W()
            else
                hX = LerpFTLess(self.lerp,hX,button.x,0.001)
                hW = LerpFTLess(self.lerp,hW,button:W(),0.001)
            end

            self:DrawHighlightSide(w,h,hX,hW,side)
        end
    end

    if useScrollPanel then
        self.scrollPanel = oop.CreatePanel("v_scrollpanel",self):ad(function(self,w,h) self:setSize(w,h) end)
    end
end

function PANEL:CreateVBar() self.scrollPanel:CreateVBar() end
function PANEL:CreateHBar() self.scrollPanel:CreateHBar() end

function PANEL:Clear()
    self.buttons = {}

    if self.scrollPanel then
        self.scrollPanel:Clear()
    else
        for i,panel in pairs(self:GetChildren()) do
            panel:Remove()
        end
    end
end

function PANEL:SetFont(font)
    self.font = font or "HS.12"

    for i,button in pairs(self.buttons) do
        button.font = self.font
    end

    return self
end

function PANEL:Add(name,callback,setID)
    local id = setID or #self.buttons + 1
    local button = oop.CreatePanel("v_button",self.scrollPanel or self)

    self.buttons[id] = button

    button.text = name
    button.font = self.font
    button.id = id
    button.callback = callback

    function button.OnClick(_,key)
        self.setButton = id
        if self.OnClick then self:OnClick(id,key) end
        if callback then callback(id,key) end
    end

    local side = self.side
    
    if side == "left" or side == "right" then
        button:ad(function(_,w,h)
            local isLast = id == #self.buttons
            
            if self.WideButton == true then
                button:setSize(w,math.ceil(h / #self.buttons))
            else
                button:setSize(w,self.WideButton * ScreenSize)
            end

            button:setPos(0,button:H() * (id - 1))
        end)
    elseif side == "top" or side == "bottom" then
        button:ad(function(_,w,h)
            local isLast = id == #self.buttons

            if self.WideButton == true then
                button:setSize(math.ceil(w / #self.buttons),h)
            else
                button:setSize(self.WideButton * ScreenSize,h)
            end
        
            button:setPos(button:W() * (id - 1),0)

            if isLast then
                if button.x + math.ceil(w / #self.buttons) > w then
                    button:setSize(math.ceil(w / #self.buttons) - 1,button:H())
                end
            end
        end)
    end

    return button
end

function PANEL:Set(id)
    self.setButton = id

    local button = self.buttons[id]
    if button and button.callback then
        button.callback()
    end
end

//

PANEL.initDrawStyle = "white"

PANEL:SetDrawStyle("white",{
    DrawHighlightSide = function(self,w,h,sideX,sideW,sideType)//мог бы наименовать функции но х3 лень
        surface.SetDrawColor(255,255,255)

        if sideType == "right" then
            surface.DrawRect(w - 2,sideX,2,sideW)
        elseif sideType == "left" then
            surface.DrawRect(0,sideX,2,sideW)
        elseif sideType == "top" then
            surface.DrawRect(sideX,0,sideW,2)
        elseif sideType == "bottom" then
            surface.DrawRect(sideX,h - 2,sideW,2)
        end
    end
})

PANEL:SetDrawStyle("whitebox",{
    DrawHighlightSide = function(self,w,h,sideX,sideW,sideType)//мог бы наименовать функции но х3 лень
        surface.SetDrawColor(255,255,255)

        if sideType == "right" then
            surface.DrawRect(w - 2,sideX,2,sideW)
            surface.SetDrawColor(255,255,255,25)
            surface.DrawRect(0,sideX,w,sideW)
        elseif sideType == "left" then
            surface.DrawRect(0,sideX,2,sideW)
            surface.SetDrawColor(255,255,255,25)
            surface.DrawRect(0,sideX,w,sideW)
        elseif sideType == "top" then
            surface.DrawRect(sideX,0,sideW,2)
            surface.SetDrawColor(255,255,255,25)
            surface.DrawRect(sideX,0,sideW,h)
        elseif sideType == "bottom" then
            surface.DrawRect(sideX,h - 2,sideW,2)
            surface.SetDrawColor(255,255,255,25)
            surface.DrawRect(sideX,0,sideW,h)
        end
    end
})