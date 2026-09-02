net.Receive("hg_donat_inventory_full",function()
    local body = net.ReadString()

    if not inventoryManager or not inventoryManager.InputFull then return end

    inventoryManager:InputFull(body)
    inventoryManager:Event_Call("Any Response")
end)

-- The UI can be reloaded after the initial spawn sync. Ask for a fresh copy
-- once all donation files have finished loading.
hook.Add("InitPostEntity","HG Donat Inventory Sync",function()
    net.Start("hg_donat_inventory_request")
    net.SendToServer()
end)
