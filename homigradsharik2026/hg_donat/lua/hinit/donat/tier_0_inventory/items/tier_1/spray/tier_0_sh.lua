local ITEM = inventoryManager:ItemReg("spray",{"base","base_use","item"},true)
if not ITEM then return INCLUDE_BREAK end

DonatCraftList = DonatCraftList or {}

DonatCraftList["spray"] = {
    category = "Аксесуары",
    name = "Spray",
    input = {
        {class = "receiver"},
        {class = "item",type = "sent_she_potion"},
        {class = "item",type = "sent_she_target"},
        {class = "bodygroup",type = "4",count = 3},
    },
    output = {
        {class = "spray"},
        {class = "spray"}
    }
}


ITEM.category = "4_items"

function ITEM:GetCountUse()
    return self.data.countUse or 500
end

function ITEM:GetPrintName()
    return self.data.name or "Spray"
end

function ITEM:GetDesc()
    if self.data.creatorSteamID then
        return "creator steamid64: " .. self.data.creatorSteamID .. "\nurl: " .. self.data.url
    else
        return "Ненастроеный Spray которым можно красить стены картинками\nБудте внимательнее с выбором картинки,\nрекомендую зайти на https://ru.pinterest.com\nВажно что-бы ulr картинки был доступен ВСЕГДА\n\nЕсли вы нарушите Правила Публикации Контента, вы забаним вас навсегда! (Не пытайтесь нащупать грань)"
    end
end

function ITEM:GetItemInfo() return weapons.Get("wep_spray"),"wep_spray" end
function ITEM:GetItemInfo() return {swep = "wep_spray"} end

if SERVER then return end

CreateClientConVar("hg_rpc_spray","0",true,true)

function ITEM:DrawImage(x,y,w,h)
    if self.data.url then
        local imageMaterial = ImageTool:LoadingURL(self.data.url)

        if type(imageMaterial) == "IMaterial" then
            if imageMaterial:IsError() then
                local alpha, dotStr = ImageTool:Anim()

                surface.SetDrawColor(255, alpha, 255)
                surface.DrawRect(x,y,w,h)
                draw.DrawText("ERROR", "H.25",x + w/2,y + h/2,Color(alpha,0,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            else
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(imageMaterial)

                surface.DrawTexturedRect(x,y,w,h)
            end
        else
            local alpha, dotStr = ImageTool:Anim()

            surface.SetDrawColor(255, alpha, 255)
            surface.DrawRect(x,y,w,h)
            draw.DrawText("Loading" .. dotStr, "H.25",x + w/2,y + h/2,Color(alpha,0,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end
end

function ITEM:DrawBar(w,h,panel,size)
    local box = math.min(w,h) - size * 2

    surface.SetDrawColor(40,40,40)
    surface.SetBG("brick")
    draw.BG2(0,0,w,h)

    local size = h + h * math.cos(RealTime() * 2) / 2
    draw.GradientDown(0,h - size,w,size)

    self:DrawImage(w/2-box/2,h/2-box/2,box,box)

    draw.SimpleText(self:GetPrintName(),"HS.18",w/2,h - (h/2 - box/2)/4,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
    self:DrawCountUse(w,h,panel,desc)

    draw.Frame(0,0,w,h,cframe1,cframe2)
end

function ITEM:DrawObject(w,h,panel,desc)
    if not desc then return end

    local size = math.ceil(h * 0.2) * 1


    local box = math.min(w,h) * 0.7

    self:DrawImage(w/2-box/2,h/2-box/2,box,box)

    self:DrawCountUse(w,h,panel,desc)
end

local wait

function ITEM:CreateDescPanel(panel)
    if self.data.creatorSteamID then
        self:CreateDescPanelItem(panel)
    else
        local textEntry = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(w,h/3) end)
        textEntry:SetPlaceholderText("Введите URL картинки")
        textEntry:SetText(self.data.url or "")

        function textEntry.OnEnter(_,value)
            self.data.url = value != "" and value
        end
        
        local textEntry = oop.CreatePanel("v_textentry",panel):ad(function(self,w,h) self:setSize(w,h/3):setPos(0,h/3) end)
        textEntry:SetPlaceholderText("Имя")
        textEntry:SetText(self.data.name or "")

        function textEntry.OnEnter(_,value)
            self.data.name = value != "" and value
        end

        if panel.type == "shop" then return end

        local button = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,h/3):setPos(0,h/3*2) end)
        button:SetupDrawStyle("white") button.text = "Запечатать" button.font = "HS.45"

        function button.OnClick()
            if not self.data.url or not self.data.name then return end

            Homigrad_RulesPublishContent("hg_rpc_spray",function()
                VParametrAgree("Вы уверены в своём выборе?",function()
                    MainThread:CoroutineWrap(function()
                        self:NetUserRequest({cmd = "set",url = self.data.url,name = self.data.name})
                    end):Send()
                end,"После принятие решения вы не смоежте больше распечатать этот " .. (self.data.name or ""))
            end)
        end

        function button.Step()
            if self.data.creatorSteamID then
                panel:Clear()

                self:CreateDescPanel(panel)
            end
        end
    end
end