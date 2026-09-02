local ITEM,NoInherit = inventoryManager:ItemReg("role_adminpanel","base",true)
if not ITEM then return INCLUDE_BREAK end

local types = {
    microsponsor = {
        printName = "MICROSPONSOR",
        model = "models/weapons/arccw_go/w_eq_fraggrenade_thrown.mdl",
        vec = Vector(100,0,-1),
        ang = Angle(0,0,0),
        color = Color(230,126,34),
        raryType = "common"
    },
    sponsor = {
        printName = "SPONSOR",
        model = "models/weapons/arccw_go/w_eq_fraggrenade_thrown.mdl",
        vec = Vector(100,0,-1),
        ang = Angle(0,0,0),
        color = Color(230,126,34),
        raryType = "uncommon"
    },
    megasponsor = {
        printName = "MEGASPONSOR",
        model = "models/weapons/arccw_go/w_eq_fraggrenade_thrown.mdl",
        vec = Vector(100,0,-1),
        ang = Angle(0,0,0),
        color = Color(230,126,34),
        raryType = "uncommon"
    },
    doperator = {
        printName = "DOPERATOR",
        model = "models/weapons/arccw_go/w_eq_flashbang_thrown.mdl",
        vec = Vector(100,0,1),
        ang = Angle(0,0,0),
        color = Color(52,152,219),
        raryType = "rary"
    },
    dadmin = {
        printName = "DADMIN",
        model = "models/weapons/arccw_go/w_eq_incendiarygrenade_thrown.mdl",
        vec = Vector(100,0,-0.4),
        ang = Angle(0,0,0),
        color = Color(31,139,76),
        raryType = "legendary"
    },
    dsuperadmin = {
        printName = "DSUPERADMIN",
        model = "models/weapons/arccw_go/w_eq_smokegrenade_thrown.mdl",
        vec = Vector(100,0,0),
        ang = Angle(0,0,0),
        color = Color(31,139,76),
        raryType = "epic"
    }
}

function ITEM:GetRoleNameSystem()
    return types[self:GetType()] and self:GetType()
end

function ITEM:GetType() return self.type == "UNKOWN" and "microsponsor" or self.type or "microsponsor" end
function ITEM:GetRaryType() return types[self:GetType()] and types[self:GetType()].raryType end
function ITEM:GetPrintName() return types[self:GetType()] and types[self:GetType()].printName end
function ITEM:GetColor() return types[self:GetType()] and types[self:GetType()].color end
function ITEM:GetDesc() return types[self:GetType()] and types[self:GetType()].desc or [[
Выдаётся навсегда.

Купить её можно за Donat Balance,
а пополнить Donat Balance можно на нашем сайте https://kopigrad.com/shop/

Рекомендую перед покупкой ознакомится с нашими правилами проекта!
Иначе за многочисленые нарушения мы можем снять с вас привелегию!
https://kopigrad.com/wiki/rules/
]]
end

if SERVER then return end

local color_gray = Color(200,200,200,125)

