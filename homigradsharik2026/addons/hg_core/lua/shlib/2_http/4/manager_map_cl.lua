mapManager = ManagerCreate("mapManager",{"node","node_network"})

mapManager.listIndex = mapManager.listIndex or {}

net.ReceiveMediaToken("mapManager_listIndex",function(body)
    local newListIndex = JSONToTable(body)

    for k in pairs(mapManager.listIndex) do mapManager.listIndex[k] = nil end
    
    for k,v in pairs(newListIndex) do
        mapManager.listIndex[k] = v
    end
end)

mapManager.textH = 32

function mapManager.DrawIcon(x,y,w,h,map,align,info)
    if map == "extend" then map = game.GetMap() end
    if map == "random" then map = RTVGetRandomMap() end

    info = info or mapManager.listIndex[map]
    if not info then
        -- No preview data (e.g. external mapManager_listIndex / rtv_maps token
        -- not loaded). Fall back to a placeholder so the drawing never nil-crashes.
        info = mapManager.listIndex[map] or { previewImage = nil }
    end
    local previewImage = info.previewImage

    surface.SetDrawColor(0,0,0,128)
    draw.GradientDown(x + 1,y + h - (h*0.8 + 1),w - 2,h*0.8)
    surface.SetDrawColor(125,125,125,64)
    draw.GradientDown(x + 1, y + h - mapManager.textH + 1,w - 2,mapManager.textH)
    surface.SetDrawColor(2550,255,255)
    surface.DrawRect(x + 1,y + h - 1,w - 2,1)
    
    local iconSize = w - mapManager.textH
    local xIcon,yIcon

    if align == "CENTER" then
        xIcon,yIcon = w/2 - iconSize/2,h/2 - iconSize/2
    else
        xIcon,yIcon = w/2 - iconSize/2,mapManager.textH/2
    end

    xIcon = x + xIcon
    yIcon = y + yIcon

    if previewImage then
        surface.SetDrawColor(255,255,255,255)
        DrawHTTPMaterial(xIcon,yIcon,iconSize,iconSize,previewImage)
    else
        surface.SetDrawColor(0,0,0,255)
        surface.DrawRect(xIcon,yIcon,iconSize,iconSize)
    end

    draw.SimpleText(map,"HS.12",x + w / 2,y + h - mapManager.textH / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    draw.Frame(xIcon,yIcon,iconSize,iconSize,cframe1,cframe2)
end