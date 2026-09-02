net.Receive("event_info_cmd",function()
    Event_ChatCommandsUI = net.ReadTable()

    local Event_ChatCommandsCategoryByName = {}

    for category,info in pairs(Event_ChatCommandsUI) do
        for name,desc in pairs(info) do
            Event_ChatCommandsCategoryByName[name] = category
        end
    end
end)