function ITEM:CreateDescPanel(panel)
    if panel.type then
        local butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,h/3) end)
        butt:SetupDrawStyle("white") butt.font = "HS.18"
        function butt:DrawText(w,h)
            draw.SimpleText("ПОДРОБНОСТИ ПЛЮШЕК ПРИВЕЛЕГИИ",self.font,w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
            draw.SimpleText("https://kopigrad.com/role/",self.font,w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
            draw.SimpleText("нажмите на эту кнопку что-бы открыть сайт","H.12",w/2,h - 6,color_gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
        end
        function butt:OnClick() gui.OpenURL("https://kopigrad.com/role/") end

        local butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,h/3):setPos(0,h/3) end)
        butt:SetupDrawStyle("white") butt.font = "HS.18"
        function butt:DrawText(w,h)
            draw.SimpleText("ПРАВИЛА НАШЕГО ПРОЕКТА",self.font,w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
            draw.SimpleText("https://kopigrad.com/wiki/rules/",self.font,w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
            draw.SimpleText("нажмите на эту кнопку что-бы открыть сайт","H.12",w/2,h - 6,color_gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
        end
        function butt:OnClick() gui.OpenURL("https://kopigrad.com/wiki/rules/") end

        local butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,h/3):setPos(0,h/3*2) end)
        butt:SetupDrawStyle("white") butt.font = "HS.18"
        function butt:DrawText(w,h)
            draw.SimpleText("ПОПОЛНЕНИЕ DONAT BALANCE",self.font,w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
            draw.SimpleText("https://kopigrad.com/shop/",self.font,w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
            draw.SimpleText("нажмите на эту кнопку что-бы открыть сайт","H.12",w/2,h - 6,color_gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
        end
        function butt:OnClick() gui.OpenURL("https://kopigrad.com/shop/") end
    else
        local butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,h/3) end)
        butt:SetupDrawStyle("white") butt.font = "HS.18"
        function butt:DrawText(w,h)
            draw.SimpleText("ПОДРОБНОСТИ ПЛЮШЕК ПРИВЕЛЕГИИ",self.font,w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
            draw.SimpleText("https://kopigrad.com/role/",self.font,w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
            draw.SimpleText("нажмите на эту кнопку что-бы открыть сайт","H.12",w/2,h - 6,color_gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
        end
        function butt:OnClick() gui.OpenURL("https://kopigrad.com/role/") end
        
        local butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,h/3):setPos(0,h/3) end)
        butt:SetupDrawStyle("white") butt.font = "HS.18"
        function butt:DrawText(w,h)
            draw.SimpleText("ПРАВИЛА НАШЕГО ПРОЕКТА",self.font,w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
            draw.SimpleText("https://kopigrad.com/wiki/rules/",self.font,w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
            draw.SimpleText("нажмите на эту кнопку что-бы открыть сайт","H.12",w/2,h - 6,color_gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
        end
        function butt:OnClick() gui.OpenURL("https://kopigrad.com/wiki/rules/") end

        //
        
        local button = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,h/3):setPos(0,h/3*2) end)

        function button.Draw(_,w,h)
            local profile = Profiles[AccountSteamID64]
            local roles = (profile and profile.roles) or {}
            local hasRole = roles[self:GetRoleNameSystem()]

            if hasRole then
                surface.SetDrawColor(255,0,0,100)
                surface.DrawRect(0,0,w,h)
                surface.SetDrawColor(255,0,0,255)

                button:SetLock(true)
            else
                surface.SetDrawColor(0,255,0,100)
                surface.DrawRect(0,0,w,h)
                surface.SetDrawColor(0,255,0,255)
            end

            local size = h + h * 0.25 * math.cos(RealTime())
            draw.GradientDown(0,h - size + 1,w,size)

            if hasRole then
                draw.SimpleText("У ВАС УЖЕ ЕСТЬ ЭТА ПРИВЕЛЕГИЯ","H.25",w/2,h/2,button:IsHovered() and color_white or color_black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            else
                draw.SimpleText("ПОЛУЧИТЬ ПРИВЕЛЕГИЮ","H.25",w/2,h/2,button:IsHovered() and color_white or color_black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end

            if self.wait then
                DrawBlurByPanel(2,button)
                DrawLoading(w/2,h/2,h/2)
            end
        end

        function button.OnClick()
            self:NetUserActivated(button)
        end
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

function ITEM:DrawObject(w,h,panel,desc)
    local type = types[self:GetType()]

    local mdl = self:GetCSM(type.model,desc)

    self:OpenScene(w,h,panel,20)
        mdl:SetAngles(type.ang)
        mdl:SetPos(type.vec)
        mdl:DrawModel()
    self:CloseScene(w,h,panel)
end

function ITEM:DrawBar(w,h,panel)
    local raryType = self:GetRaryType()
    local raryData = DonatItemsRaryData[raryType]
    
    surface.SetDrawColor(self:GetColor())
    surface.DrawRect(0,h - 6,w,6)
    draw.GradientDown(0,h - h / 6 + 1 - 6,w,h / 6)

    draw.SimpleText(self:GetPrintName(),"HS.12",w/2,h - 20,raryData[3],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end

//

function ITEM:OnDelete()
    if not self.wait then return end

    DonatInventory_ShowNewItems({{
        {
            class = self.class,
            type = self.type
        }
    }},"Вы получили привелегию",function() end)
end

function ITEM:InputUserCommand()
    if not self.wait then return end

    self.wait = nil
end