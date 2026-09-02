local PANEL = oop.Reg("v_alphapage","v_panel")
if not PANEL then return end

function PANEL:OnInit()
    self.pages = {}
    self.curretPage = nil
    self.startSlide = 0
end

function PANEL:GetK() return math.max(self.startSlide - RealTime() + 0.1,0) / 0.1 end

function PANEL:Step()
    local curretPage = self.pages[self.curretPage or 0]
    local oldCurretPage = self.pages[self.oldCurretPage or 0]

    local k = self:GetK()

    if IsValid(curretPage) then
        curretPage:SetAlpha(255 - 255 * k)
    end

    if IsValid(oldCurretPage) then
        oldCurretPage:SetAlpha(255 * k)
        if k <= 0 then oldCurretPage:SetVisible(false) end
    end
end

function PANEL:Add(id)
    local panel = oop.CreatePanel("v_panel",self):ad(function(self,w,h) self:setSize(w,h) end)

    self.pages[id] = panel

    panel:SetVisible(false)

    return panel
end

function PANEL:Set(id,fast,...)
    if id == self.curretPage then return end

    self.oldCurretPage = self.curretPage
    self.curretPage = id

    self.startSlide = RealTime() + (fast and -1 or 0)

    for id,page in pairs(self.pages) do
        page:SetVisible(id == self.curretPage or id == self.oldCurretPage)
        page:SetAlpha(page:IsVisible() and 255 or 0)
    end

    local page = self.pages[self.curretPage]

    if page.Open then page:Open(...) end

    if self.OnSet then self:OnSet() end
end