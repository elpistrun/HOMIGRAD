local PANEL = oop.Reg("v_scrollpage","v_panel")
if not PANEL then return end

function PANEL:OnInit()
    self.pages = {}

    self.page = 1
    self.setPage = 1
    self.Lerp = 1

    self.canvasPanel = oop.CreatePanel("v_panel",self)
end

function PANEL:SetHorizontal(horizontal)
    self.horizontal = horizontal

    if horizontal then
        self.canvasPanel:ad(function(canvas,w,h) canvas:setSize(w * #self.pages,h) end)
    else
        self.canvasPanel:ad(function(canvas,w,h) canvas:setSize(w,h * #self.pages) end)
    end
end

function PANEL:Step()
    self.page = LerpFTLess(self.Lerp,self.page,self.setPage,0.05)

    if self.horizontal then
        self.canvasPanel:setPos(-self:W() * (self.page - 1),0)
    else
        self.canvasPanel:setPos(0,-self:H() * (self.page - 1))
    end
end

function PANEL:Add(id,page)
    page = page or oop.CreatePanel("v_panel",self.canvasPanel)
    
    id = id or #self.pages + 1
    page.id = id

    if self.pages[id] == page then return end

    page:SetVisible(true)

    page.GetPageInterpolation = function()
        if self.page > id then
            return 1 - math.min(self.page - id,1)
        else
            return 1 - math.min(id - self.page,1)
        end
    end

    table.insert(self.pages,id,page)
    for i = 1,#self.pages do self.pages[i].id = i end

    self:UpdateLayout()

    return page,id
end

function PANEL:Pop(id,dontDelete)
    local page = self.pages[id]
    if not page then return end

    table.remove(self.pages,id)
    for i = 1,#self.pages do self.pages[i].id = i end

    if not dontDelete and IsValid(page) then
        page:Remove()
    else
        page:SetVisible(false)
    end

    self:UpdateLayout()

    return page
end

function PANEL:Set(page,fast)
    self.setPage = page
    if fast then self.page = page end

    if self.OnPage then self:OnPage(page) end
    self:Event_Call("Page",page)
end

function PANEL:Clear()
    for i,panel in pairs(self.canvasPanel:GetChildren()) do
        panel:Remove()
    end

    self.pages = {}
end

function PANEL:UpdateLayout()
    for i = 1,#self.pages do
        local page = self.pages[i]

        page:setSize(self:W(),self:H())

        i = i - 1

        if self.horizontal then
            page:setPos(self:W() * i,0)
        else
            page:setPos(0,self:H() * i)
        end
    end
end