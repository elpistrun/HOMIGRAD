donatPanel.shop[100] = {
    name = "Привелегии",
    list = {
        {class = "role_adminpanel",type = "dsuperadmin",priceDonat = 10000},
        {class = "role_adminpanel",type = "dadmin",priceDonat = 4000},
        {class = "role_adminpanel",type = "doperator",priceDonat = 3000},
        {class = "role_adminpanel",type = "megasponsor",priceDonat = 1000},
        {class = "role_adminpanel",type = "sponsor",priceDonat = 500},
        {class = "role_adminpanel",type = "microsponsor",priceDonat = 250}
    }
}

if SERVER then return end

local PAGE = donatPanel:SeasonPage_Reg(101)
PAGE.Name = "DONAT PRIVILEGES"
PAGE.Description = "Специальные предложение за донат валюту"
PAGE.ColorText = Color(255,0,0)

local color = Color(248,250,112)

local randomModels = {
    "models/weapons/w_rif_m4a1_silencer.mdl",
    "models/weapons/w_smg_mp5.mdl",
    "models/weapons/w_smg_mac10.mdl",
    "models/weapons/w_rif_ak47.mdl",

    "models/weapons/w_mach_m249para.mdl",
    "models/weapons/w_suitcase_passenger.mdl",
    "models/weapons/w_eq_fraggrenade.mdl",
    "models/weapons/w_eq_flashbang.mdl"
}

function PAGE.Draw(w,h)
    surface.SetDrawColor(color.r / 2.5,color.g / 2.5,color.b / 2.5,125)
    surface.DrawRect(0,0,w,h)
    
    surface.SetDrawColor(color.r / 2,color.g / 2,color.b / 2,190)
    surface.SetBG("pletanka")
    draw.BG2(2,2,w - 4,h - 4)

    local size = h + h * math.max(math.cos(RealTime())) / 6

    surface.SetDrawColor(color.r,color.g,color.b,200)
    draw.GradientDown(0,h - size + 1,w,size)

    draw.Frame(0,0,w,h,cframe1,cframe2)
end

function PAGE.Open(frame,banner)
    local drawParticles = donatPanel.Create3DParticles(banner,randomModels,0.5)

    function banner:Draw(w,h)
        PAGE.Draw(w,h)
        drawParticles(self,w,h)

        local x,y = self:LocalToScreen(0,0)

        DrawBlur(3,x,y)

        cam.Start3D(Vector(0,500,0),(-Vector(0,100,0)):Angle(),40,x,y,w,h)
            local mdl = CSM.GetByID("models/weapons/arccw_go/v_mach_negev.mdl",tostring(self) .. "main")
            mdl:SetNoDraw(true)
            mdl:SetPos(Vector(-21.75,460 + self.hovered,-14))
            mdl:SetAngles(Angle(-45,0,0))
            mdl:DrawModel()
        cam.End3D()
    end

    local panel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) end)
    panel:setSize(frame:W() / 2,frame:H())
    panel:AddFlexParent()
    
    local panelItem = oop.CreatePanel("v_donat_item_panel",frame):ad(function(self,w,h) self:setSize(w/3.3,h):setPos(w - self:W(),0) end)
    panelItem.itemCreatePanel:Remove()
    panelItem.descPanel.type = "shop"

    local panelBuy = oop.CreatePanel("v_donat_button_buy",panelItem):ad(function(self,w,h) self:setSize(w,math.max(h * 0.05,60)):setPos(0,h - self:H()) end)

    panelItem.descPanel:ad(function(self,w,h) self:setPos(0,panelItem.descItem:H()):setSize(w,h - panelBuy:H() - self.y) end)

    local selectItem,selectItemAnchor

    function panel:Draw()
        selectItem = nil
    end

    function panel:DrawOver()
        local item = selectItem or selectItemAnchor

        panelItem:SetItemEx(item)
        panelBuy.item = item
    end

    local size = panel:W() / 3

    local list = donatPanel.shop[100].list
    local max = #list

    for i = 1,max do
        i = max - i + 1

        local button = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(size,h / 2) end):AddByFlex()

        local item = inventoryManager:CreateItemObjectFromData(list[i])
        item.price = list[i].price
        item.priceDonat = list[i].priceDonat
        item.categoryID = 100
        item.categorySubID = 0  
        item.categoryItemID = i

        function button:Draw(w,h)
            item:DrawIcon(w,h,self)

            draw.SimpleText(item.data.priceDonat,"HS.25",w/2,h * 0.075,donatPanel.color_gold,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            if button:IsHovered() then
                selectItem = item
            end
        end

        function button:OnClick()
            selectItemAnchor = item
        end
    end

    panel:ad(function(self,w,h)
        self:setSize(self:W(),self:H())
        self:setPos(0,h / 2 - self:H() / 2)
    end)
end

concommand.Add("hg_donat_show",function(ply)
    scoreboard.curretPage = 102
    donatPanel.curretSeasonPage = 101

    scoreboard:Open()
end)

if Initialize then scoreboard:Open() end