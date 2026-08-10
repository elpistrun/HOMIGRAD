inventoryManager = ManagerCreate("inventory",{"node","node_network","node_network_user"})

function inventoryManager:InputFull(body)
    for steamid64,items in pairs(JSONToTable(body)) do
        inventoryManager.listData[steamid64] = items

        inventoryManager.listGame[steamid64] = {}

        for id,item in pairs(items) do
            inventoryManager.listGame[steamid64][id] = inventoryManager:CreateItemObjectFromData(item)
        end
    end
end

function inventoryManager:InputServer()
    local cmd = net.ReadString()

    if cmd == "add" then
        local steamid64,item = net.ReadString(),net.ReadTable()

        inventoryManager.listData[steamid64][item.id] = item
        inventoryManager.listGame[steamid64][item.id] = inventoryManager:CreateItemObjectFromData(item)

        inventoryManager:Event_Call("Add",steamid64,item)
    elseif cmd == "remove" then
        local steamid64,item = net.ReadString(),net.ReadTable()

        local itemGame = inventoryManager.listGame[steamid64][item.id]
        if itemGame and itemGame.OnRemove then itemGame:OnRemove() end

        inventoryManager.listData[steamid64][item.id] = item
        inventoryManager.listGame[steamid64][item.id] = nil

        inventoryManager:Event_Call("Remove",steamid64,item)
    elseif cmd == "delete" then
        local item = JSONToTable(net.ReadString())

        local steamid64 = item.steamid64

        local itemGame = inventoryManager.listGame[steamid64][item.id]
        if itemGame and itemGame.OnDelete then itemGame:OnDelete() end

        inventoryManager.listData[steamid64][item.id] = nil
        inventoryManager.listGame[steamid64][item.id] = nil

        inventoryManager:Event_Call("Delete",item)
    elseif cmd == "update" then
        local item = JSONToTable(net.ReadString())

        local steamid64 = item.steamid64

        local oldData = util.tableCopy(inventoryManager.listData[steamid64][item.id])
        inventoryManager.listData[steamid64][item.id] = item

        local itemGame = inventoryManager.listGame[steamid64][item.id]

        if itemGame.class != item.class then
            itemGame = inventoryManager:CreateItemObjectFromData(item)

            inventoryManager.listGame[steamid64][item.id] = itemGame
        else
            itemGame.type = item.type
            itemGame.data = item.data or {}
        end

        itemGame.requestWait = nil

        if itemGame.Update then itemGame:Update(oldData) end

        inventoryManager:Event_Call("Update",item)
    end

    timer.Create("inventoryManger Any Response",0,1,function()
        inventoryManager:Event_Call("Any Response")
    end)
end