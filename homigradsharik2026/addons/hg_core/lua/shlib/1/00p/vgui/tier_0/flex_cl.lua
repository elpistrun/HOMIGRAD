local PANEL = oop.Get("v_panel")
if not PANEL then return end

function PANEL:AddFlexParent()
    self:ad(function(self,w,h)
        self.flexPointX = 0
        self.flexPointY = 0
        self.flexMaxY = 0

        local whitelist = {}

        for _,child in pairs(self:GetChildren()) do
            whitelist[child] = true
        end

        self.flexWhitelist = whitelist
    end)
end

function PANEL:AddByFlex()
    self:ad(function(self,w,h)
        local parent = self:GetParent()

        if not parent.flexWhitelist[self] then
            self:setPos(self.setFlexPointX or 0,self.setFlexPointY or 0)
            
            return
        end

        parent.flexWhitelist[self] = nil

        if parent.flexPointX + self:W() > parent:W() then
            parent.flexPointX = 0
            parent.flexPointY = parent.flexPointY + parent.flexMaxY
            parent.flexMaxY = 0
        end

        parent.flexMaxY = math.max(parent.flexMaxY,self:H())

        self.setFlexPointX = parent.flexPointX or 0
        self.setFlexPointY = parent.flexPointY or 0
        self:setPos(self.setFlexPointX,self.setFlexPointY)
        
        parent.flexPointX = parent.flexPointX + self:W()
    end)

    return self
end