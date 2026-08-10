local ITEM,NoInherit = inventoryManager:ItemReg("role_base","base",true)
if not ITEM then return INCLUDE_BREAK end

NoInherit.doNotShowInUI = true

ITEM.category = "3_icons"

ITEM.Name = "ROLE_BASE"
ITEM.Desc = "Desc"
ITEM.RaryType = "uncommon"

ITEM.Model = "models/props_combine/breenglobe.mdl"
ITEM.ModelVector = Vector()

ITEM.Config = {
    [1] = {
        desc = "desc1",
        raryType = "rary",
        time = 60 * 60 * 24 * 30
    },
    [2] = {
        desc = "desc2",
        raryType = "legendary",
        time = 60 * 60 * 24 * 30 * 12
    }
}

function ITEM:GetPrintName()
    return self.Name
end

function ITEM:GetDesc()
    return self.Desc or self.Config[self.data.itemType or 1].desc
end

function ITEM:GetRaryType()
    return self.RaryType
end

function ITEM:GetModel()
    return self.WorldModel or "models/weapons/arccw_go/w_eq_fraggrenade_thrown.mdl"
end

function ITEM:GetTimeLess() return self.Config[tonumber(self.type or 1) or 1].time or os.time() + 60 end

local color_black = Color(0,0,0)

ITEM.WorldAngle = Angle(0,0,0)
ITEM.WorldVector = Vector(0,0,0)

function ITEM:DrawObject(w,h,panel,desc)
    local mdl = self:GetCSM(self:GetModel(),desc)

    self:OpenScene(w,h,panel,20)
        mdl:SetAngles(self.WorldAngle)
        mdl:SetPos(self.WorldVector)
        mdl:DrawModel()
    self:CloseScene(w,h,panel)
end

function ITEM:GetItemType()
    return self.data.itemType or 1
end

function ITEM:GetColor() return self.Color end

local color_white,color_gold = Color(255,255,255),Color(2550,255,0)

function ITEM:DrawBar(w,h,panel)
    local raryType = self:GetRaryType()
    local raryData = DonatItemsRaryData[raryType]

    local k = 1
    
    if self.data.activeTime then k = (tonumber(self.data.activeTime) + self:GetTimeLess() - os.time()) / self:GetTimeLess() end

    if not panel.type and not self.data.activated then
        draw.SimpleText("НЕ АКТИВИРОВАНА","HS.12",w/2,12,nil,TEXT_ALIGN_CENTER,nil)

        k = 1
    end

    surface.SetDrawColor(0,0,0)
    surface.DrawRect(0,h - 6,w,6)
    
    surface.SetDrawColor(self:GetColor())
    surface.DrawRect(0,h - 6,w * k,6)
    draw.GradientDown(0,h - h / 6 + 1 - 6,w,h / 6)

    surface.SetDrawColor(255,255,255,25)
    surface.DrawRect(0,h - 1,w,1)

    draw.SimpleText(self:GetPrintName(),"HS.12",w/2,h - 20,self:GetItemType() != 1 and color_gold or color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end

local color_black = Color(0,0,0)
local color_white = Color(255,255,255)

function ITEM:CreateDescPanel(panel)
    if panel.type then return end
    
    local button = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,h/3) end)

    function button.Draw(_,w,h)
        if self.data.activated then
            button:SetLock(true)
            
            surface.SetDrawColor(255,255,255,75)
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(255,255,255,255)
            draw.GradientRight(0,0,w,h)
    
            local time = (self.data.activeTime or 0) + self:GetTimeLess() - os.time()

            draw.SimpleText("ИСТЕКАЕТ ЧЕРЕЗ: " .. math.floor(time / 60 / 60 * 10) / 10 .. " часов","H.25",w - 16,h/2,color_black,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        else
            surface.SetDrawColor(0,255,0,100)
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(0,255,0,255)

            local size = h + h * 0.25 * math.cos(RealTime())
            draw.GradientDown(0,h - size + 1,w,size)

            draw.SimpleText("АКТИВИРОВАТЬ","H.45",w/2,h/2,button:IsHovered() and color_white or color_black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        
            if self.wait then
                DrawBlurByPanel(2,button)
                DrawLoading(w/2,h/2,h/2)
            end
        end
    end

    function button.OnClick()
        self:NetUserActivated(button)
    end
end

function ITEM:NetUserActivated(button)
    if self.data.activated then return end

    MainThread:CoroutineWrap(function()
        button:SetLock(true)
        self.wait = true

        self:NetUserRequest({cmd = "activated"})
        self.wait = nil
        if IsValid(button) then button:SetLock(false) end
    end):Send()
end

ITEM.ActivatedTitle = "Вы активировали подписку!"
ITEM.ActivatedSound = "homigrad/conffeti_pop.wav"

function ITEM:Update()
    if self.wait then
        if self.data.activated then
            DonatInventory_ShowNewItems({{
                {
                    class = self.class,
                    type = self.type,
                    activated = true
                }
            }},self.ActivatedTitle,function() end,self.ActivatedSound)
        end
        
        self.wait = nil
    end
end