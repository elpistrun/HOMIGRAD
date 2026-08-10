local white = Color(25,25,25)
local white2 = Color(22,22,22)
local white3 = Color(19,19,19)

local acceptCategory = {
    ["gm"] = "Sandbox",
    ["jb"] = "Jail Break",

    ["roblox"] = "Roblox",
    ["rblx"] = "Roblox"
}

function RTVUI_CreateSelectMap(page,callback,drawIcon)
    local iconSize = math.min(ScrH(),ScrW()) * 0.2

    // Category
    
    local category = oop.CreatePanel("v_panel",page):ad(function(self,w,h) self:setSize(250,h * 0.75):setPos(w * 0.05,h * 0.2) end)
    
    function category:Draw(w,h)
        draw.RoundedBox(8,0,0,w,h,white)

        draw.SimpleText(L("rtv_category"),"HS.25",w / 2,16,nil,TEXT_ALIGN_CENTER)
    end
 
    
    local scrollnav = oop.CreatePanel("v_scrollnav",category):ad(function(self,w,h) self:setSize(w - 32,h - 64):setPos(16,48) end)
    scrollnav:SetHighlightSide("right",true,40)
    
    // Maps

    local maps = oop.CreatePanel("v_panel",page):ad(function(self,w,h) self:setSize(w * 0.75,h * 0.75):setPos(w * 0.2,h * 0.2) end)
    
    function maps:Draw(w,h)
        draw.RoundedBox(8,0,0,w,h,white)

        draw.SimpleText(L("rtv_maps"),"HS.25",w / 2,16,nil,TEXT_ALIGN_CENTER)
    end

    local scrollpanelMaps = oop.CreatePanel("v_scrollpanel",maps):ad(function(self,w,h) self:setSize(w - 32,h - 64):setPos(16,48) end)
    scrollpanelMaps:CreateVBar()
    scrollpanelMaps.scrolling = iconSize * 2

    local search = oop.CreatePanel("v_textentry",maps):ad(function(self,w,h) self:setSize(w * 0.3,30):setPos(16,16) end)
    search.font = "HS.12"
    search:SetPlaceholderText(L("rtv_search"))

    function search:OnChange()
        scrollpanelMaps:Update()
    end

    // General

    function scrollnav:Update(tags)
        self:Clear()

        local i = 0
        for tag in SortedPairs(tags) do
            local I = i
            i = i + 1
            local butt = scrollnav:Add()
            
            local hover = 0
            function butt:Draw(w,h)
                surface.SetDrawColor(22,22,22)
                surface.DrawRect(0,0,w,h)
                surface.SetDrawColor(19,19,19)
                surface.DrawRect(0,h - 1,w,1)

                draw.SimpleText(tag,"HS.25",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

                if self:IsHovered() then
                    surface.SetDrawColor(255,255,255,1)
                    surface.DrawRect(0,0,w,h)
                end

                hover = LerpFTLess(0.25,hover,scrollnav.setButton - 1 == I and 1 or 0,0.001)
                
                surface.SetDrawColor(64,64,64,64)
                draw.GradientLeft(0,0,w / 2 * (hover),h)
            end

            function butt:OnClick()
                scrollnav:Set(I + 1)
                scrollpanelMaps:Update(tags[tag])
            end

            if not scrollpanelMaps.first then
                scrollpanelMaps.first = true

                butt:OnClick()
            end
        end
    end

    function scrollpanelMaps:Update(listCategory)
        self:Clear()

        listCategory = listCategory or self.listCategory
        self.listCategory = listCategory

        local value = search:GetValue()

        local pointX,pointY = 0,0
        
        for _,map in SortedPairs(listCategory) do
            if map == game.GetMap() then continue end
            
            local info = page.list[map]
            info.name = map

            if value != "" and not string.find(map,value) then continue end

            local x,y = pointX,pointY
            local icon = oop.CreatePanel("v_button",self):ad(function(self,w,h) self:setSize(iconSize,iconSize + mapManager.textH/2):setPos(x,y) end)
        
            function icon:Draw(w,h)
                mapManager.DrawIcon(0,0,w,h,map,align,info)

                if self:IsHovered() then
                    surface.SetDrawColor(255,255,255,5)
                    surface.DrawRect(0,0,w,h)
                end

                if drawIcon then drawIcon(w,h,map,info) end
            end

            function icon:OnClick()
                callback(map)
            end

            pointX = pointX + icon:W()
            if pointX + icon:W() >= self:W() then
                pointY = pointY + icon:H()
                pointX = 0
            end
        end
    end
    
    function page:Update(list)
        local tags = {
            Other = {}
        }

        self.list = list

        for map in SortedPairs(list) do
            local split = string.Split(map,"_")

            local tag = split[1]

            if acceptCategory[tag] and #split >= 2 then
                tag = acceptCategory[tag]

                tags[tag] = tags[tag] or {}
                tags[tag][#tags[tag] + 1] = map
            else
                tags.Other[#tags.Other + 1] = map
            end
        end

        scrollnav:Update(tags)
    end
end

if Initialize then OpenRTV() end