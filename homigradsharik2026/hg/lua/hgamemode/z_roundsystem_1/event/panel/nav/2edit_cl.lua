EventPanel_Pages[2] = {}
local Panel = EventPanel_Pages[2]
Panel.Name = "event_page_edit"

local function cmdValueToText(value)
    if TypeID(value) == TYPE_BOOL then
        return value and 1 or 0
    else
        return tostring(value)
    end
end

function Panel.Create(page)
    function page:Draw(w,h)
        draw.SimpleText(L("event_page_edit"),"HS.25",w / 2,30,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local scrollPanel = oop.CreatePanel("v_scrollpanel",page):ad(function(self,w,h) self:setSize(w,h - 60):setPos(0,60) end)
    scrollPanel.scrolling = scrollPanel:W() * 0.25
    scrollPanel:CreateHBar()

    local I2 = 0
    for category,info in pairs(EventEditsUI) do
        local I = 1
        local create

        local categoryPanel

        for name,desc in SortedPairs(info) do
            if not create then
                create = true
                local i2 = I2
                I2 = I2 + 1

                categoryPanel = oop.CreatePanel("v_panel",scrollPanel):ad(function(self,w,h) self:setSize(scrollPanel:W() * 0.25,h):setPos(self:W() * i2,0) end)
                function categoryPanel:Draw(w,h)
                    surface.SetDrawColor(0,0,0,100)
                    surface.DrawRect(0,0,w,h)

                    draw.SimpleText(category,"HS.18",w / 2,15,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

                    draw.Frame(0,0,w,h,cframe2,cframe1)
                end
            end

            local i = I
            I = I + 1
            local panel = oop.CreatePanel("v_parametr",categoryPanel):ad(function(self,w,h) self:setSize(w,30):setPos(0,self:H() * i) end)
            panel.Tip = L(desc)
            panel.text = name
            panel.font = "HS.18"
            function panel:GetText() return cmdValueToText(EventEdits[name]) end
            function panel.Callback(value) RunConsoleCommand("say","!" .. name .. " " .. tostring(value)) end//lan
        end
    end
end

if Initialize then scoreboard:Open() end

EventEdits = EventEdits or {}

net.Receive("event_info_edit",function()
    EventEdits = net.ReadTable()
end)

net.Receive("event_info_edit_ui",function()
    EventEditsUI = net.ReadTable()
end)