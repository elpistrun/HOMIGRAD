adminPanel.commandRegistry("map",{{type = "string",name = "Имя карты"}},nil,nil,"mapData")
adminPanel.commandRegistry("map_block",{{type = "string",name = "Имя карты"},{type = "bool",name = "Запретить"}},nil,nil,"mapData")
adminPanel.commandRegistry("map_setcontent",{{type = "string",name = "Имя карты"},{type = "table",name = "content"}},"game",nil,"mapData").UICreate = function(panelCommand,panelCommandRight)
    local scrollPanel = oop.CreatePanel("v_scrollpanel",panelCommand):setSize(panelCommand:W(),panelCommand:H())
    scrollPanel:CreateVBar()
    scrollPanel.canvasPanel:AddFlexParent()
    scrollPanel.scrolling = 200

    local iconSize = math.floor(scrollPanel:W() / 6) - 2

    local selectMap

    for map,content in SortedPairs(mapManager.listIndex) do
        local icon = oop.CreatePanel("v_button",scrollPanel):ad(function(self,w,h) self:setSize(iconSize,iconSize + 20) end):AddByFlex()

        function icon:Draw(w,h)
            if selectMap == map then
                surface.SetDrawColor(255,255,255,64)
                surface.DrawRect(0,0,w,h)

                surface.SetDrawColor(0,0,0,255)
                draw.GradientDown(0,0,w,h)
            end

            if MapsBlocked[map] then
                surface.SetDrawColor(255,0,0,64)
                surface.DrawRect(0,0,w,h)

                surface.SetDrawColor(0,0,0,255)
                draw.GradientDown(0,0,w,h)
            end

            mapManager.DrawIcon(0,0,w,h,map)
            
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
            selectMap = map
        end
    end

    local previewImageTextEntry = oop.CreatePanel("v_textentry",panelCommandRight):setSize(panelCommandRight:W(),40):setPos(0,40)
    previewImageTextEntry:SetPlaceholderText("PREVIEW IMAGE URL")

    local sumbit = oop.CreatePanel("v_button",panelCommandRight):setSize(panelCommandRight:W(),60):setPos(0,panelCommandRight:H() - 60)
    sumbit:SetupDrawStyle("white") sumbit.text = "SUMBIT" sumbit.font = "HS.25"

    function sumbit:OnClick()
        local previewImage = previewImageTextEntry:GetValue()
        if previewImage == "" then previewImage = nil end

        adminPanel.commandSendToServer("map_setcontent",{
            [1] = selectMap,
            [2] = {
                previewImage = previewImage
            }
        })
    end
end

if CLIENT then
    net.ReceiveMediaToken("map_block",function(body)
        MapsBlocked = JSONToTable(body,true) or {}

        event.Call("Map Blocked Sync")
    end)
end
