AdminPanelPages[3] = AdminPanelPages[3] or {}
local Page = AdminPanelPages[3]

Page.Name = "ap_ui_map"

function Page.CanOpen()
    return LocalPlayer():HasSuccess("command_map")
end

local accessCategories = {
    ["jb"] = "JailBreak",
    ["jail"] = "JailBreak",
    ["ba"] = "JailBreak",
    ["deathrun"] = "DeathRun",

    ["gm"] = "Game",
    ["de"] = "Game",
    ["cs"] = "Game",

    ["d1"] = "HalfLife",
    ["d2"] = "HalfLife",
    ["d3"] = "HalfLife",
}

function Page.Open(frame)
    local scrollNav = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(300,h) end)
    scrollNav:SetHighlightSide("right",nil,75);

    local page = oop.CreatePanel("v_scrollpanel",frame):ad(function(self,w,h) self:setPos(scrollNav:W(),0):setSize(w - self.x,h) end)
    page:CreateVBar()
    page.canvasPanel:AddFlexParent()
    page.scrolling = 200

    local iconSize = math.floor(page:W()/6) - 2

    function page:Select(list)
        self:Clear()

        for map,info in SortedPairs(list) do
            local icon = oop.CreatePanel("v_button",page):ad(function(self,w,h) self:setSize(iconSize,iconSize + 20) end):AddByFlex()
        
            function icon:Draw(w,h)
                if MapsBlocked[map] then
                    surface.SetDrawColor(255,0,0,64)
                    surface.DrawRect(0,0,w,h)

                    surface.SetDrawColor(0,0,0,255)
                    draw.GradientDown(0,0,w,h)
                end

                mapManager.DrawIcon(0,0,w,h,map,nil,info)
                
                if self:IsHovered() then
                    surface.SetDrawColor(255,255,255,5)
                    surface.DrawRect(0,0,w,h)
                end

                if MapsBlocked[map] then
                    surface.SetDrawColor(255,0,0,5)
                    surface.DrawRect(0,0,w,h)
                    
                    draw.SimpleText("ЗАКРЫТО","HS.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                end
            end
            
            function icon:OnClick(key)
                if key == MOUSE_LEFT then
                    VParametrAgree(L("ap_ui_realy_want_change_map"),function()
                        RunConsoleCommand("ulx_cmd","map",map)
                    end)
                else
                    RunConsoleCommand("ulx","map_block",map,not MapsBlocked[map] and 1 or 0)
                end
            end
        end
    end

    function frame:Update()
        scrollNav:Clear()

        local categories = {}

        for name,info in SortedPairs(mapManager.listIndex or {}) do
            local split = string.Split(name,"_")
    
            local category = accessCategories[split[1]] or "other"
            
            categories[category] = categories[category] or {}
            categories[category][name] = info
        end
    
        if not Page.SelectCategory then
            Page.SelectCategory = "other"
        end

        for category,list in pairs(categories) do
            local butt = scrollNav:Add(category,function() page:Select(list) Page.SelectCategory = category end)
            butt:SetupDrawStyle("white_gradient"); butt.font = "HS.25"

            if Page.SelectCategory == category then butt:OnClick() end
        end
    end

    frame:Update()
end

event.Add("Map Blocked Sync","UI",function()
    //if IsValid(adminpanel_menu[3]) then adminpanel_menu[3]:Update() end
end)

if Initialize then RunConsoleCommand("adminpanel_menu") end