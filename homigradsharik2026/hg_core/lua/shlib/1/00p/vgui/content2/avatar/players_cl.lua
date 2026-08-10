local PANEL = oop.Reg("v_players","v_panel")
if not PANEL then return end

function PANEL:OnInit()
    self.searchH = 30

    local search = oop.CreatePanel("v_textentry",self)
    search:ad(function(_,w,h) search:setSize(w,self.searchH) end)
    search.DrawOver = function(self,w,h) draw.Frame(0,0,w,h,cframe2,cframe1) end
    search:SetPlaceholderText("Введите имя игрока")
    search:SetFont("H18")
    self.search = search
    function search.OnChange()
        self.value = string.utf8lower(search:GetValue())
        if self.OnChangeFilterValue then self:OnChangeFilterValue(self.value) end
        self:Update()
    end
    self.value = ""

    local scroll = oop.CreatePanel("v_scrollpanel",self):ad(function(self,w,h) self:setPos(0,search:H()):setSize(w,h - self.y) end)
    self.scrollPanel = scroll

    local avatars = oop.CreatePanel("v_avatarlist",scroll)
    self.avatars = avatars
    avatars:SetScrollPanel(scroll)

    self.list = {}

    self.Filter = function(self,value,info) return value == "" or string.find(string.utf8lower(info.name or ""),value) end
end

function PANEL:SetHeightSearch(h)
    self.searchH = h
    self.search:InvalidateLayout(true)
    self.avatars:InvalidateLayout(true)
end

function PANEL:CreateVBar() self.scrollPanel:CreateVBar() end

function PANEL:SetPlaceholderText(text) self.search:SetPlaceholderText(text) end

//

function PANEL:Setup(iconSize)
    self.iconSize = iconSize
    self.avatars:Setup(iconSize)
    self.scrollPanel.scrolling = iconSize * 3
end

local function addPanel(self,info)
    local panel = self.avatars:AddPanel(info.id,info.name,info.avatar,info.avatarFrame,info.background,info.backgroundOpacity)

    panel.Draw = function(_,w,h)
        self:DrawPanel(w,h,panel,info)
    end
    
    panel.OnClick = function(_,key)
        if self.OnClick then self:OnClick(key,info) end
    end
end

function PANEL:AddPanel(id,name,avatar,avatarFrame,background,backgroundOpacity,backgroundY)
    for i = 1,#self.list do
        if self.list[i].id == id then return end
    end

    self.list[#self.list + 1] = {
        id = id,
        name = name,
        avatar = avatar,
        avatarFrame = avatarFrame,
        background = background,
        backgroundOpacity = backgroundOpacity,
        backgroundY = backgroundY
    }

    if not self:Filter(self.value,self.list[#self.list]) then return end

    return addPanel(self,self.list[#self.list])
end

function PANEL:RemovePanel(id)
    for i,info in pairs(self.list) do
        if info[1] == id then
            table.remove(self.list)

            break
        end
    end

    self.avatars:RemovePanel(id)
end

function PANEL:AddPlayer(ply)
    return self:AddPanel(ply:SteamID64(),ply:Name(),ply:GetAvatar(),ply:GetAvatarFrame(),ply:GetBackground(),ply:GetBackgroundOpacity(),ply:GetBackgroundY())
end

function PANEL:SetAlphaPanel(...) self.avatars:SetAlphaPanel(...) end

function PANEL:Clear()
    self.list = {}
    self.avatars:Clear()
end

function PANEL:Update()
    local value = self.value

    self.avatars:Clear()
    if self.OnChangeFilterValue then self:OnChangeFilterValue(self.value) end

    for i,info in pairs(self.list) do
        if not self:Filter(value,info) then continue end

        addPanel(self,info)
    end
end

//

PANEL:SetDrawStyle("white",{
    DrawPanel = function(self,w,h,panel,info)
        surface.SetDrawColor(255,255,255,5)
        surface.DrawRect(0,0,w,h)

        if panel:IsHovered() then
            surface.SetDrawColor(255,255,255,15)
            surface.DrawRect(0,0,w,h)
        end
    end,
    Init = function(self,style)
        self.search:SetupDrawStyle("white")
        
        self.DrawPanel = style.DrawPanel
    end
})

PANEL:SetDrawStyle("dark",{
    DrawPanel = function(self,w,h,panel,info)
        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)

        if panel:IsHovered() then
            surface.SetDrawColor(255,255,255,5)
            surface.DrawRect(0,0,w,h)
        end
    end,
    Init = function(self,style)
        self.search:SetupDrawStyle("dark")
        
        self.DrawPanel = style.DrawPanel
    end
})