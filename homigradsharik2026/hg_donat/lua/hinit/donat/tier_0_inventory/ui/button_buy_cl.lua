local PANEL = oop.Reg("v_donat_button_buy","v_button")
if not PANEL then return end

PANEL.initDrawStyle = nil

function PANEL:Draw(w,h)
    local color_gold = donatPanel.color_gold

    surface.SetDrawColor(0,0,0,50)
    surface.DrawRect(0,0,w,h)

    self:SetLock(true)

    local item = self.item
    if not item then return end

    local price,priceDonat = item.price,item.priceDonat

    local data = balanceManager.listData[AccountSteamID64] or {}

    local balance,balanceDonat = data.balance,data.balance_donat
    balance = balance and tonumber(balance) or 0
    balanceDonat = balanceDonat and tonumber(balanceDonat) or 0

    if (price and balance >= price) or (priceDonat and balanceDonat >= priceDonat) then
        self:SetLock(false)
        
        surface.SetDrawColor(0,255,0,100)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(0,255,0,255)

        local size = h + h * 0.25 * math.cos(RealTime())
        draw.GradientDown(0,h - size + 1,w,size)

        draw.SimpleText(L("donat_ui_shop_buy",(price or priceDonat)),"H.25",w/2,h/2,self:IsHovered() and (priceDonat and color_gold or colorWhite) or colorBlack,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    else
        surface.SetDrawColor(255,0,0,100)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(255,0,0,255)
        local size = h + h * 0.25 * math.cos(RealTime())
        draw.GradientDown(0,h - size + 1,w,size)

        draw.SimpleText(L("donat_ui_shop_not_enough"),"H.25",w/2,h/2,self:IsHovered() and colorWhite or colorBlack,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    draw.Frame(0,0,w,h,cframe2,cframe1)
end

function PANEL:OnClick()
    donatPanel:CreateBuyPanel(self.item)
end