adminPanel.commandCreate("menu",function()
    RunConsoleCommand("adminpanel_menu")
end)

AdminPanelPages = AdminPanelPages or {}

concommand.Add("adminpanel_menu",function()
    if IsValid(adminpanel_menu) then adminpanel_menu:Remove() end

    adminpanel_menu = VguiCreateBlackScreen("adminpanel")

    local scrollnav = oop.CreatePanel("v_scrollnav",adminpanel_menu):ad(function(self,w,h) self:setPos(w*0.05,h*0.05):setSize(w - w * 0.05 * 2,50) end)
    scrollnav:SetHighlightSide("bottom",nil,true)

    local scrollpage = oop.CreatePanel("v_scrollpage",adminpanel_menu):ad(function(self,w,h) self:setPos(scrollnav.x,scrollnav.y + scrollnav:H()):setSize(scrollnav:W(),h - self.y - h * 0.05) end)
    scrollpage:SetHorizontal(true)
    scrollpage.Lerp = 1

    function scrollpage:Draw(w,h)
        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)
        
        draw.Frame(0,0,w,h,cframe1,cframe2)
    end

    local pages = {}
    
    function adminpanel_menu:Update()
        for i,page in pairs(AdminPanelPages) do
            if page.CanOpen and page.CanOpen() != pages[i] then scrollnav:Set(number,force) adminpanel_menu:Build() break end
        end

        for i,page in pairs(scrollpage.pages) do
            if page.Update then page:Update() end
        end 
    end

    function adminpanel_menu:SelectPage(i,force)
        AdminPanelPage = i
        local page = AdminPanelPages[i]
        local panel = adminpanel_menu[i]

        local number = AdminPanelPages[i].number
        scrollpage:Set(number,force)

        if not panel.isOpen then
            panel.isOpen = true
            page.Open(panel)
        end
    end

    function adminpanel_menu:Build()
        scrollnav:Clear()

        for i,page in pairs(AdminPanelPages) do
            if page.CanOpen and not page.CanOpen() then pages[i] = false continue end
            pages[i] = true

            local panel = scrollpage:Add()
            adminpanel_menu[i] = panel
            AdminPanelPages[i].number = #scrollpage.pages

            local butt = scrollnav:Add(L(page.Name or i),function()
                adminpanel_menu:SelectPage(i)
            end)
            butt:SetupDrawStyle("white_gradient"); butt.font = "H30Black"
        end
    end

    adminpanel_menu:Build()

    if not AdminPanelPage then AdminPanelPage = 1 end
    if AdminPanelPage then scrollnav:Set(AdminPanelPage,true) end
end)

if Initialize then RunConsoleCommand("adminpanel_menu") end