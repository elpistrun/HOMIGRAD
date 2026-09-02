net.Receive("hg_balance_sync",function()
    if not balanceManager then return end

    for steamid64,data in pairs(net.ReadTable() or {}) do
        data.balance = tonumber(data.balance) or 0
        data.balance_donat = tonumber(data.balance_donat) or 0
        balanceManager.listData[steamid64] = data
        balanceManager:Event_Call("Update",data)
    end
end)

hook.Add("InitPostEntity","HG Balance Request",function()
    net.Start("hg_balance_request")
    net.SendToServer()
end)

