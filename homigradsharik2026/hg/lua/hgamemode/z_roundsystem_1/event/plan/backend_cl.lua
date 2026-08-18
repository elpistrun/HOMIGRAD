if eventManager then eventManager.listData = eventManager.listData or {} end

concommand.Add("hg_event_create",function()
    net.Start("event_create")
        net.WriteTable({cmd = "open"})
    net.SendToServer()
end)

concommand.Add("hg_event_remove",function(_,_,args)
    net.Start("hg_event_remove")
        net.WriteString(tostring(args[1] or ""))
    net.SendToServer()
end)

net.Receive("hg_event_list",function()
    if not eventManager then return end
    eventManager.listData = net.ReadTable() or {}
    eventManager:Event_Call("Update")
end)
