EventPanel_Pages[5] = {}
local Panel = EventPanel_Pages[5]
Panel.Name = "event_chat"

local gray = Color(166,165,165,165)

function Panel.Create(page)
    local scrollpanel = oop.CreatePanel("v_scrollpanel",page):setDSize(1,1)
    scrollpanel:CreateVBar()
    scrollpanel.scrolling = 400

    for name,info in pairs(Event_ChatCommandsUI) do
        local category = oop.CreatePanel("v_panel",scrollpanel)

        function category:Draw(w,h)
            surface.SetDrawColor(0,0,0,200)
            surface.DrawRect(0,0,w,30)
            surface.SetDrawColor(255,255,255,64)
            draw.GradientLeft(0,0,w / 3,30)
            draw.SimpleText(name,"HS.18",15,15,nil,nil,TEXT_ALIGN_CENTER)
        end

        function category:DrawOver(w,h)
            draw.Frame(0,0,w,h,cframe1,cframe2)
        end

        local y = 30
        for name,cmd in SortedPairs(info) do
            local Y = y
            y = y + 30
            local panel = oop.CreatePanel("v_panel",category):ad(function(self,w,h) self:setSize(w,30):setPos(0,Y) end)
            local desc = L(cmd[1] or "")

            local args = ""
            for i,arg in pairs(cmd[2] or {}) do
                args = args .. " <" .. arg .. ">"
            end

            function panel:Draw(w,h)
                draw.SimpleText(name,"HS.18",15,15,nil,nil,TEXT_ALIGN_CENTER)
                local tw,th = surface.GetTextSize(name)

                draw.SimpleText(args,"HS.18",15 + tw,15,gray,nil,TEXT_ALIGN_CENTER)
                
                surface.SetDrawColor(0,0,0,200)
                surface.DrawRect(0,h - 1,w,1)

                if panel:DrawTip(desc) then
                    surface.SetDrawColor(255,255,255,5)
                    surface.DrawRect(0,0,w,h)
                end
            end
        end

        category:ad(function(self,w,h) self:setSize(w,y) end)
    end

    scrollpanel:ad(function(self,w,h)
        local y = 0

        for i,child in pairs(scrollpanel.canvasPanel:GetChildren()) do
            child:setPos(0,y)
            y = y + child:H()
        end
    end)
end