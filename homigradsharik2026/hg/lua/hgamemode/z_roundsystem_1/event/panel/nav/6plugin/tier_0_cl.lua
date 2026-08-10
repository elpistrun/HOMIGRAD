EventPanel_Pages[6] = {}
local Panel = EventPanel_Pages[6]
Panel.Name = "event_plugins"

function Panel.Create(frame)
    EventPanel_PluginSetPage = EventPanel_PluginSetPage or 1

    local list = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setSize(300,h) end)
    list:SetHighlightSide("right")
    list.WideButton = 50

    local pagelists = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h) self:setPos(list:W(),0):setSize(w - list:W(),h) end)
    pagelists:SetHorizontal(false)

    for name,plugin in SortedPairs(EventPluginsClasses) do
        if name == "base" then continue end

        local page = pagelists:Add()
        local id = #pagelists.pages
        
        page.plugin = plugin
        plugin.page = page
        
        for k,v in pairs(plugin) do page[k] = v end

        page.listUpdate = {}

        function page:Update()
            for i,panel in pairs(page.listUpdate) do panel:Update() end
        end

        page:AddEditBool("enabled")

        list:Add(L(plugin.PrintName or name),function()
            EventPanel_PluginSetPage = id
            pagelists:Set(id)
        end)

        if plugin.Create then plugin:Create(page) end
    end

    pagelists:Set(EventPanel_PluginSetPage)
    list:Set(EventPanel_PluginSetPage)
end

event.Add("Event Plugin Sync","UI",function(plugin)
    if plugin.page and IsValid(plugin.page) then plugin.page:Update() end
end)