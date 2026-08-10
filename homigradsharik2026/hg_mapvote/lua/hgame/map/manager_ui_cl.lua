net.ReceiveMediaToken("maplist.txt",function(body)
    RTV_MapsList = util.JSONToTable(body,true)

    if IsValid(mapManagerFrame) then mapManagerFrame:Update2() end
end)

MapsBlocked = MapsBlocked or {}
net.ReceiveMediaToken("map_blacklist.txt",function(body)
    MapsBlocked = util.JSONToTable(body,true)

    if IsValid(mapManagerFrame) then mapManagerFrame:Update2() end
end)
