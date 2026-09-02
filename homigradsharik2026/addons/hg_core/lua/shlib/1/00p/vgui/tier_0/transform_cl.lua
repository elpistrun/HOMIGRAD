local PANEL = oop.Get("v_panel")
if not PANEL then return end

function PANEL:setPos(x,y)
    self:SetPos(x,y)

    return self
end

function PANEL:setSize(w,h)
    self:SetSize(w,h)

    return self
end

function PANEL:setW(w) self:SetWidth(w) return self end
function PANEL:setH(h) self:SetHeight(h) return self end

function PANEL:setX(x) self:SetX(x) return self end
function PANEL:setY(y) self:SetY(y) return self end

function PANEL:W() return self:GetWide() end
function PANEL:H() return self:GetTall() end

function PANEL:setPosD(x,y)
    local parent = self:GetParent()

    self.dx = x
    self.dy = y

    self.x = parent:GetWide() * x
    self.y = parent:GetTall() * y

    return self
end

PANEL.setDPos = PANEL.setPosD

function PANEL:setSizeD(w,h)
    local parent = self:GetParent()

    self.dw = w
    self.dh = h

    self:setSize(parent:GetWide() * w,parent:GetTall() * h)
    
    return self
end

PANEL.setDSize = PANEL.setSizeD

function PANEL:PerformLayout()
    self:Event_Call("Perform",w,h)
end

PANEL:Event_Add("Perform","Transform",function(self,w,h)
    local parent = self:GetParent()

    if self.dx then
        self.x = parent:GetWide() * self.dx
        self.y = parent:GetTall() * self.dy
    end

    if self.dw then
        self:SetSize(parent:GetWide() * self.dw,parent:GetTall() * self.dh)
    end
end,-1)

local max = math.max
local min = math.min

function PANEL:GetScreenViewData()
	local leftx, topy = self:LocalToScreen( 0, 0 )
	local rightx, bottomy = self:LocalToScreen( self:GetWide(), self:GetTall() )

    local curparent = self

    while curparent:GetParent() != nil do
        curparent = curparent:GetParent()

        local x1, y1 = curparent:LocalToScreen( 0, 0 )
        local x2, y2 = curparent:LocalToScreen( curparent:GetWide(), curparent:GetTall() )

        leftx = max( leftx, x1 )
        topy = max( topy, y1 )
        rightx = min( rightx, x2 )
        bottomy = min( bottomy, y2 )
    end

    return leftx,topy,rightx,bottomy
end

function PANEL:EnableScissor()
    local leftx,topy,bottomx,righty = self:GetScreenViewData()
    render.SetScissorRect(leftx,topy,bottomx,righty,true)
end

function PANEL:DisableScissor()
    render.SetScissorRect(0,0,0,0,false)
end

function PANEL:GetChildrenSize()
    local w,h = 0,0

    for _,child in pairs(self:GetChildren()) do
        local w2,h2 = child.x + child:GetWide(),child.y + child:GetTall()

        if w < w2 then w = w2 end
        if h < h2 then h = h2 end
    end

    return w,h
end