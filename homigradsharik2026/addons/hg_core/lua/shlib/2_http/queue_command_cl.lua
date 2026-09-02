concommand.Add("cl_queue_show",function(ply)
    for name,thread in pairs(queueManager.thread) do
        if TypeID(thread) != TYPE_TABLE then continue end
        
        print(name .. ": " .. table.Count(thread.list))
        
        for id,queue in pairs(thread.list) do
            print("\t" .. queue:GetPrint())

            if queue.isTransaction then
                for id,queue in pairs(queue.list) do
                    print("\t\t" .. queue:GetPrint())
                end
            end
        end
    end
end)

concommand.Add("cl_queue_reset_all",function(ply)
    local count = 0

    for name,thread in pairs(queueManager.thread) do
        if TypeID(thread) != TYPE_TABLE then continue end

        for id,queue in pairs(thread.list) do
            count = count + 1
            
            thread.list[id] = nil
        end
    end

    print("reset " .. count .. " queue")
end)

concommand.Add("cl_queue_print",function(ply,cmd,args)
    local queue = queueManager.thread[args[1]].list[tonumber(args[2])]

    print("name: " .. queue:Name() .. "\nstack: " .. queue.stack)
end)